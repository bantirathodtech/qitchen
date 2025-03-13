// // lib/features/order/repository/redis_order_repository.dart
// import '../../service/redis_order_service.dart';
// import '../model/redis_order_model.dart';
//
// class RedisOrderRepository {
//   final RedisOrderService _redisOrderService;
//
//   RedisOrderRepository(this._redisOrderService);
//
//   Future<Map<String, dynamic>> createRedisOrder(
//       RedisOrderModel orderData) async {
//     try {
//       return await _redisOrderService.createRedisOrder(orderData);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
