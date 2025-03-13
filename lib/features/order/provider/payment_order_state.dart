// lib/features/order/provider/payment_order_state.dart

import 'package:flutter/foundation.dart';

import '../../../common/log/loggers.dart';
import '../data/models/payment_order.dart';

class PaymentOrderState extends ChangeNotifier {
  static const String TAG = '[PaymentOrderState]';
  PaymentOrder? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;

  PaymentOrder? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String get errorMessage => _errorMessage ?? '';

  void setOrder(PaymentOrder order) {
    _currentOrder = order;
    AppLogger.logInfo('Order updated', tag: TAG);
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
    AppLogger.logInfo('State reset', tag: TAG);
    notifyListeners();
  }
}
