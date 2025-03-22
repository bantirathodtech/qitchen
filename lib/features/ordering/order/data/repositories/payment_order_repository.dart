import '../../../../../common/log/loggers.dart';
import '../../services/payment_api_service.dart';
import '../models/order_response.dart';
import '../models/payment_order.dart';
import 'order_exception.dart';

class PaymentOrderRepository {
  static const String TAG = '[PaymentOrderRepository]';
  final PaymentApiService _apiService;

  PaymentOrderRepository({
    required PaymentApiService apiService,
  }) : _apiService = apiService;

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
      AppLogger.logInfo('$TAG Creating payment order: $documentNo');

      final order = PaymentOrder(
        order: Order(
          documentno: documentNo,
          cSBunitID: cSBunitID, // Primary BU for the order
          dateOrdered: dateOrdered,
          discAmount: discAmount,
          grosstotal: grosstotal,
          taxamt: taxamt,
          mobileNo: mobileNo,
          finPaymentmethodId: finPaymentmethodId,
          isTaxIncluded: isTaxIncluded,
          metaData: metaData,
          line: lineItems, // Includes items with their own cSBunitID
        ),
      );

      AppLogger.logDebug('$TAG Order details: ${order.toJson()}');
      final response = await _apiService.createOrder(order);

      if (response.isSuccess) {
        return response;
      } else {
        throw OrderException(response.message);
      }
    } catch (e) {
      AppLogger.logError('$TAG Failed to create order: $e');
      throw OrderException('Failed to create payment order: $e');
    }
  }
}