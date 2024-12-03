import 'package:flutter/foundation.dart';

import '../../../common/log/loggers.dart';
import '../data/models/kitchen_order.dart';
import '../data/repositories/kitchen_order_repository.dart';
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
      AppLogger.logInfo('Creating kitchen order: $documentNo', tag: TAG);

      // Reset state
      _state.setLoading(true);
      _state.resetError();

      // Validate input data
      _validateInputData(
        customerId: customerId,
        documentNo: documentNo,
        cSBunitID: cSBunitID,
        customerName: customerName,
        lineItems: lineItems,
      );

      final response = await _repository.createRedisOrder(
        customerId: customerId,
        documentNo: documentNo,
        cSBunitID: cSBunitID,
        customerName: customerName,
        dateOrdered: dateOrdered,
        status: status,
        lineItems: _prepareLineItems(lineItems),
      );

      // Update state with the created order
      final createdOrder = KitchenOrder(
        customerId: customerId,
        documentno: documentNo,
        cSBunitID: cSBunitID,
        customerName: customerName,
        dateOrdered: dateOrdered,
        status: status,
        line: lineItems,
      );
      _state.setOrder(createdOrder);

      AppLogger.logInfo(
          'Kitchen order created successfully: ${response.message}',
          tag: TAG);
      return true;
    } catch (e) {
      AppLogger.logError('Failed to create kitchen order: $e', tag: TAG);
      _state.setError(_formatErrorMessage(e));
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      AppLogger.logInfo('Updating kitchen order status: $orderId to $status',
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
      AppLogger.logError('Failed to update order status: $e', tag: TAG);
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
    if (customerId.isEmpty) {
      throw Exception('Customer ID is required');
    }
    if (documentNo.isEmpty) {
      throw Exception('Document number is required');
    }
    if (cSBunitID.isEmpty) {
      throw Exception('Business unit ID is required');
    }
    if (customerName.isEmpty) {
      throw Exception('Customer name is required');
    }
    if (lineItems.isEmpty) {
      throw Exception('Order must contain at least one item');
    }

    // Validate each line item
    for (var item in lineItems) {
      if (item.mProductId.isEmpty) {
        throw Exception('Product ID is required for all items');
      }
      if (item.name.isEmpty) {
        throw Exception('Product name is required for all items');
      }
      if (item.qty <= 0) {
        throw Exception('Quantity must be greater than 0');
      }
      if (item.productioncenter.isEmpty) {
        throw Exception('Production center is required for all items');
      }
    }
  }

  List<KitchenOrderItem> _prepareLineItems(List<KitchenOrderItem> items) {
    return items
        .map((item) => KitchenOrderItem(
              mProductId: item.mProductId,
              name: item.name,
              qty: item.qty,
              notes: item.notes.trim(),
              productioncenter: item.productioncenter,
              tokenNumber: item.tokenNumber,
              status: item.status.toLowerCase(),
              subProducts: item.subProducts
                  .map((addon) => KitchenOrderAddon(
                        addonProductId: addon.addonProductId,
                        name: addon.name,
                        qty: addon.qty,
                      ))
                  .toList(),
            ))
        .toList();
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
}
