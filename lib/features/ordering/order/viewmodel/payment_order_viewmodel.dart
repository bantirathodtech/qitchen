// lib/features/order/viewmodel/payment_order_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../../common/log/loggers.dart';
import '../data/models/payment_order.dart';
import '../data/repositories/order_exception.dart';
import '../data/repositories/payment_order_repository.dart';
import '../provider/payment_order_state.dart';

class PaymentOrderViewModel extends ChangeNotifier {
  static const String TAG = '[PaymentOrderViewModel]';
  final PaymentOrderRepository _repository;
  final PaymentOrderState _state;

  PaymentOrderViewModel({
    required PaymentOrderRepository repository,
    required PaymentOrderState state,
  })  : _repository = repository,
        _state = state;

  PaymentOrder? get order => _state.currentOrder;

  Future<bool> createOrder({
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
      AppLogger.logInfo('Creating payment order: $documentNo', tag: TAG);
      _state.setLoading(true);
      _state.resetError();

      // Validate line items
      if (lineItems.isEmpty) {
        throw OrderException('Order must contain at least one item');
      }

      final response = await _repository.createOrder(
        documentNo: documentNo,
        cSBunitID: cSBunitID,
        dateOrdered: dateOrdered,
        discAmount: discAmount,
        grosstotal: grosstotal,
        taxamt: taxamt,
        mobileNo: mobileNo,
        finPaymentmethodId: finPaymentmethodId,
        isTaxIncluded: isTaxIncluded,
        metaData: metaData,
        lineItems: lineItems,
      );

      if (response.isSuccess) {
        // Update the state with the created order
        _state.setOrder(PaymentOrder(
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
        ));

        AppLogger.logInfo('Order created successfully: ${response.message}',
            tag: TAG);
        return true;
      } else {
        throw Exception('Failed to create payment order: ${response.message}');
      }
    } catch (e) {
      AppLogger.logError('Failed to create order: $e', tag: TAG);
      _state.setError(e.toString());
      return false;
    } finally {
      _state.setLoading(false);
    }
  }
  void clearPayment() {
    // order = null;
    notifyListeners();
  }
}
