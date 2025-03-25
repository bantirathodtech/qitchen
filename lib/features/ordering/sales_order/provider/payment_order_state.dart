import 'package:flutter/foundation.dart';

import '../../../../common/log/loggers.dart';
import '../model/payment_order.dart';

/// Manages the state of a payment order, including the current order, loading status, and errors.
///
/// This class extends [ChangeNotifier] to provide reactive updates to the UI when the state changes.
class PaymentOrderState extends ChangeNotifier {
  static const String tag = '[PaymentOrderState]';

  /// The current payment order, which can be null if no order is active.
  PaymentOrder? _currentOrder;

  /// Indicates whether an operation (e.g., creating an order) is in progress.
  bool _isLoading = false;

  /// Stores an error message if an operation fails, or null if there’s no error.
  String? _errorMessage;

  /// Gets the current payment order, or null if none exists.
  PaymentOrder? get currentOrder => _currentOrder;

  /// Gets whether an operation is currently loading.
  bool get isLoading => _isLoading;

  /// Checks if an error exists.
  bool get hasError => _errorMessage != null;

  /// Gets the error message, returning an empty string if no error exists.
  String get errorMessage => _errorMessage ?? '';

  /// Sets the current payment order (or clears it by setting to null).
  ///
  /// [order] can be a [PaymentOrder] or null to indicate no active order.
  void setOrder(PaymentOrder? order) {
    _currentOrder = order;
    AppLogger.logInfo(
      'Order updated: ${order?.order.documentno ?? "cleared"}',
      tag: tag,
    );
    notifyListeners(); // Notify UI of the change
  }

  /// Sets the loading state.
  ///
  /// [value] indicates whether loading is active.
  void setLoading(bool value) {
    _isLoading = value;
    AppLogger.logDebug('Loading state changed to: $value', tag: tag);
    notifyListeners(); // Notify UI of the change
  }

  /// Sets an error message when an operation fails.
  ///
  /// [message] describes the error.
  void setError(String message) {
    _errorMessage = message;
    AppLogger.logError('Error set: $message', tag: tag);
    notifyListeners(); // Notify UI of the change
  }

  /// Clears any existing error message.
  void resetError() {
    _errorMessage = null;
    AppLogger.logDebug('Error cleared', tag: tag);
    notifyListeners(); // Notify UI of the change
  }

  /// Resets the entire state to its initial values.
  void reset() {
    _currentOrder = null;
    _isLoading = false;
    _errorMessage = null;
    AppLogger.logInfo('State fully reset', tag: tag);
    notifyListeners(); // Notify UI of the change
  }
}

// // lib/features/order_shared_common/provider/payment_order_state.dart
//
// import 'package:flutter/foundation.dart';
// import '../../../../common/log/loggers.dart';
// import '../model/payment_order.dart';
//
// class PaymentOrderState extends ChangeNotifier {
//   static const String TAG = '[PaymentOrderState]';
//   PaymentOrder? _currentOrder;
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   PaymentOrder? get currentOrder => _currentOrder;
//   bool get isLoading => _isLoading;
//   bool get hasError => _errorMessage != null;
//   String get errorMessage => _errorMessage ?? '';
//
//   void setOrder(PaymentOrder order) {
//     _currentOrder = order;
//     AppLogger.logInfo('Order updated', tag: TAG);
//     notifyListeners();
//   }
//
//   void setLoading(bool value) {
//     _isLoading = value;
//     AppLogger.logDebug('Loading state: $value', tag: TAG);
//     notifyListeners();
//   }
//
//   void setError(String message) {
//     _errorMessage = message;
//     AppLogger.logError('Error set: $message', tag: TAG);
//     notifyListeners();
//   }
//
//   void resetError() {
//     _errorMessage = null;
//     AppLogger.logDebug('Error reset', tag: TAG);
//     notifyListeners();
//   }
//
//   void reset() {
//     _currentOrder = null;
//     _isLoading = false;
//     _errorMessage = null;
//     AppLogger.logInfo('State reset', tag: TAG);
//     notifyListeners();
//   }
// }
