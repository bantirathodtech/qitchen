import '../../../../common/log/loggers.dart';
import '../../../../core/services/errors/app_exception.dart';
import '../model/order_response.dart';
import '../model/payment_order.dart';
import '../service/payment_api_service.dart';

class PaymentOrderRepository {
  static const String tag = '[PaymentOrderRepository]';
  final PaymentApiService _apiService;

  // Step 1: Initialize repository with API service
  PaymentOrderRepository({
    required PaymentApiService apiService,
  }) : _apiService = apiService;

  // Step 2: Create a payment order
  Future<OrderResponse> createOrder({
    required String documentNo,
    required String cSBunitID,
    required String dateOrdered,
    required num discAmount,
    required num grosstotal,
    required num taxamt,
    required String mobileNo,
    required String finPaymentmethodId,
    required String isTaxIncluded,
    required List<OrderMetadata> metaData,
    required List<PaymentOrderItem> lineItems,
  }) async {
    try {
      // Step 2.1: Log the operation start
      AppLogger.logInfo('$tag Creating payment order: $documentNo');

      // Step 2.2: Create PaymentOrder object
      final order = PaymentOrder(
        order: Order(
          documentno: documentNo,
          cSBunitID: cSBunitID,
          dateOrdered: dateOrdered,
          discAmount: discAmount,
          grosstotal: grosstotal,
          taxamt: taxamt,
          mobileNo: mobileNo,
          finPaymentmethodId: finPaymentmethodId,
          isTaxIncluded: isTaxIncluded,
          metaData: metaData,
          line: lineItems,
        ),
      );

      // Step 2.3: Log order details for debugging
      AppLogger.logDebug('$tag Order details: ${order.toJson()}');

      // Step 2.4: Call API service to create order
      final response = await _apiService.createOrder(order);

      // Step 2.5: Validate response
      if (response.isSuccess) {
        AppLogger.logInfo('$tag Order created: ${response.message}');
        return response;
      } else {
        throw AppException(
          response.message,
          code: 'API_ERROR',
        );
      }
    } catch (e) {
      // Step 2.6: Handle and log errors
      AppLogger.logError('$tag Failed to create order: $e');
      throw AppException.from(e, message: 'Failed to create payment order: $e');
    }
  }
}

// import '../../../../common/log/loggers.dart';
// import '../service/payment_api_service.dart';
// import '../model/order_response.dart';
// import '../model/payment_order.dart';
//
// class PaymentOrderRepository {
//   static const String TAG = '[PaymentOrderRepository]';
//   final PaymentApiService _apiService;
//
//   PaymentOrderRepository({
//     required PaymentApiService apiService,
//   }) : _apiService = apiService;
//
//   Future<OrderResponse> createOrder({
//     required String documentNo,
//     required String cSBunitID,
//     required String dateOrdered,
//     required num discAmount,
//     required num grosstotal,
//     required num taxamt,
//     required String mobileNo,
//     required String finPaymentmethodId,
//     required String isTaxIncluded,
//     required List<OrderMetadata> metaData,
//     required List<PaymentOrderItem> lineItems,
//   }) async {
//     try {
//       AppLogger.logInfo('$TAG Creating payment order_shared_common: $documentNo');
//
//       final order = PaymentOrder(
//         order: Order(
//           documentno: documentNo,
//           cSBunitID: cSBunitID, // Primary BU for the order_shared_common
//           dateOrdered: dateOrdered,
//           discAmount: discAmount,
//           grosstotal: grosstotal,
//           taxamt: taxamt,
//           mobileNo: mobileNo,
//           finPaymentmethodId: finPaymentmethodId,
//           isTaxIncluded: isTaxIncluded,
//           metaData: metaData,
//           line: lineItems, // Includes items with their own cSBunitID
//         ),
//       );
//
//       AppLogger.logDebug('$TAG Order details: ${order.toJson()}');
//       final response = await _apiService.createOrder(order);
//
//       if (response.isSuccess) {
//         return response;
//       } else {
//         throw OrderException(response.message);
//       }
//     } catch (e) {
//       AppLogger.logError('$TAG Failed to create order_shared_common: $e');
//       throw OrderException('Failed to create payment order_shared_common: $e');
//     }
//   }
// }