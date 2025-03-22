// lib/features/order/data/repositories/kitchen_order_repository.dart

import '../../../../../common/log/loggers.dart';
import '../../services/kitchen_api_service.dart';
import '../models/kitchen_order.dart';
import '../models/kitchen_order_response.dart';
import 'order_exception.dart';

class KitchenOrderRepository {
  static const String TAG = '[KitchenOrderRepository]';
  final KitchenApiService apiService;

  KitchenOrderRepository({
    required KitchenApiService apiService,
  }) : apiService = apiService;

  Future<KitchenOrderResponse> createRedisOrder({
    required String customerId,
    required String documentNo,
    required String cSBunitID,
    required String customerName,
    required String dateOrdered,
    required String status,
    required List<KitchenOrderItem> lineItems,
  }) async {
    try {
      // Step 1: Log the start of the repository operation
      AppLogger.logInfo('$TAG Creating kitchen order: $documentNo');

      // Step 2: Validate required fields
      if (documentNo.isEmpty || cSBunitID.isEmpty) {
        throw OrderException('Document number and business unit ID are required');
      }
      if (lineItems.isEmpty) {
        throw OrderException('Cannot create kitchen order with empty line items');
      }

      // Step 3: Format date to ISO 8601
      final formattedDate = DateTime.tryParse(dateOrdered)?.toIso8601String() ??
          DateTime.now().toIso8601String();

      // Step 4: Create KitchenOrder object with exact API structure
      final order = KitchenOrder(
        customerId: customerId,
        documentno: documentNo,
        cSBunitID: cSBunitID,
        customerName: customerName,
        dateOrdered: formattedDate,
        status: status.toLowerCase(),
        line: lineItems.map((item) => KitchenOrderItem(
          mProductId: item.mProductId,
          name: item.name,
          qty: item.qty, // Ensured as int upstream
          tokenNumber: item.tokenNumber, // Ensured as int upstream
          notes: item.notes,
          productioncenter: item.productioncenter,
          status: item.status.toLowerCase(),
          subProducts: item.subProducts.map((addon) => KitchenOrderAddon(
            addonProductId: addon.addonProductId,
            name: addon.name,
            qty: addon.qty,
          )).toList(),
        )).toList(),
      );

      // Step 5: Log the order data for debugging
      AppLogger.logDebug('$TAG Kitchen order details: ${order.toJson()}');

      // Step 6: Send the order to the API service
      final response = await apiService.createRedisOrder(order);

      // Step 7: Verify the response
      if (!response.isSuccess) {
        throw OrderException('Failed to create kitchen order: ${response.message}');
      }

      // Step 8: Log success and return the response
      AppLogger.logInfo('$TAG Kitchen order created successfully: ${response.message}');
      return response;
    } catch (e) {
      // Step 9: Handle and log errors
      AppLogger.logError('$TAG Failed to create kitchen order: $e', stackTrace: StackTrace.current);
      if (e is OrderException) rethrow;
      throw OrderException('Failed to create kitchen order: $e');
    }
  }

  Future<List<KitchenOrder>> getPendingOrders() async {
    try {
      AppLogger.logInfo('$TAG Fetching pending kitchen orders');

      final orders = await apiService.getPendingOrders();

      // Sort orders by date for consistency
      orders.sort((a, b) => DateTime.parse(b.dateOrdered)
          .compareTo(DateTime.parse(a.dateOrdered)));

      AppLogger.logInfo(
          '$TAG Successfully fetched ${orders.length} pending orders');

      return orders;
    } catch (e) {
      AppLogger.logError('$TAG Failed to fetch pending orders: $e',
          stackTrace: StackTrace.current);
      throw OrderException('Failed to fetch pending orders: $e');
    }
  }

  Future<KitchenOrderResponse> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      AppLogger.logInfo(
          '$TAG Updating kitchen order status: $orderId to $status');

      // Validate status
      final validStatuses = [
        'pending',
        'preparing',
        'cooking',
        'ready',
        'completed'
      ];
      final normalizedStatus = status.toLowerCase();

      if (!validStatuses.contains(normalizedStatus)) {
        throw OrderException(
            'Invalid status. Must be one of: ${validStatuses.join(", ")}');
      }

      final response = await apiService.updateOrderStatus(
        orderId: orderId,
        status: normalizedStatus,
      );

      AppLogger.logInfo(
          '$TAG Successfully updated order status: ${response.message}');
      return response;
    } catch (e) {
      AppLogger.logError('$TAG Failed to update order status: $e',
          stackTrace: StackTrace.current);

      if (e is OrderException) {
        rethrow;
      }
      throw OrderException('Failed to update kitchen order status: $e');
    }
  }

  // Helper method to validate order items
  void validateLineItems(List<KitchenOrderItem> items) {
    for (var item in items) {
      if (item.mProductId.isEmpty) {
        throw OrderException('Product ID is required for all items');
      }
      if (item.name.isEmpty) {
        throw OrderException('Product name is required for all items');
      }
      if (item.qty <= 0) {
        throw OrderException('Quantity must be greater than 0');
      }
      if (item.productioncenter.isEmpty) {
        throw OrderException('Production center is required for all items');
      }
    }
  }
}
