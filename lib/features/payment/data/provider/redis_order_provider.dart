// // lib/features/order/provider/redis_order_provider.dart
// import 'package:flutter/foundation.dart';
//
// import '../model/redis_order_model.dart';
//
// class RedisOrderProvider extends ChangeNotifier {
//   RedisOrderModel? _currentRedisOrder;
//   bool _isLoading = false;
//   String _error = '';
//
//   RedisOrderModel? get currentRedisOrder => _currentRedisOrder;
//   bool get isLoading => _isLoading;
//   String get error => _error;
//
//   void setRedisOrder(RedisOrderModel order) {
//     _currentRedisOrder = order;
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
// }
