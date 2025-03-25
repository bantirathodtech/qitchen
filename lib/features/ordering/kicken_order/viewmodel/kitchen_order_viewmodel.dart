import 'package:flutter/foundation.dart';
import '../../../../common/log/loggers.dart';
import '../model/kitchen_order.dart';
import '../../sales_order/model/payment_order.dart';
import '../repository/kitchen_order_repository.dart';
import '../provider/kitchen_order_state.dart';

class KitchenOrderViewModel extends ChangeNotifier {
  static const String TAG = '[KitchenOrderViewModel]';
  final KitchenOrderRepository _repository;
  final KitchenOrderState _state;

  KitchenOrderViewModel({
    required KitchenOrderRepository repository,
    required KitchenOrderState state,
  })  : _repository = repository,
        _state = state;

  Future<bool> createRedisOrder({
    required String customerId,
    required String documentNo,
    required String cSBunitID,
    required String customerName,
    required String dateOrdered,
    required String status,
    required List<KitchenOrderItem> lineItems,
  }) async {
    try {
      // Step 1: Log the start of the kitchen order_shared_common creation process
      AppLogger.logInfo('Creating kitchen order_shared_common: $documentNo', tag: TAG);

      // Step 2: Set loading state to true and clear any previous errors
      _state.setLoading(true);
      _state.resetError();

      // Step 3: Validate all input data to ensure it meets requirements
      _validateInputData(
        customerId: customerId,
        documentNo: documentNo,
        cSBunitID: cSBunitID,
        customerName: customerName,
        lineItems: lineItems,
      );

      // Step 4: Prepare line items, ensuring all numeric fields are integers
      final preparedItems = _prepareLineItems(lineItems);
      AppLogger.logDebug('$TAG Prepared line items: ${preparedItems.map((i) => i.toJson())}', tag: TAG);

      // Step 5: Call the repository to create the order_shared_common in Redis
      final response = await _repository.createRedisOrder(
        customerId: customerId,
        documentNo: documentNo,
        cSBunitID: cSBunitID,
        customerName: customerName,
        dateOrdered: dateOrdered,
        status: status,
        lineItems: preparedItems,
      );

      // Step 6: Create a KitchenOrder object to update the state
      final createdOrder = KitchenOrder(
        customerId: customerId,
        documentno: documentNo,
        cSBunitID: cSBunitID,
        customerName: customerName,
        dateOrdered: dateOrdered,
        status: status,
        line: preparedItems,
      );
      _state.setOrder(createdOrder);

      // Step 7: Log success and return true
      AppLogger.logInfo('Kitchen order_shared_common created successfully: ${response.message}', tag: TAG);
      return true;
    } catch (e) {
      // Step 8: Handle errors, log them, and update state
      AppLogger.logError('Failed to create kitchen order_shared_common: $e', tag: TAG);
      _state.setError(_formatErrorMessage(e));
      return false;
    } finally {
      // Step 9: Reset loading state regardless of success or failure
      _state.setLoading(false);
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      AppLogger.logInfo('Updating kitchen order_shared_common status: $orderId to $status',
          tag: TAG);

      _state.setLoading(true);
      _state.resetError();

      // Validate status
      if (!_isValidStatus(status)) {
        throw Exception('Invalid status: $status');
      }

      final response = await _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      _state.updateOrderStatus(orderId, status);

      AppLogger.logInfo(
          'Order status updated successfully: ${response.message}',
          tag: TAG);
      return true;
    } catch (e) {
      AppLogger.logError('Failed to update order_shared_common status: $e', tag: TAG);
      _state.setError(_formatErrorMessage(e));
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  Future<List<KitchenOrder>> getPendingOrders() async {
    try {
      AppLogger.logInfo('Fetching pending kitchen orders', tag: TAG);

      _state.setLoading(true);
      _state.resetError();

      final orders = await _repository.getPendingOrders();

      // Update state with latest orders
      for (var order in orders) {
        _state.updateOrderStatus(order.documentno, order.status);
      }

      AppLogger.logInfo('Fetched ${orders.length} pending orders', tag: TAG);
      return orders;
    } catch (e) {
      AppLogger.logError('Failed to fetch pending orders: $e', tag: TAG);
      _state.setError(_formatErrorMessage(e));
      return [];
    } finally {
      _state.setLoading(false);
    }
  }

  // Helper Methods

  void _validateInputData({
    required String customerId,
    required String documentNo,
    required String cSBunitID,
    required String customerName,
    required List<KitchenOrderItem> lineItems,
  }) {
    // Step 3.1: Check for empty required fields
    if (customerId.isEmpty) throw Exception('Customer ID is required');
    if (documentNo.isEmpty) throw Exception('Document number is required');
    if (cSBunitID.isEmpty) throw Exception('Business unit ID is required');
    if (customerName.isEmpty) throw Exception('Customer name is required');
    if (lineItems.isEmpty) throw Exception('Order must contain at least one item');

    // Step 3.2: Validate each line item
    for (var item in lineItems) {
      if (item.mProductId.isEmpty) throw Exception('Product ID is required for all items');
      if (item.name.isEmpty) throw Exception('Product name is required for all items');
      if (item.qty <= 0) throw Exception('Quantity must be greater than 0');
      if (item.productioncenter.isEmpty) throw Exception('Production center is required for all items');
      // Step 3.3: Ensure numeric fields are integers
      if (item.qty.runtimeType != int) throw Exception('Quantity must be an integer');
      if (item.tokenNumber.runtimeType != int) throw Exception('Token number must be an integer');
    }
  }

  List<KitchenOrderItem> _prepareLineItems(List<KitchenOrderItem> items) {
    // Step 4.1: Transform and clean line items, ensuring type safety
    return items.map((item) => KitchenOrderItem(
      mProductId: item.mProductId,
      name: item.name,
      qty: item.qty, // Already validated as int
      notes: item.notes.trim(),
      productioncenter: item.productioncenter,
      tokenNumber: item.tokenNumber, // Already validated as int
      status: item.status.toLowerCase(),
      subProducts: item.subProducts.map((addon) => KitchenOrderAddon(
        addonProductId: addon.addonProductId,
        name: addon.name,
        qty: addon.qty, // Ensure addon qty is int
      )).toList(),
    )).toList();
  }

  bool _isValidStatus(String status) {
    final validStatuses = [
      'pending',
      'preparing',
      'cooking',
      'ready',
      'completed'
    ];
    return validStatuses.contains(status.toLowerCase());
  }

  // Add this method to KitchenOrderViewModel class
  void setDisplayOrder(Order paymentOrder) {
    try {
      AppLogger.logInfo('Setting display kitchen order_shared_common: ${paymentOrder.documentno}', tag: TAG);

      // Convert payment order_shared_common to kitchen order_shared_common format
      final kitchenOrder = KitchenOrder(
        customerId: paymentOrder.customerId ?? paymentOrder.mobileNo,
        documentno: paymentOrder.documentno,
        cSBunitID: paymentOrder.cSBunitID,
        customerName: paymentOrder.customerName ?? 'Guest',
        dateOrdered: paymentOrder.dateOrdered,
        status: 'pending', // Default status
        line: _convertToKitchenItems(paymentOrder.line),
      );

      // Update state without making API calls
      _state.setOrder(kitchenOrder);
      _state.updateOrderStatus(paymentOrder.documentno, 'pending');

      // Notify listeners for UI update
      notifyListeners();

      AppLogger.logInfo('Kitchen order_shared_common set for display successfully', tag: TAG);
    } catch (e) {
      AppLogger.logError('Failed to set kitchen order_shared_common for display: $e', tag: TAG);
    }
  }

// Helper method to convert payment items to kitchen items
  List<KitchenOrderItem> _convertToKitchenItems(List<PaymentOrderItem> paymentItems) {
    return paymentItems.map((item) => KitchenOrderItem(
      mProductId: item.mProductId,
      name: item.name ?? 'Unknown Item',
      qty: item.qty,
      notes: '',
      productioncenter: item.productioncenter ?? 'Default Center',
      tokenNumber: 1, // Default token number
      status: 'pending',
      subProducts: item.subProducts.map((addon) => KitchenOrderAddon(
        addonProductId: addon.addonProductId,
        name: addon.name,
        qty: addon.qty,
      )).toList(),
    )).toList();
  }

  String _formatErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  // State Management Helpers
  bool isOrderPending(String documentNo) {
    return _state.orderStatuses[documentNo]?.toLowerCase() == 'pending';
  }

  bool isOrderInProgress(String documentNo) {
    final status = _state.orderStatuses[documentNo]?.toLowerCase();
    return status == 'preparing' || status == 'cooking';
  }

  bool isOrderReady(String documentNo) {
    return _state.orderStatuses[documentNo]?.toLowerCase() == 'ready';
  }

  bool isOrderCompleted(String documentNo) {
    return _state.orderStatuses[documentNo]?.toLowerCase() == 'completed';
  }
  void clearOrder() {
    // Logic to clear kitchen order_shared_common
    notifyListeners();
  }
}
