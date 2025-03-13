// // lib/features/order/viewmodel/order_viewmodel.dart
// import 'package:flutter/foundation.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../data/model/order_data_model.dart';
// import '../../data/provider/order_provider.dart';
// import '../../data/repository/order_repository.dart';
//
// class OrderViewModel extends ChangeNotifier {
//   static const String TAG = '[OrderViewModel]';
//   final OrderRepository _repository;
//   final OrderProvider _orderProvider;
//
//   OrderViewModel({
//     required OrderRepository repository,
//     required OrderProvider orderProvider,
//   })  : _repository = repository,
//         _orderProvider = orderProvider;
//
//   Future<bool> createOrder({
//     required String documentNo,
//     required String businessUnitId,
//     required String paymentMethodId,
//     required String mobileNo,
//     required List<OrderLine> orderLines,
//     required int totalAmount,
//     required int taxAmount,
//   }) async {
//     AppLogger.logDebug(
//         '$TAG Creating order with ${orderLines.length} line items');
//     bool success = false;
//     _orderProvider.setError('');
//
//     try {
//       _orderProvider.setLoading(true);
//
//       final orderData = OrderDataModel(
//         documentno: documentNo,
//         cSBunitID: businessUnitId,
//         dateOrdered: DateTime.now().toString().substring(0, 19),
//         discAmount: 0.0,
//         grosstotal: totalAmount,
//         taxamt: taxAmount,
//         mobileNo: mobileNo,
//         finPaymentmethodId: paymentMethodId,
//         isTaxIncluded: 'N',
//         metaData: [MetaData(key: '_dokan_vendor_id', value: '2')],
//         line: orderLines,
//       );
//
//       final response = await _repository.createOrder(orderData);
//
//       if (response['status'] == '200') {
//         _orderProvider.setOrder(orderData);
//         success = true;
//         AppLogger.logInfo(
//             '$TAG Order created successfully: ${response['recordId']}');
//       } else {
//         throw Exception(response['message'] ?? 'Failed to create order');
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Error creating order: $e');
//       _orderProvider.setError(e.toString());
//       success = false;
//     } finally {
//       _orderProvider.setLoading(false);
//     }
//
//     return success;
//   }
// }
