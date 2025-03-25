// lib/features/history/services/order_history_service.dart

import 'package:flutter/cupertino.dart';
import '../../../../common/log/loggers.dart';
import '../../../../core/services/base/api_base_service.dart';
import '../../../../core/services/endpoints/api_url_manager.dart';
import '../../../../data/db/app_preferences.dart';
import '../model/order_history_model.dart';

class OrderHistoryService {
  final ApiBaseService apiBaseService;

  OrderHistoryService({required this.apiBaseService});

  // Fetch order_shared_common history from the API
  Future<Map<String, dynamic>> fetchOrderHistory(String customerId) async {
    try {
      AppLogger.logInfo(
          '[OrderHistoryService] Fetching order_shared_common history for customer: $customerId');

      // Get customer data from preferences
      final userData = await AppPreference.getUserData();
      final b2cCustomerId = userData['b2cCustomerId'];

      if (b2cCustomerId == null || b2cCustomerId.toString().isEmpty) {
        AppLogger.logError(
            '[OrderHistoryService] b2cCustomerId not found in stored preferences');
        throw Exception(
            'Customer ID not found. Please login again.');
      }

      AppLogger.logInfo(
          '[OrderHistoryService] Using b2cCustomerId: $b2cCustomerId for API request');

      // Make GET request to orders endpoint
      final response = await apiBaseService.sendRestRequest(
        method: 'GET',
        endpoint: AppUrls.getOrders,
        queryParams: {'customer_id': b2cCustomerId.toString()},
      );

      if (response == null) {
        AppLogger.logError(
            '[OrderHistoryService] No response received from server');
        throw Exception(
            'No response received from server');
      }

      // Log the full response for debugging
      AppLogger.logInfo('[OrderHistoryService] Raw API response: $response');

      // Parse and validate the response
      if (!response.containsKey('data') ||
          !response['data'].containsKey('getMyOrders')) {
        AppLogger.logError(
            '[OrderHistoryService] Invalid response format: Missing data or getMyOrders');
        throw Exception('Invalid response format from server');
      }

      // Convert response to OrderHistory objects and filter duplicates
      final rawOrdersList = response['data']['getMyOrders'] as List;

      // Log the count of raw orders received
      AppLogger.logInfo(
          '[OrderHistoryService] Raw order_shared_common count from API: ${rawOrdersList.length}');

      // Check for duplicates in the raw data
      final orderIds = <String>{};
      final filteredOrders = <Map<String, dynamic>>[];

      for (var order in rawOrdersList) {
        final orderId = order['sOrderID'] ?? '';
        if (orderId.isNotEmpty && !orderIds.contains(orderId)) {
          orderIds.add(orderId);
          filteredOrders.add(order as Map<String, dynamic>);
        }
      }

      // Log how many duplicates were removed
      AppLogger.logInfo(
          '[OrderHistoryService] Filtered ${rawOrdersList.length - filteredOrders.length} duplicate orders');

      // Create a modified response with filtered orders
      final Map<String, dynamic> filteredResponse = Map<String, dynamic>.from(response);
      filteredResponse['data'] = Map<String, dynamic>.from(response['data']);
      filteredResponse['data']['getMyOrders'] = filteredOrders;

      // Log successful response
      debugPrint('[OrderHistoryService] Successfully filtered orders');
      AppLogger.logInfo(
          '[OrderHistoryService] Returning ${filteredOrders.length} unique orders');

      return filteredResponse;
    } catch (e) {
      // Log error and rethrow
      AppLogger.logError(
          '[OrderHistoryService] Failed to fetch order_shared_common history: $e');
      throw Exception('Failed to fetch order_shared_common history: $e');
    }
  }
}


// // lib/features/history/services/order_history_service.dart
//
// import 'package:flutter/cupertino.dart';
// import '../../../../common/log/loggers.dart';
// import '../../../../core/api/api_base_service.dart';
// import '../../../../core/api/api_url_manager.dart';
// import '../../../../data/db/app_preferences.dart';
// import '../model/order_history_model.dart';
//
// class OrderHistoryService {
//   final ApiBaseService
//       apiBaseService; // Base API service for making HTTP requests
//
//   OrderHistoryService({required this.apiBaseService});
//
//   // Fetch order_shared_common history from the API
//   Future<Map<String, dynamic>> fetchOrderHistory(String customerId) async {
//     try {
//       AppLogger.logInfo(
//           'OrderHistoryService: Fetching order_shared_common history for customer: $customerId');
//
//       // Get customer data from preferences
//       final userData = await AppPreference.getUserData();
//       final b2cCustomerId = userData['b2cCustomerId'];
//
//       if (b2cCustomerId == null || b2cCustomerId.toString().isEmpty) {
//         AppLogger.logError(
//             'OrderHistoryService: b2cCustomerId not found in stored preferences');
//         throw Exception(
//             'OrderHistoryService: Customer ID not found. Please login again.');
//       }
//
//       AppLogger.logInfo(
//           'OrderHistoryService: Fetching order_shared_common history for customer: $b2cCustomerId');
//
//       // Make GET request to orders endpoint
//       final response = await apiBaseService.sendRestRequest(
//         method: 'GET',
//         // endpoint: '${AppUrls.createOrder}',
//         endpoint: AppUrls.getOrders,
//         queryParams: {'customer_id': customerId},
//       );
//
//       if (response == null) {
//         AppLogger.logError(
//             'OrderHistoryService: No response received from server');
//         throw Exception(
//             'OrderHistoryService: No response received from server');
//       }
//
//       // Convert response to OrderHistory objects
//       final ordersList = (response['data']['getMyOrders'] as List)
//           .map((order_shared_common) => OrderHistory.fromJson(order_shared_common))
//           .toList();
//
//       // Log successful response
//       debugPrint('OrderHistoryService: Successfully fetched orders');
//       AppLogger.logInfo(
//           'OrderHistoryService: Successfully fetched ${ordersList.length} orders');
//
//       return response;
//     } catch (e) {
//       // Log error and rethrow
//       AppLogger.logError(
//           'OrderHistoryService: Failed to fetch order_shared_common history: $e');
//       throw Exception('OrderHistoryService: Failed to fetch order_shared_common history: $e');
//     }
//   }
// }

// import 'package:cw_food_ordering/features/3.home/api/api_base_service.dart';
//
// import '../../../common/log/loggers.dart';
// import '../../../core/network/api_url_manager.dart';
// import '../../../data/db/app_preferences.dart';
// import '../model/order_history_model.dart';
//
// class OrderHistoryService {
//   final ApiBaseService _apiBaseService;
//
//   OrderHistoryService({required ApiBaseService apiBaseService})
//       : _apiBaseService = apiBaseService;
//
//   Future<List<OrderHistoryModel>> getOrderHistory(String customerId) async {
//     try {
//       AppLogger.logInfo('Fetching order_shared_common history for customer: $customerId');
//
//       // Get customer data from preferences
//       final userData = await AppPreference.getUserData();
//       final b2cCustomerId = userData['b2cCustomerId'];
//
//       if (b2cCustomerId == null || b2cCustomerId.toString().isEmpty) {
//         AppLogger.logError('b2cCustomerId not found in stored preferences');
//         throw Exception('Customer ID not found. Please login again.');
//       }
//       AppLogger.logInfo('Fetching order_shared_common history for customer: $b2cCustomerId');
//
//       final response = await _apiBaseService.sendRestRequest(
//         method: 'GET',
//         body: {'customerId': b2cCustomerId},
//         endpoint:
//             '${AppUrls.createOrder}?customer_id=$customerId', // Using the correct endpoint from AppUrls
//       );
//
//       if (response == null) {
//         AppLogger.logError('No response received from server');
//         throw Exception('No response received from server');
//       }
//
//       final ordersList = (response['data']['getMyOrders'] as List)
//           .map((order_shared_common) => OrderHistoryModel.fromJson(order_shared_common))
//           .toList();
//
//       AppLogger.logInfo('Successfully fetched ${ordersList.length} orders');
//       return ordersList;
//     } catch (e) {
//       AppLogger.logError('Failed to fetch order_shared_common history: $e');
//       throw Exception('Failed to fetch order_shared_common history: $e');
//     }
//   }
// }
