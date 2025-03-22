// lib/features/history/states/order_history_state.dart

// Define possible states for order history
import 'package:flutter/cupertino.dart';

import '../model/order_history_model.dart';

enum OrderHistoryStatus {
  initial, // Initial state before any loading
  loading, // Loading data
  success, // Successfully loaded data
  error // Error occurred
}

// State class to manage order history data
class OrderHistoryState {
  final OrderHistoryStatus status; // Current state status
  final List<OrderHistory> orders; // List of orders
  final String? errorMessage; // Error message if any
  final DateTime? lastUpdated; // When the data was last updated

  // Constructor with default values
  const OrderHistoryState({
    this.status = OrderHistoryStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.lastUpdated,
  });

  // Create a copy of state with some changes
  OrderHistoryState copyWith({
    OrderHistoryStatus? status,
    List<OrderHistory>? orders,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return OrderHistoryState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper getters for common state checks
  bool get isLoading => status == OrderHistoryStatus.loading;
  bool get hasError => status == OrderHistoryStatus.error;
  bool get hasOrders => orders.isNotEmpty;
}

// State notifier to manage state changes
class OrderHistoryStateNotifier extends ChangeNotifier {
  OrderHistoryState _state = const OrderHistoryState();

  // Getter for current state
  OrderHistoryState get state => _state;

  // Update state to loading
  void setLoading() {
    _state = _state.copyWith(
      status: OrderHistoryStatus.loading,
      errorMessage: null,
    );
    notifyListeners();
  }

  // Update state with new orders
  void setOrders(List<OrderHistory> orders) {
    _state = _state.copyWith(
      status: OrderHistoryStatus.success,
      orders: orders,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  // Update state with error
  void setError(String message) {
    _state = _state.copyWith(
      status: OrderHistoryStatus.error,
      errorMessage: message,
    );
    notifyListeners();
  }

  // Reset state to initial
  void reset() {
    _state = const OrderHistoryState();
    notifyListeners();
  }
}
