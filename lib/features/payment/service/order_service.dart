// // lib/features/order/service/order_service.dart
//
// import '../../../common/log/loggers.dart';
// import '../../../core/api/api_base_service.dart';
// import '../../../core/api/api_url_manager.dart';
// import '../data/model/order_data_model.dart';
//
// class OrderService {
//   static const String TAG = '[OrderService]';
//   final ApiBaseService _apiBaseService;
//
//   OrderService({required ApiBaseService apiBaseService})
//       : _apiBaseService = apiBaseService;
//
//   Future<Map<String, dynamic>> createOrder(OrderDataModel orderData) async {
//     try {
//       AppLogger.logInfo('$TAG Creating order');
//       AppLogger.logDebug('$TAG documentno: ${orderData.documentno}');
//       AppLogger.logDebug('$TAG cSBunitID: ${orderData.cSBunitID}');
//       AppLogger.logDebug('$TAG MobileNo: ${orderData.mobileNo}');
//       AppLogger.logDebug('$TAG Amount: ${orderData.grosstotal}');
//       AppLogger.logDebug(
//           '$TAG Order request has ${orderData.line.length} line items');
//       AppLogger.logDebug('$TAG Full request body: ${orderData.toJson()}');
//
//       final response = await _apiBaseService.sendRestRequest(
//         method: 'POST',
//         body: orderData.toJson(),
//         endpoint: AppUrls.createOrder,
//       );
//
//       if (response == null) {
//         AppLogger.logError('$TAG No response from server');
//         throw Exception('No response received from server');
//       }
//
//       AppLogger.logInfo('$TAG Order created successfully');
//       AppLogger.logDebug('$TAG Response: $response');
//
//       return response as Map<String, dynamic>;
//     } catch (e) {
//       AppLogger.logError('$TAG Create order error: $e');
//       throw Exception('Failed to create order: $e');
//     }
//   }
// }
