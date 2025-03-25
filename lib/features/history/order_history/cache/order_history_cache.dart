// lib/features/history/cache/order_history_cache.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/log/loggers.dart';
import '../model/order_history_model.dart';

/// Dedicated class for caching order_shared_common history data
class OrderHistoryCache {
  static const String TAG = '[OrderHistoryCache]';
  static const String ORDER_HISTORY_DATA_KEY = 'cached_order_history_';
  static const String CACHE_TIMESTAMP_KEY = 'order_history_cache_timestamp_';
  static const int CACHE_DURATION_MS = 300000; // 5 min in milliseconds

  /// Save order_shared_common history data to cache for a specific customer
  static Future<bool> saveOrderHistoryData(String customerId, List<OrderHistory> orders) async {
    try {
      AppLogger.logInfo('$TAG: Saving order_shared_common history data to cache for customer: $customerId');
      final prefs = await SharedPreferences.getInstance();

      // Create a list of order_shared_common JSON objects
      final ordersList = orders.map((order) => _convertOrderToJson(order)).toList();

      // Convert to JSON string
      final jsonData = json.encode(ordersList);

      // Save data and timestamp using customer-specific keys
      await prefs.setString('$ORDER_HISTORY_DATA_KEY$customerId', jsonData);
      await prefs.setInt('$CACHE_TIMESTAMP_KEY$customerId', DateTime.now().millisecondsSinceEpoch);

      AppLogger.logInfo('$TAG: Order history data cached successfully for customer: $customerId');
      return true;
    } catch (e) {
      AppLogger.logError('$TAG: Error caching order_shared_common history data: $e');
      return false;
    }
  }

  /// Get cached order_shared_common history data if available and not expired
  static Future<List<OrderHistory>?> getOrderHistoryData(String customerId) async {
    try {
      AppLogger.logInfo('$TAG: Attempting to get cached order_shared_common history data for customer: $customerId');
      final prefs = await SharedPreferences.getInstance();

      // Check if cache exists
      final cacheKey = '$ORDER_HISTORY_DATA_KEY$customerId';
      if (!prefs.containsKey(cacheKey)) {
        AppLogger.logInfo('$TAG: No cached order_shared_common history data found for customer: $customerId');
        return null;
      }

      // Check if cache is expired
      final timestamp = prefs.getInt('$CACHE_TIMESTAMP_KEY$customerId') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = now - timestamp;

      if (cacheDuration > CACHE_DURATION_MS) {
        AppLogger.logInfo('$TAG: Cached order_shared_common history data is expired for customer: $customerId');
        return null;
      }

      // Retrieve and parse cached data
      final jsonData = prefs.getString(cacheKey);
      if (jsonData == null) return null;

      final ordersList = (json.decode(jsonData) as List)
          .map((item) => _convertJsonToOrder(item as Map<String, dynamic>))
          .toList();

      AppLogger.logInfo('$TAG: Successfully retrieved ${ordersList.length} cached orders for customer: $customerId');
      return ordersList;
    } catch (e) {
      AppLogger.logError('$TAG: Error retrieving cached order_shared_common history data: $e');
      return null;
    }
  }

  /// Clear order_shared_common history data cache for a specific customer or all customers
  static Future<void> clearCache([String? customerId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (customerId != null) {
        // Clear cache for specific customer
        AppLogger.logInfo('$TAG: Clearing order_shared_common history cache for customer: $customerId');
        await prefs.remove('$ORDER_HISTORY_DATA_KEY$customerId');
        await prefs.remove('$CACHE_TIMESTAMP_KEY$customerId');
      } else {
        // Clear all order_shared_common history caches
        AppLogger.logInfo('$TAG: Clearing all order_shared_common history caches');
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith(ORDER_HISTORY_DATA_KEY) || key.startsWith(CACHE_TIMESTAMP_KEY)) {
            await prefs.remove(key);
          }
        }
      }
      AppLogger.logInfo('$TAG: Order history cache cleared ${customerId != null ? 'for customer: $customerId' : 'for all customers'}');
    } catch (e) {
      AppLogger.logError('$TAG: Error clearing order_shared_common history cache: $e');
    }
  }

  // Helper method to convert OrderHistory to JSON map
  static Map<String, dynamic> _convertOrderToJson(OrderHistory order) {
    return {
      'orderId': order.orderId,
      'documentNo': order.documentNo,
      'orderDate': order.orderDate,
      'status': order.status,
      'paymentMethodId': order.paymentMethodId,
      'storeName': order.storeName,
      'totalAmount': order.totalAmount,
      'items': order.items.map((item) => {
        'productId': item.productId,
        'productName': item.productName,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
        'addons': item.addons.map((addon) => {
          'addonId': addon.addonId,
          'name': addon.name,
          'price': addon.price,
        }).toList(),
      }).toList(),
    };
  }

  // Helper method to convert JSON map to OrderHistory
  static OrderHistory _convertJsonToOrder(Map<String, dynamic> json) {
    return OrderHistory(
      orderId: json['orderId'] ?? '',
      documentNo: json['documentNo'] ?? '',
      orderDate: json['orderDate'] ?? '',
      status: json['status'] ?? '',
      paymentMethodId: json['paymentMethodId'] ?? '',
      storeName: json['storeName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderLineItem.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}