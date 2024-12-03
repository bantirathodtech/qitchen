// lib/features/order/provider/kitchen_order_state.dart

import 'package:flutter/foundation.dart';

import '../../../common/log/loggers.dart';
import '../data/models/kitchen_order.dart';

class KitchenOrderState extends ChangeNotifier {
  static const String TAG = '[KitchenOrderState]';
  KitchenOrder? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, String> _orderStatuses = {};

  KitchenOrder? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String get errorMessage => _errorMessage ?? '';
  Map<String, String> get orderStatuses => Map.unmodifiable(_orderStatuses);

  void setOrder(KitchenOrder order) {
    _currentOrder = order;
    updateOrderStatus(order.documentno, order.status);
    AppLogger.logInfo('Kitchen order updated', tag: TAG);
    notifyListeners();
  }

  void updateOrderStatus(String documentNo, String status) {
    _orderStatuses[documentNo] = status;
    AppLogger.logInfo('Status updated for order $documentNo: $status',
        tag: TAG);
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    AppLogger.logDebug('Loading state: $value', tag: TAG);
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    AppLogger.logError('Error set: $message', tag: TAG);
    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    AppLogger.logDebug('Error reset', tag: TAG);
    notifyListeners();
  }

  void reset() {
    _currentOrder = null;
    _isLoading = false;
    _errorMessage = null;
    _orderStatuses.clear();
    AppLogger.logInfo('State reset', tag: TAG);
    notifyListeners();
  }
}
