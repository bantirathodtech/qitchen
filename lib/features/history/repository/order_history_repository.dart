// lib/features/history/repositories/order_history_repository.dart

import 'package:flutter/cupertino.dart';

import '../model/order_history_model.dart';
import '../service/order_history_service.dart';

class OrderHistoryRepository {
  final OrderHistoryService _service; // Service for API calls

  OrderHistoryRepository(this._service);

  // Fetch and transform order history data
  Future<List<OrderHistory>> getOrderHistory(String customerId) async {
    try {
      // Get raw API response
      final response = await _service.fetchOrderHistory(customerId);

      // Convert response to our model structure
      final orderResponse = OrderHistoryResponse.fromJson(response);

      // Return the list of orders
      return orderResponse.data.orders;
    } catch (e) {
      debugPrint('OrderHistoryRepository Error: $e');
      throw Exception('Error getting order history: $e');
    }
  }
}
