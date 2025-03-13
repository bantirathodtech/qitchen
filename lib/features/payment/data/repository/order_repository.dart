// // lib/features/order/repository/order_repository.dart
// import '../../service/order_service.dart';
// import '../model/order_data_model.dart';
//
// class OrderRepository {
//   final OrderService _orderService;
//
//   OrderRepository(this._orderService);
//
//   Future<Map<String, dynamic>> createOrder(OrderDataModel orderData) async {
//     try {
//       return await _orderService.createOrder(orderData);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
