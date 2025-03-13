// lib/features/history/services/order_history_service.dart

import 'package:flutter/cupertino.dart';

import '../../../common/log/loggers.dart';
import '../../../core/api/api_base_service.dart';
import '../../../core/api/api_url_manager.dart';
import '../../../data/db/app_preferences.dart';
import '../model/order_history_model.dart';

class OrderHistoryService {
  final ApiBaseService
      apiBaseService; // Base API service for making HTTP requests

  OrderHistoryService({required this.apiBaseService});

  // Fetch order history from the API
  Future<Map<String, dynamic>> fetchOrderHistory(String customerId) async {
    try {
      AppLogger.logInfo(
          'OrderHistoryService: Fetching order history for customer: $customerId');

      // Get customer data from preferences
      final userData = await AppPreference.getUserData();
      final b2cCustomerId = userData['b2cCustomerId'];

      if (b2cCustomerId == null || b2cCustomerId.toString().isEmpty) {
        AppLogger.logError(
            'OrderHistoryService: b2cCustomerId not found in stored preferences');
        throw Exception(
            'OrderHistoryService: Customer ID not found. Please login again.');
      }

      AppLogger.logInfo(
          'OrderHistoryService: Fetching order history for customer: $b2cCustomerId');

      // Make GET request to orders endpoint
      final response = await apiBaseService.sendRestRequest(
        method: 'GET',
        endpoint: '${AppUrls.createOrder}',
        queryParams: {'customer_id': customerId},
      );

      if (response == null) {
        AppLogger.logError(
            'OrderHistoryService: No response received from server');
        throw Exception(
            'OrderHistoryService: No response received from server');
      }

      // Convert response to OrderHistory objects
      final ordersList = (response['data']['getMyOrders'] as List)
          .map((order) => OrderHistory.fromJson(order))
          .toList();

      // Log successful response
      debugPrint('OrderHistoryService: Successfully fetched orders');
      AppLogger.logInfo(
          'OrderHistoryService: Successfully fetched ${ordersList.length} orders');

      return response;
    } catch (e) {
      // Log error and rethrow
      AppLogger.logError(
          'OrderHistoryService: Failed to fetch order history: $e');
      throw Exception('OrderHistoryService: Failed to fetch order history: $e');
    }
  }
}

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
//       AppLogger.logInfo('Fetching order history for customer: $customerId');
//
//       // Get customer data from preferences
//       final userData = await AppPreference.getUserData();
//       final b2cCustomerId = userData['b2cCustomerId'];
//
//       if (b2cCustomerId == null || b2cCustomerId.toString().isEmpty) {
//         AppLogger.logError('b2cCustomerId not found in stored preferences');
//         throw Exception('Customer ID not found. Please login again.');
//       }
//       AppLogger.logInfo('Fetching order history for customer: $b2cCustomerId');
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
//           .map((order) => OrderHistoryModel.fromJson(order))
//           .toList();
//
//       AppLogger.logInfo('Successfully fetched ${ordersList.length} orders');
//       return ordersList;
//     } catch (e) {
//       AppLogger.logError('Failed to fetch order history: $e');
//       throw Exception('Failed to fetch order history: $e');
//     }
//   }
// }
