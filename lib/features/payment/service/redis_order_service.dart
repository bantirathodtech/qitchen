// // lib/features/order/service/redis_order_service.dart
// import '../../../common/log/loggers.dart';
// import '../../../core/api/api_base_service.dart';
// import '../../../core/api/api_url_manager.dart';
// import '../data/model/redis_order_model.dart';
//
// class RedisOrderService {
//   static const String TAG = '[RedisOrderService]';
//   final ApiBaseService _apiBaseService;
//
//   RedisOrderService({required ApiBaseService apiBaseService})
//       : _apiBaseService = apiBaseService;
//
//   Future<Map<String, dynamic>> createRedisOrder(
//       RedisOrderModel orderData) async {
//     try {
//       AppLogger.logInfo('$TAG Creating Redis order');
//       AppLogger.logDebug('$TAG documentno: ${orderData.documentno}');
//       AppLogger.logDebug('$TAG customerId: ${orderData.customerId}');
//
//       final response = await _apiBaseService.sendRestRequest(
//         method: 'POST',
//         body: orderData.toJson(),
//         endpoint: AppUrls.redisOrder,
//       );
//
//       if (response == null) {
//         AppLogger.logError('$TAG No response from server');
//         throw Exception('No response received from server');
//       }
//
//       AppLogger.logInfo('$TAG Redis order created successfully');
//       AppLogger.logDebug('$TAG Response: $response');
//
//       return response as Map<String, dynamic>;
//     } catch (e) {
//       AppLogger.logError('$TAG Create Redis order error: $e');
//       throw Exception('Failed to create Redis order: $e');
//     }
//   }
// }
