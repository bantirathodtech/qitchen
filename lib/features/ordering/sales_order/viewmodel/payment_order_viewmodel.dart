// lib/features/order_shared_common/viewmodel/payment_order_viewmodel.dart
import 'package:flutter/foundation.dart';

import '../../../../common/log/loggers.dart';
import '../../../../core/services/errors/app_exception.dart';
import '../model/payment_order.dart';
import '../provider/payment_order_state.dart';
import '../repository/payment_order_repository.dart';

/// ViewModel for managing payment order operations and state.
///
/// This class interacts with the [PaymentOrderRepository] to perform operations
/// and updates the [PaymentOrderState] to reflect changes for the UI.
class PaymentOrderViewModel extends ChangeNotifier {
  static const String tag = '[PaymentOrderViewModel]';
  final PaymentOrderRepository _repository;
  final PaymentOrderState _state;

  /// Initializes the ViewModel with a repository and state.
  PaymentOrderViewModel({
    required PaymentOrderRepository repository,
    required PaymentOrderState state,
  })  : _repository = repository,
        _state = state;

  /// Gets the current payment order from the state, or null if none exists.
  PaymentOrder? get order => _state.currentOrder;

  /// Creates a new payment order and updates the state based on the result.
  ///
  /// Returns `true` if the order is created successfully, `false` otherwise.
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
      // Log the start of the operation
      AppLogger.logInfo('Creating payment order: $documentNo', tag: tag);
      _state.setLoading(true);
      _state.resetError();

      // Validate input data
      if (lineItems.isEmpty) {
        throw AppException(
          'Order must contain at least one item',
          code: 'VALIDATION',
        );
      }

      // Call repository to create the order
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

      // Check response and update state
      if (response.isSuccess) {
        final newOrder = PaymentOrder(
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
        _state.setOrder(newOrder);
        AppLogger.logInfo('Order created successfully: ${response.message}',
            tag: tag);
        return true;
      } else {
        throw AppException(
          'Failed to create payment order: ${response.message}',
          code: 'CREATION_FAILED',
        );
      }
    } catch (e) {
      // Handle errors and update state
      AppLogger.logError('Failed to create order: $e', tag: tag);
      _state.setError(e.toString());
      return false;
    } finally {
      // Reset loading state and notify UI
      _state.setLoading(false);
      notifyListeners();
    }
  }

  /// Sets a display order without making an API call.
  void setDisplayOrder(Order order) {
    AppLogger.logInfo('Setting display order: ${order.documentno}', tag: tag);
    _state.setOrder(PaymentOrder(order: order));
    notifyListeners(); // Notify UI of the change
  }

  /// Clears the current payment order from the state.
  void clearPayment() {
    AppLogger.logInfo('Clearing payment order', tag: tag);
    _state.setOrder(null); // Clears the order by setting it to null
    notifyListeners(); // Notify UI of the change
  }
}

// import 'package:flutter/foundation.dart';
// import '../../../../common/log/loggers.dart';
// import '../model/payment_order.dart';
// import '../repository/payment_order_repository.dart';
// import '../provider/payment_order_state.dart';
//
// class PaymentOrderViewModel extends ChangeNotifier {
//   static const String TAG = '[PaymentOrderViewModel]';
//   final PaymentOrderRepository _repository;
//   final PaymentOrderState _state;
//
//   PaymentOrderViewModel({
//     required PaymentOrderRepository repository,
//     required PaymentOrderState state,
//   })  : _repository = repository,
//         _state = state;
//
//   PaymentOrder? get order => _state.currentOrder;
//
//   Future<bool> createOrder({
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
//       AppLogger.logInfo('Creating payment order_shared_common: $documentNo', tag: TAG);
//       _state.setLoading(true);
//       _state.resetError();
//
//       // Validate line items
//       if (lineItems.isEmpty) {
//         throw OrderException('Order must contain at least one item');
//       }
//
//       final response = await _repository.createOrder(
//         documentNo: documentNo,
//         cSBunitID: cSBunitID,
//         dateOrdered: dateOrdered,
//         discAmount: discAmount,
//         grosstotal: grosstotal,
//         taxamt: taxamt,
//         mobileNo: mobileNo,
//         finPaymentmethodId: finPaymentmethodId,
//         isTaxIncluded: isTaxIncluded,
//         metaData: metaData,
//         lineItems: lineItems,
//       );
//
//       if (response.isSuccess) {
//         // Update the state with the created order_shared_common
//         _state.setOrder(PaymentOrder(
//           order: Order(
//             documentno: documentNo,
//             cSBunitID: cSBunitID,
//             dateOrdered: dateOrdered,
//             discAmount: discAmount,
//             grosstotal: grosstotal,
//             taxamt: taxamt,
//             mobileNo: mobileNo,
//             finPaymentmethodId: finPaymentmethodId,
//             isTaxIncluded: isTaxIncluded,
//             metaData: metaData,
//             line: lineItems,
//           ),
//         ));
//
//         AppLogger.logInfo('Order created successfully: ${response.message}',
//             tag: TAG);
//         return true;
//       } else {
//         throw Exception('Failed to create payment order_shared_common: ${response.message}');
//       }
//     } catch (e) {
//       AppLogger.logError('Failed to create order_shared_common: $e', tag: TAG);
//       _state.setError(e.toString());
//       return false;
//     } finally {
//       _state.setLoading(false);
//     }
//   }
//
//   // Add this method to your PaymentOrderViewModel class
//   void setDisplayOrder(Order order) {
//     AppLogger.logInfo('Setting display order_shared_common: ${order.documentno}', tag: TAG);
//
//     // Just set the order_shared_common in the state without calling repository methods
//     _state.setOrder(PaymentOrder(order: order));
//
//     // Notify listeners so UI can update
//     notifyListeners();
//   }
//
//   void clearPayment() {
//     // order_shared_common = null;
//     notifyListeners();
//   }
// }
