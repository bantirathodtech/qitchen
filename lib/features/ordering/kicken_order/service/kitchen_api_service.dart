import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../common/log/loggers.dart';
import '../../../../core/services/base/api_base_service.dart';
import '../../../../core/services/endpoints/api_url_manager.dart';
import '../../../../core/services/errors/network_exception.dart';
import '../../../../core/services/response_handler/network_response_handler.dart';
import '../model/kitchen_order.dart';
import '../model/kitchen_order_response.dart';

class KitchenApiService {
  static const String tag = '[KitchenApiService]';
  final ApiBaseService _apiService;
  final Logger _logger;

  // Step 1: Initialize service with API base service and logger
  KitchenApiService({
    required ApiBaseService apiService,
    Logger? logger,
  })  : _apiService = apiService,
        _logger = logger ?? Logger();

  // Step 2: Create a Redis order
  Future<KitchenOrderResponse> createRedisOrder(KitchenOrder order) async {
    try {
      // Step 2.1: Log the operation start
      AppLogger.logInfo('$tag Creating Redis order');

      // Step 2.2: Log order details for debugging
      AppLogger.logDebug('$tag Redis order data: ${order.toJson()}');
      AppLogger.logDebug('$tag JSON payload: ${jsonEncode(order.toJson())}');

      // Step 2.3: Validate order data
      _validateRedisOrder(order);

      // Step 2.4: Send request to API
      final response = await _apiService.sendRestRequest(
        endpoint: AppUrls.redisOrder,
        method: 'POST',
        body: order.toJson(),
      );

      // Step 2.5: Process response using NetworkResponseHandler
      final processedResponse = NetworkResponseHandler.processResponse(
        Response(
          requestOptions: RequestOptions(path: AppUrls.redisOrder),
          data: response,
          statusCode: 200, // Assuming success, handled by NetworkResponseHandler
        ),
      );

      // Step 2.6: Parse response
      final responseMap = processedResponse as Map<String, dynamic>;
      if (!responseMap.containsKey('message')) {
        throw NetworkException(
          message: 'Invalid Redis API response format: $responseMap',
          code: 'INVALID_RESPONSE',
        );
      }

      final orderResponse = KitchenOrderResponse.fromJson(responseMap);
      if (!orderResponse.isSuccess) {
        throw NetworkException(
          message: 'Redis order creation failed: ${orderResponse.message}',
          code: 'CREATION_FAILED',
        );
      }

      // Step 2.7: Log success
      AppLogger.logInfo('$tag Redis order created: ${orderResponse.message}');
      return orderResponse;
    } catch (e, stackTrace) {
      // Step 2.8: Handle and log errors
      AppLogger.logError('$tag Failed to create Redis order: $e',
          stackTrace: stackTrace);
      rethrow;
    }
  }

  // Step 3: Fetch pending orders
  Future<List<KitchenOrder>> getPendingOrders() async {
    try {
      // Step 3.1: Log operation start
      AppLogger.logInfo('$tag Fetching pending kitchen orders');

      // Step 3.2: Send GET request
      final response = await _apiService.sendRestRequest(
        endpoint: '${AppUrls.redisOrder}/pending',
        method: 'GET',
      );

      // Step 3.3: Process response
      final processedResponse = NetworkResponseHandler.processResponse(
        Response(
          requestOptions: RequestOptions(path: '${AppUrls.redisOrder}/pending'),
          data: response,
          statusCode: 200,
        ),
      );

      // Step 3.4: Validate and parse response
      if (processedResponse is! Map || !processedResponse.containsKey('orders')) {
        throw NetworkException(
          message: 'Invalid response format for pending orders',
          code: 'INVALID_FORMAT',
        );
      }

      final ordersList = List<Map<String, dynamic>>.from(processedResponse['orders']);
      final orders = ordersList.map((json) => KitchenOrder.fromJson(json)).toList();

      // Step 3.5: Log success
      AppLogger.logInfo('$tag Fetched ${orders.length} pending orders');
      return orders;
    } catch (e) {
      // Step 3.6: Handle and log errors
      AppLogger.logError('$tag Failed to fetch pending orders: $e');
      rethrow;
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

      // Step 4.2: Send PUT request
      final response = await _apiService.sendRestRequest(
        endpoint: '${AppUrls.redisOrder}/$orderId/status',
        method: 'PUT',
        body: {'status': status},
      );

      // Step 4.3: Process response
      final processedResponse = NetworkResponseHandler.processResponse(
        Response(
          requestOptions: RequestOptions(path: '${AppUrls.redisOrder}/$orderId/status'),
          data: response,
          statusCode: 200,
        ),
      );

      // Step 4.4: Validate and parse response
      if (!processedResponse.containsKey('message')) {
        throw NetworkException(
          message: 'Invalid status update response format',
          code: 'INVALID_FORMAT',
        );
      }

      final orderResponse = KitchenOrderResponse.fromJson(processedResponse);
      AppLogger.logInfo('$tag Status updated: ${orderResponse.message}');
      return orderResponse;
    } catch (e) {
      // Step 4.5: Handle and log errors
      AppLogger.logError('$tag Failed to update order status: $e');
      rethrow;
    }
  }

  // Step 5: Validate Redis order data
  void _validateRedisOrder(KitchenOrder order) {
    if (order.line.isEmpty) {
      throw NetworkException(
        message: 'Redis order must contain at least one line item',
        code: 'VALIDATION_ERROR',
      );
    }
    for (var item in order.line) {
      if (item.name.isEmpty || item.mProductId.isEmpty) {
        throw NetworkException(
          message: 'Line items must have valid name and product ID',
          code: 'VALIDATION_ERROR',
        );
      }
      if (item.qty.runtimeType != int) {
        throw NetworkException(
          message: 'Quantity must be an integer for item ${item.name}',
          code: 'TYPE_ERROR',
        );
      }
      if (item.tokenNumber.runtimeType != int) {
        throw NetworkException(
          message: 'Token number must be an integer for item ${item.name}',
          code: 'TYPE_ERROR',
        );
      }
    }
  }
}

// import 'dart:convert';
//
// import 'package:logger/logger.dart';
// import '../../../../common/log/loggers.dart';
// import '../../../../core/services/base/api_base_service.dart';
// import '../../../../core/services/endpoints/api_url_manager.dart';
// import '../model/kitchen_order.dart';
// import '../model/kitchen_order_response.dart';
//
// class KitchenApiService {
//   static const String TAG = '[KitchenApiService]';
//   final ApiBaseService _apiService;
//   final Logger _logger;
//
//   KitchenApiService({
//     required ApiBaseService apiService,
//     Logger? logger,
//   })  : _apiService = apiService,
//         _logger = logger ?? Logger();
//
//   Future<KitchenOrderResponse> createRedisOrder(KitchenOrder order) async {
//     try {
//       AppLogger.logInfo('$TAG Creating Redis order_shared_common');
//       AppLogger.logDebug('$TAG Redis order_shared_common data: ${order.toJson()}');
//       AppLogger.logDebug('$TAG JSON payload to Redis: ${jsonEncode(order.toJson())}');
//
//       _validateRedisOrder(order); // Ensures qty and tokenNumber are int
//
//       final response = await _apiService.sendRestRequest(
//         endpoint: AppUrls.redisOrder,
//         method: 'POST',
//         body: order.toJson(),
//       ); // <--- Error likely thrown here
//
//       AppLogger.logDebug('$TAG Received response: $response (type: ${response.runtimeType})');
//
//       Map<String, dynamic> responseMap;
//       if (response is List<dynamic>) {
//         responseMap = response.isNotEmpty ? response[0] as Map<String, dynamic> : {};
//       } else if (response is Map<String, dynamic>) {
//         responseMap = response;
//       } else {
//         throw ApiException(
//           message: 'Unexpected response type: ${response.runtimeType}, data: $response',
//           code: 'INVALID_RESPONSE_TYPE',
//         );
//       }
//
//       if (!responseMap.containsKey('message')) {
//         throw ApiException(
//           message: 'Invalid Redis API response format: $responseMap',
//           code: 'INVALID_RESPONSE',
//         );
//       }
//
//       final orderResponse = KitchenOrderResponse.fromJson(responseMap);
//       if (!orderResponse.isSuccess) {
//         throw ApiException(
//           message: 'Redis order_shared_common creation failed: ${orderResponse.message}',
//           code: 'CREATION_FAILED',
//         );
//       }
//
//       AppLogger.logInfo('$TAG Redis order_shared_common created successfully: ${orderResponse.message}');
//       return orderResponse;
//     } catch (e, stackTrace) {
//       AppLogger.logError('$TAG Failed to create Redis order_shared_common: $e', stackTrace: stackTrace);
//       rethrow;
//     }
//   }
//
//   Future<List<KitchenOrder>> getPendingOrders() async {
//     try {
//       AppLogger.logInfo('$TAG Fetching pending kitchen orders');
//       //
//       // final Map<String, String> headers = {
//       //   'Content-Type': 'application/json',
//       //   'Accept': '*/*'
//       // };
//
//       final response = await _apiService.sendRestRequest(
//         endpoint: '${AppUrls.redisOrder}/pending',
//         method: 'GET',
//         // headers: headers,
//       );
//
//       if (response is! Map || !response.containsKey('orders')) {
//         throw ApiException(
//           message: 'Invalid response format for pending orders',
//           code: 'INVALID_FORMAT',
//         );
//       }
//
//       final ordersList = List<Map<String, dynamic>>.from(response['orders']);
//       final orders =
//           ordersList.map((json) => KitchenOrder.fromJson(json)).toList();
//
//       AppLogger.logInfo(
//           '$TAG Successfully fetched ${orders.length} pending orders');
//       return orders;
//     } catch (e) {
//       AppLogger.logError('$TAG Failed to fetch pending orders: $e');
//       rethrow;
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
//       // final Map<String, String> headers = {
//       //   'Content-Type': 'application/json',
//       //   'Accept': '*/*'
//       // };
//
//       // Match Redis API endpoint structure for updates
//       final response = await _apiService.sendRestRequest(
//         endpoint: '${AppUrls.redisOrder}/$orderId/status',
//         method: 'PUT',
//         // headers: headers,
//         body: {'status': status},
//       );
//
//       if (!response.containsKey('message')) {
//         throw ApiException(
//           message: 'Invalid status update response format',
//           code: 'INVALID_FORMAT',
//         );
//       }
//
//       final orderResponse = KitchenOrderResponse.fromJson(response);
//       AppLogger.logInfo(
//           '$TAG Kitchen order_shared_common status updated successfully: ${orderResponse.message}');
//
//       return orderResponse;
//     } catch (e) {
//       AppLogger.logError('$TAG Failed to update kitchen order_shared_common status: $e');
//       rethrow;
//     }
//   }
//
//   // Helper method to validate Redis order_shared_common data before sending
//   void _validateRedisOrder(KitchenOrder order) {
//     // Step 2.1: Ensure line items exist
//     if (order.line.isEmpty) {
//       throw ApiException(
//         message: 'Redis order_shared_common must contain at least one line item',
//         code: 'VALIDATION_ERROR',
//       );
//     }
//
//     // Step 2.2: Validate each line item
//     for (var item in order.line) {
//       if (item.name.isEmpty || item.mProductId.isEmpty) {
//         throw ApiException(
//           message: 'Redis order_shared_common line items must have valid name and product ID',
//           code: 'VALIDATION_ERROR',
//         );
//       }
//       // Step 2.3: Ensure numeric fields are integers
//       if (item.qty.runtimeType != int) {
//         throw ApiException(
//           message: 'Quantity must be an integer for item ${item.name}',
//           code: 'TYPE_ERROR',
//         );
//       }
//       if (item.tokenNumber.runtimeType != int) {
//         throw ApiException(
//           message: 'Token number must be an integer for item ${item.name}',
//           code: 'TYPE_ERROR',
//         );
//       }
//     }
//   }
// }
