// lib/common/log/order_history_logger.dart

import '../../../../common/log/loggers.dart';

/// Specialized logging utility for order_shared_common history debugging
/// Can be used to filter logs specifically for order_shared_common history issues
class OrderHistoryLogger {
  static const String _PREFIX = '[ORDER_HISTORY]';

  /// Log order_shared_common history related information
  static void log(String message) {
    AppLogger.logInfo('$_PREFIX $message');
  }

  /// Log order_shared_common history related errors
  static void error(String message) {
    AppLogger.logError('$_PREFIX $message');
  }

  /// Log details about an API response
  static void logApiResponse(dynamic response) {
    try {
      if (response == null) {
        error('API returned null response');
        return;
      }

      // Extract relevant information from the response
      final bool hasData = response.containsKey('data');
      final bool hasOrders = hasData && response['data'].containsKey('getMyOrders');
      final int orderCount = hasOrders ? (response['data']['getMyOrders'] as List).length : 0;

      log('API Response: hasData=$hasData, hasOrders=$hasOrders, orderCount=$orderCount');

      // Log first few order_shared_common IDs to help identify duplicates
      if (orderCount > 0) {
        final orders = response['data']['getMyOrders'] as List;
        final Set<String> orderIds = {};
        final List<String> duplicateIds = [];

        for (var i = 0; i < orders.length && i < 10; i++) {
          final order = orders[i];
          final String orderId = order['sOrderID'] ?? 'unknown';

          if (orderIds.contains(orderId)) {
            duplicateIds.add(orderId);
          } else {
            orderIds.add(orderId);
          }
        }

        if (duplicateIds.isNotEmpty) {
          log('Found duplicate order_shared_common IDs: ${duplicateIds.join(', ')}');
        }
      }
    } catch (e) {
      error('Error logging API response: $e');
    }
  }

  /// Log a list of orders and check for duplicates
  static void logOrders(List<dynamic> orders, {String source = 'unknown'}) {
    try {
      log('Orders from $source: count=${orders.length}');

      // Check for duplicates
      final Map<String, int> orderIdCounts = {};
      for (var order in orders) {
        final String orderId = order['orderId'] ?? order['sOrderID'] ?? 'unknown';
        orderIdCounts[orderId] = (orderIdCounts[orderId] ?? 0) + 1;
      }

      // Log duplicate entries
      final duplicates = orderIdCounts.entries.where((entry) => entry.value > 1).toList();
      if (duplicates.isNotEmpty) {
        log('Found ${duplicates.length} duplicate order_shared_common IDs:');
        for (var entry in duplicates) {
          log('  - ${entry.key}: appears ${entry.value} times');
        }
      } else {
        log('No duplicate orders found');
      }
    } catch (e) {
      error('Error logging orders: $e');
    }
  }

  /// Add debugging info to help track state updates
  static void logStateUpdate(String action, int orderCount) {
    log('State update: $action - orderCount=$orderCount');
  }
}