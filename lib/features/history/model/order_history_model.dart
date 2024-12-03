// lib/features/history/models/order_history_model.dart

// Main class to handle the entire API response structure
class OrderHistoryResponse {
  final OrderHistoryData data; // Wrapper for API data

  OrderHistoryResponse({required this.data});

  // Convert the entire API response to our model
  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      data: OrderHistoryData.fromJson(json['data']),
    );
  }
}

// Handles the 'data' level of the API response
class OrderHistoryData {
  final List<OrderHistory> orders; // List of orders

  OrderHistoryData({required this.orders});

  factory OrderHistoryData.fromJson(Map<String, dynamic> json) {
    return OrderHistoryData(
      orders: (json['getMyOrders'] as List<dynamic>)
          .map((order) => OrderHistory.fromJson(order))
          .toList(),
    );
  }
}

// Model for individual order details
class OrderHistory {
  final String orderId; // Unique identifier for the order
  final String documentNo; // Display order number (e.g., SO/WMS557)
  final String orderDate; // Date of order placement
  final String status; // Order status (e.g., CO for Completed)
  final String paymentMethodId; // Payment method identifier
  final String storeName; // Name of the store/outlet
  final double totalAmount; // Total order amount
  final List<OrderLineItem> items; // List of items in the order

  OrderHistory({
    required this.orderId,
    required this.documentNo,
    required this.orderDate,
    required this.status,
    required this.paymentMethodId,
    required this.storeName,
    required this.totalAmount,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      orderId: json['sOrderID'] ?? '',
      documentNo: json['documentno'] ?? '',
      orderDate: json['dateordered'] ?? '',
      status: json['docstatus'] ?? '',
      paymentMethodId: json['finPaymentmethodId'] ?? '',
      storeName: json['storeName'] ?? '',
      totalAmount: (json['grosstotal'] ?? 0).toDouble(),
      items: (json['line'] as List<dynamic>?)
              ?.map((item) => OrderLineItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

// Model for items within an order
class OrderLineItem {
  final String productId; // Product identifier (value in API)
  final String productName; // Name of the product
  final int quantity; // Quantity ordered
  final double unitPrice; // Price per unit
  final double totalPrice; // Total price for this line
  final List<OrderAddon> addons; // List of addons/extras for this item

  OrderLineItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addons,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      productId: json['value'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['qty'] ?? 0,
      unitPrice: (json['unitprice'] ?? 0).toDouble(),
      totalPrice: (json['linegross'] ?? 0).toDouble(),
      addons: (json['addons'] as List<dynamic>?)
              ?.map((addon) => OrderAddon.fromJson(addon))
              .toList() ??
          [],
    );
  }
}

// Model for add-ons/extras added to items
class OrderAddon {
  final String addonId; // Unique identifier for the addon
  final String name; // Name of the addon
  final double price; // Price of the addon

  OrderAddon({
    required this.addonId,
    required this.name,
    required this.price,
  });

  factory OrderAddon.fromJson(Map<String, dynamic> json) {
    return OrderAddon(
      addonId: json['addonProductId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
