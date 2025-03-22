// // lib/features/order/provider/order_provider.dart
// import 'package:flutter/foundation.dart';
//
// import '../model/order_data_model.dart';
//
// class OrderProvider extends ChangeNotifier {
//   OrderDataModel? _currentOrder;
//   bool _isLoading = false;
//   String _error = '';
//
//   OrderDataModel? get currentOrder => _currentOrder;
//   bool get isLoading => _isLoading;
//   String get error => _error;
//
//   void setOrder(OrderDataModel order) {
//     _currentOrder = order;
//     notifyListeners();
//   }
//
//   void setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
//
//   void setError(String errorMessage) {
//     _error = errorMessage;
//     notifyListeners();
//   }
//
//   void resetError() {
//     _error = '';
//     notifyListeners();
//   }
// }
