import 'package:logger/logger.dart';

import '../../../common/log/loggers.dart';
import '../../../core/api/api_base_service.dart';
import '../../../core/api/api_error_handler.dart';
import '../../../core/api/api_url_manager.dart';
import '../data/models/kitchen_order.dart';
import '../data/models/kitchen_order_response.dart';

class KitchenApiService {
  static const String TAG = '[KitchenApiService]';
  final ApiBaseService _apiService;
  final Logger _logger;

  KitchenApiService({
    required ApiBaseService apiService,
    Logger? logger,
  })  : _apiService = apiService,
        _logger = logger ?? Logger();

  Future<KitchenOrderResponse> createRedisOrder(KitchenOrder order) async {
    try {
      AppLogger.logInfo('$TAG Creating Redis order');
      AppLogger.logDebug('$TAG Redis order data: ${order.toJson()}');

      // // Add required headers for Redis API
      // final Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'Accept': '*/*'
      // };

      // Send request to Redis API endpoint
      final response = await _apiService.sendRestRequest(
        endpoint: AppUrls.redisOrder,
        method: 'POST',
        // headers: headers,
        body: order.toJson(),
      );

      // Validate response matches expected format
      if (!response.containsKey('message')) {
        throw ApiException(
          message: 'Invalid Redis API response format',
          code: 'INVALID_RESPONSE',
        );
      }

      final orderResponse = KitchenOrderResponse.fromJson(response);

      // Verify success message matches exactly
      if (!orderResponse.isSuccess) {
        throw ApiException(
          message: 'Redis order creation failed: ${orderResponse.message}',
          code: 'CREATION_FAILED',
        );
      }

      AppLogger.logInfo(
          '$TAG Redis order created successfully: ${orderResponse.message}');
      return orderResponse;
    } catch (e) {
      AppLogger.logError('$TAG Failed to create Redis order: $e');
      rethrow;
    }
  }

  Future<List<KitchenOrder>> getPendingOrders() async {
    try {
      AppLogger.logInfo('$TAG Fetching pending kitchen orders');
      //
      // final Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'Accept': '*/*'
      // };

      final response = await _apiService.sendRestRequest(
        endpoint: '${AppUrls.redisOrder}/pending',
        method: 'GET',
        // headers: headers,
      );

      if (response is! Map || !response.containsKey('orders')) {
        throw ApiException(
          message: 'Invalid response format for pending orders',
          code: 'INVALID_FORMAT',
        );
      }

      final ordersList = List<Map<String, dynamic>>.from(response['orders']);
      final orders =
          ordersList.map((json) => KitchenOrder.fromJson(json)).toList();

      AppLogger.logInfo(
          '$TAG Successfully fetched ${orders.length} pending orders');
      return orders;
    } catch (e) {
      AppLogger.logError('$TAG Failed to fetch pending orders: $e');
      rethrow;
    }
  }

  Future<KitchenOrderResponse> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      AppLogger.logInfo(
          '$TAG Updating kitchen order status: $orderId to $status');

      // final Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'Accept': '*/*'
      // };

      // Match Redis API endpoint structure for updates
      final response = await _apiService.sendRestRequest(
        endpoint: '${AppUrls.redisOrder}/$orderId/status',
        method: 'PUT',
        // headers: headers,
        body: {'status': status},
      );

      if (!response.containsKey('message')) {
        throw ApiException(
          message: 'Invalid status update response format',
          code: 'INVALID_FORMAT',
        );
      }

      final orderResponse = KitchenOrderResponse.fromJson(response);
      AppLogger.logInfo(
          '$TAG Kitchen order status updated successfully: ${orderResponse.message}');

      return orderResponse;
    } catch (e) {
      AppLogger.logError('$TAG Failed to update kitchen order status: $e');
      rethrow;
    }
  }

  // Helper method to validate Redis order data before sending
  void _validateRedisOrder(KitchenOrder order) {
    if (order.line.isEmpty) {
      throw ApiException(
        message: 'Redis order must contain at least one line item',
        code: 'VALIDATION_ERROR',
      );
    }

    for (var item in order.line) {
      if (item.name.isEmpty || item.mProductId.isEmpty) {
        throw ApiException(
          message: 'Redis order line items must have valid name and product ID',
          code: 'VALIDATION_ERROR',
        );
      }
    }
  }
}
