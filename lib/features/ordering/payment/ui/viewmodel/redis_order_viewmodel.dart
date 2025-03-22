// // lib/features/order/viewmodel/redis_order_viewmodel.dart
// import 'package:flutter/cupertino.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../data/model/redis_order_model.dart';
// import '../../data/provider/redis_order_provider.dart';
// import '../../data/repository/redis_order_repository.dart';
//
// class RedisOrderViewModel extends ChangeNotifier {
//   static const String TAG = '[RedisOrderViewModel]';
//   final RedisOrderRepository _repository;
//   final RedisOrderProvider _redisOrderProvider;
//
//   RedisOrderViewModel({
//     required RedisOrderRepository repository,
//     required RedisOrderProvider redisOrderProvider,
//   })  : _repository = repository,
//         _redisOrderProvider = redisOrderProvider;
//
//   Future<bool> createRedisOrder({
//     required String customerId,
//     required String documentno,
//     required String businessUnitId,
//     required String customerName,
//     required List<RedisOrderLine> orderLines,
//   }) async {
//     bool success = false;
//     _redisOrderProvider.setError('');
//
//     try {
//       _redisOrderProvider.setLoading(true);
//
//       final redisOrderData = RedisOrderModel(
//         customerId: customerId,
//         documentno: documentno,
//         cSBunitID: businessUnitId,
//         customerName: customerName,
//         dateOrdered: DateTime.now().toString().substring(0, 19),
//         status: 'pending',
//         line: orderLines,
//       );
//
//       final response = await _repository.createRedisOrder(redisOrderData);
//
//       if (response['message']?.contains('successfully') == true) {
//         _redisOrderProvider.setRedisOrder(redisOrderData);
//         success = true;
//         AppLogger.logInfo('$TAG Redis order created successfully');
//       } else {
//         throw Exception(response['message'] ?? 'Failed to create Redis order');
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error creating Redis order: $e');
//       _redisOrderProvider.setError(e.toString());
//       success = false;
//     } finally {
//       _redisOrderProvider.setLoading(false);
//     }
//
//     return success;
//   }
// }
