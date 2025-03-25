// lib/features/order_shared_common/data/repositories/kitchen_order_repository.dart

import '../../../../common/log/loggers.dart';
import '../../../../core/services/errors/app_exception.dart';
import '../model/kitchen_order.dart';
import '../model/kitchen_order_response.dart';
import '../service/kitchen_api_service.dart';

class KitchenOrderRepository {
  static const String tag = '[KitchenOrderRepository]';
  final KitchenApiService apiService;

  // Step 1: Initialize repository with API service
  KitchenOrderRepository({
    required KitchenApiService apiService,
  }) : apiService = apiService;

  // Step 2: Create a Redis order
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
      // Step 2.1: Log operation start
      AppLogger.logInfo('$tag Creating kitchen order: $documentNo');

      // Step 2.2: Validate required fields
      if (documentNo.isEmpty || cSBunitID.isEmpty) {
        throw AppException(
          'Document number and business unit ID are required',
          code: 'VALIDATION',
        );
      }
      if (lineItems.isEmpty) {
        throw AppException(
          'Cannot create kitchen order with empty line items',
          code: 'VALIDATION',
        );
      }

      // Step 2.3: Format date
      final formattedDate = DateTime.tryParse(dateOrdered)?.toIso8601String() ??
          DateTime.now().toIso8601String();

      // Step 2.4: Create KitchenOrder object
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
          qty: item.qty,
          tokenNumber: item.tokenNumber,
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

      // Step 2.5: Log order details
      AppLogger.logDebug('$tag Kitchen order details: ${order.toJson()}');

      // Step 2.6: Call API service
      final response = await apiService.createRedisOrder(order);

      // Step 2.7: Validate response
      if (!response.isSuccess) {
        throw AppException(
          'Failed to create kitchen order: ${response.message}',
          code: 'API_ERROR',
        );
      }

      // Step 2.8: Log success
      AppLogger.logInfo('$tag Kitchen order created: ${response.message}');
      return response;
    } catch (e) {
      // Step 2.9: Handle and log errors
      AppLogger.logError('$tag Failed to create kitchen order: $e',
          stackTrace: StackTrace.current);
      throw AppException.from(e, message: 'Failed to create kitchen order: $e');
    }
  }

  // Step 3: Fetch pending orders
  Future<List<KitchenOrder>> getPendingOrders() async {
    try {
      // Step 3.1: Log operation start
      AppLogger.logInfo('$tag Fetching pending kitchen orders');

      // Step 3.2: Call API service
      final orders = await apiService.getPendingOrders();

      // Step 3.3: Sort orders by date
      orders.sort((a, b) => DateTime.parse(b.dateOrdered)
          .compareTo(DateTime.parse(a.dateOrdered)));

      // Step 3.4: Log success
      AppLogger.logInfo('$tag Fetched ${orders.length} pending orders');
      return orders;
    } catch (e) {
      // Step 3.5: Handle and log errors
      AppLogger.logError('$tag Failed to fetch pending orders: $e',
          stackTrace: StackTrace.current);
      throw AppException.from(e, message: 'Failed to fetch pending orders: $e');
    }
  }

  // Step 4: Update order status
  Future<KitchenOrderResponse> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      // Step 4.1: Log operation start
      AppLogger.logInfo('$tag Updating order status: $orderId to $status');

      // Step 4.2: Validate status
      final validStatuses = [
        'pending',
        'preparing',
        'cooking',
        'ready',
        'completed'
      ];
      final normalizedStatus = status.toLowerCase();
      if (!validStatuses.contains(normalizedStatus)) {
        throw AppException(
          'Invalid status. Must be one of: ${validStatuses.join(", ")}',
          code: 'VALIDATION',
        );
      }

      // Step 4.3: Call API service
      final response = await apiService.updateOrderStatus(
        orderId: orderId,
        status: normalizedStatus,
      );

      // Step 4.4: Log success
      AppLogger.logInfo('$tag Status updated: ${response.message}');
      return response;
    } catch (e) {
      // Step 4.5: Handle and log errors
      AppLogger.logError('$tag Failed to update order status: $e',
          stackTrace: StackTrace.current);
      throw AppException.from(e, message: 'Failed to update order status: $e');
    }
  }

  // Step 5: Validate line items
  void validateLineItems(List<KitchenOrderItem> items) {
    for (var item in items) {
      if (item.mProductId.isEmpty) {
        throw AppException(
          'Product ID is required for all items',
          code: 'VALIDATION',
        );
      }
      if (item.name.isEmpty) {
        throw AppException(
          'Product name is required for all items',
          code: 'VALIDATION',
        );
      }
      if (item.qty <= 0) {
        throw AppException(
          'Quantity must be greater than 0',
          code: 'VALIDATION',
        );
      }
      if (item.productioncenter.isEmpty) {
        throw AppException(
          'Production center is required for all items',
          code: 'VALIDATION',
        );
      }
    }
  }
}
// import '../../../../common/log/loggers.dart';
// import '../model/kitchen_order_response.dart';
// import '../service/kitchen_api_service.dart';
// import '../model/kitchen_order.dart';
//
// class KitchenOrderRepository {
//   static const String TAG = '[KitchenOrderRepository]';
//   final KitchenApiService apiService;
//
//   KitchenOrderRepository({
//     required KitchenApiService apiService,
//   }) : apiService = apiService;
//
//   Future<KitchenOrderResponse> createRedisOrder({
//     required String customerId,
//     required String documentNo,
//     required String cSBunitID,
//     required String customerName,
//     required String dateOrdered,
//     required String status,
//     required List<KitchenOrderItem> lineItems,
//   }) async {
//     try {
//       // Step 1: Log the start of the repository operation
//       AppLogger.logInfo('$TAG Creating kitchen order_shared_common: $documentNo');
//
//       // Step 2: Validate required fields
//       if (documentNo.isEmpty || cSBunitID.isEmpty) {
//         throw OrderException('Document number and business unit ID are required');
//       }
//       if (lineItems.isEmpty) {
//         throw OrderException('Cannot create kitchen order_shared_common with empty line items');
//       }
//
//       // Step 3: Format date to ISO 8601
//       final formattedDate = DateTime.tryParse(dateOrdered)?.toIso8601String() ??
//           DateTime.now().toIso8601String();
//
//       // Step 4: Create KitchenOrder object with exact API structure
//       final order = KitchenOrder(
//         customerId: customerId,
//         documentno: documentNo,
//         cSBunitID: cSBunitID,
//         customerName: customerName,
//         dateOrdered: formattedDate,
//         status: status.toLowerCase(),
//         line: lineItems.map((item) => KitchenOrderItem(
//           mProductId: item.mProductId,
//           name: item.name,
//           qty: item.qty, // Ensured as int upstream
//           tokenNumber: item.tokenNumber, // Ensured as int upstream
//           notes: item.notes,
//           productioncenter: item.productioncenter,
//           status: item.status.toLowerCase(),
//           subProducts: item.subProducts.map((addon) => KitchenOrderAddon(
//             addonProductId: addon.addonProductId,
//             name: addon.name,
//             qty: addon.qty,
//           )).toList(),
//         )).toList(),
//       );
//
//       // Step 5: Log the order_shared_common data for debugging
//       AppLogger.logDebug('$TAG Kitchen order_shared_common details: ${order.toJson()}');
//
//       // Step 6: Send the order_shared_common to the API service
//       final response = await apiService.createRedisOrder(order);
//
//       // Step 7: Verify the response
//       if (!response.isSuccess) {
//         throw OrderException('Failed to create kitchen order_shared_common: ${response.message}');
//       }
//
//       // Step 8: Log success and return the response
//       AppLogger.logInfo('$TAG Kitchen order_shared_common created successfully: ${response.message}');
//       return response;
//     } catch (e) {
//       // Step 9: Handle and log errors
//       AppLogger.logError('$TAG Failed to create kitchen order_shared_common: $e', stackTrace: StackTrace.current);
//       if (e is OrderException) rethrow;
//       throw OrderException('Failed to create kitchen order_shared_common: $e');
//     }
//   }
//
//   Future<List<KitchenOrder>> getPendingOrders() async {
//     try {
//       AppLogger.logInfo('$TAG Fetching pending kitchen orders');
//
//       final orders = await apiService.getPendingOrders();
//
//       // Sort orders by date for consistency
//       orders.sort((a, b) => DateTime.parse(b.dateOrdered)
//           .compareTo(DateTime.parse(a.dateOrdered)));
//
//       AppLogger.logInfo(
//           '$TAG Successfully fetched ${orders.length} pending orders');
//
//       return orders;
//     } catch (e) {
//       AppLogger.logError('$TAG Failed to fetch pending orders: $e',
//           stackTrace: StackTrace.current);
//       throw OrderException('Failed to fetch pending orders: $e');
//     }
//   }
//
//   Future<KitchenOrderResponse> updateOrderStatus({
//     required String orderId,
//     required String status,
//   }) async {
//     try {
//       AppLogger.logInfo(
//           '$TAG Updating kitchen order_shared_common status: $orderId to $status');
//
//       // Validate status
//       final validStatuses = [
//         'pending',
//         'preparing',
//         'cooking',
//         'ready',
//         'completed'
//       ];
//       final normalizedStatus = status.toLowerCase();
//
//       if (!validStatuses.contains(normalizedStatus)) {
//         throw OrderException(
//             'Invalid status. Must be one of: ${validStatuses.join(", ")}');
//       }
//
//       final response = await apiService.updateOrderStatus(
//         orderId: orderId,
//         status: normalizedStatus,
//       );
//
//       AppLogger.logInfo(
//           '$TAG Successfully updated order_shared_common status: ${response.message}');
//       return response;
//     } catch (e) {
//       AppLogger.logError('$TAG Failed to update order_shared_common status: $e',
//           stackTrace: StackTrace.current);
//
//       if (e is OrderException) {
//         rethrow;
//       }
//       throw OrderException('Failed to update kitchen order_shared_common status: $e');
//     }
//   }
//
//   // Helper method to validate order_shared_common items
//   void validateLineItems(List<KitchenOrderItem> items) {
//     for (var item in items) {
//       if (item.mProductId.isEmpty) {
//         throw OrderException('Product ID is required for all items');
//       }
//       if (item.name.isEmpty) {
//         throw OrderException('Product name is required for all items');
//       }
//       if (item.qty <= 0) {
//         throw OrderException('Quantity must be greater than 0');
//       }
//       if (item.productioncenter.isEmpty) {
//         throw OrderException('Production center is required for all items');
//       }
//     }
//   }
// }
