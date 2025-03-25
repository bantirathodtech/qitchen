# Example Flow for Service Operations

This document outlines a reusable pattern for service operations (POST, PUT, GET) in Flutter/Dart, using a single model (`Order`) directly without creating additional models in the service layer. Below is the sample code and flow for each operation, which you can apply to any service.

## Sample Code

### `lib/features/order/data/models/order.dart`

```dart
/// A generic order model for demonstration purposes.
class Order {
  final String id;
  final String name;
  final double amount;

  Order({
    required this.id,
    required this.name,
    required this.amount,
  });

  /// Converts the Order object to JSON for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };

  /// Creates an Order object from JSON response data.
  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

/// A generic response model for API operations.
class OrderResponse {
  final String message;
  final bool success;

  OrderResponse({
    required this.message,
    required this.success,
  });

  /// Creates an OrderResponse object from JSON response data.
  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
        message: json['message'] as String,
        success: json['success'] as bool? ?? true,
      );
}
```

### `lib/features/order/data/services/order_service.dart`

```dart
import 'dart:convert';
import '../../../../common/log/loggers.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/services/base/api_base_service.dart';
import '../../../../core/services/network_response_handler.dart';
import '../endpoints/api_url_manager.dart';
import '../models/order.dart';

/// Service for interacting with the order API.
///
/// Reuses [Order] and [OrderResponse] directly for all operations.
class OrderService {
  static const String tag = '[OrderService]';
  final ApiBaseService _apiService;

  OrderService({required this._apiService});

  /// Creates an order using the [Order] model (POST).
  Future<OrderResponse> createOrder(Order order) async {
    try {
      AppLogger.logInfo('$tag Creating order');
      AppLogger.logDebug('$tag Order data: ${order.toJson()}');

      final response = await _apiService.sendRestRequest(
        endpoint: AppUrls.orderEndpoint,
        method: 'POST',
        body: order.toJson(),
      );

      final processedResponse = NetworkResponseHandler.processResponse(
        response,
      );

      final orderResponse = OrderResponse.fromJson(processedResponse);
      return orderResponse;
    } catch (e) {
      AppLogger.logError('$tag Failed to create order: $e');
      rethrow;
    }
  }

  /// Updates an existing order using the [Order] model (PUT).
  Future<OrderResponse> updateOrder(Order order) async {
    try {
      AppLogger.logInfo('$tag Updating order: ${order.id}');

      final response = await _apiService.sendRestRequest(
        endpoint: '${AppUrls.orderEndpoint}/${order.id}',
        method: 'PUT',
        body: order.toJson(),
      );

      final processedResponse = NetworkResponseHandler.processResponse(
        response,
      );

      final orderResponse = OrderResponse.fromJson(processedResponse);
      return orderResponse;
    } catch (e) {
      AppLogger.logError('$tag Failed to update order: $e');
      rethrow;
    }
  }

  /// Fetches all orders, reusing [Order] directly (GET).
  Future<List<Order>> getOrders() async {
    try {
      AppLogger.logInfo('$tag Fetching orders');

      final response = await _apiService.sendRestRequest(
        endpoint: '${AppUrls.orderEndpoint}/all',
        method: 'GET',
      );

      final processedResponse = NetworkResponseHandler.processResponse(response);

      final ordersList = List<Map<String, dynamic>>.from(processedResponse['orders']);
      return ordersList.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      AppLogger.logError('$tag Failed to fetch orders: $e');
      rethrow;
    }
  }
}
```

### `lib/core/services/endpoints/api_url_manager.dart`

```dart
class AppUrls {
  static const String orderEndpoint = '/api/orders';
}
```

## Flow for Service Operations

### Creating an Order (POST)
- **Input:** `Order` object
- **Request:**
  ```json
  {
    "id": "1",
    "name": "Sample Order",
    "amount": 100.0
  }
  ```
- **Response:**
  ```json
  {
    "message": "Order created",
    "success": true
  }
  ```
- **Parsed Into:** `OrderResponse(message: 'Order created', success: true)`

### Updating an Order (PUT)
- **Input:** Updated `Order` object
- **Request:**
  ```json
  {
    "id": "1",
    "name": "Updated Order",
    "amount": 150.0
  }
  ```
- **Response:**
  ```json
  {
    "message": "Order updated",
    "success": true
  }
  ```
- **Parsed Into:** `OrderResponse(message: 'Order updated', success: true)`

### Fetching Orders (GET)
- **Request:** Fetch all orders
- **Response:**
  ```json
  {
    "orders": [
      {"id": "1", "name": "Order 1", "amount": 100.0},
      {"id": "2", "name": "Order 2", "amount": 200.0}
    ]
  }
  ```
- **Parsed Into:** `List<Order>`

## Key Points
- **Reuse Model:** Use the same `Order` model for input (POST/PUT) and output (GET) with `toJson()` and `fromJson()`.
- **Response Model:** Use `OrderResponse` for POST/PUT responses to handle API metadata.
- **No Redundancy:** Avoid creating new models in the service layer.

## Usage
To apply this pattern to any service:
1. Define your model (e.g., `Order`) with `toJson()` and `fromJson()`.
2. Define a response model (e.g., `OrderResponse`) for operation results.
3. Implement service methods (e.g., `OrderService`) following the above flow.

