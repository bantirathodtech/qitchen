// // lib/features/order/viewmodel/confirmation_process_viewmodel.dart
//
// import 'package:flutter/foundation.dart';
//
// import '../data/models/kitchen_order.dart';
// import '../data/models/payment_order.dart';
// import '../data/repositories/kitchen_order_repository.dart';
// import '../data/repositories/payment_order_repository.dart';
// import '../provider/kitchen_order_state.dart';
// import '../provider/payment_order_state.dart';
// import '../utils/order_data_transformer.dart';
//
// class ConfirmationProcessViewModel extends ChangeNotifier {
//   final PaymentOrderRepository _paymentRepository;
//   final KitchenOrderRepository _kitchenRepository;
//   final PaymentOrderState _paymentState;
//   final KitchenOrderState _kitchenState;
//   final OrderDataTransformer _transformer;
//
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   ConfirmationProcessViewModel({
//     required PaymentOrderRepository paymentRepository,
//     required KitchenOrderRepository kitchenRepository,
//     required PaymentOrderState paymentState,
//     required KitchenOrderState kitchenState,
//     required OrderDataTransformer transformer,
//   })  : _paymentRepository = paymentRepository,
//         _kitchenRepository = kitchenRepository,
//         _paymentState = paymentState,
//         _kitchenState = kitchenState,
//         _transformer = transformer;
//
//   bool get isLoading => _isLoading;
//   bool get hasError => _errorMessage != null;
//   String get errorMessage => _errorMessage ?? '';
//
//   Future<bool> processOrderConfirmation({
//     required String orderId,
//     required List<OrderItem> items,
//     required double totalAmount,
//     required String restaurantName,
//     required String paymentMethod,
//   }) async {
//     try {
//       _setLoading(true);
//       _clearError();
//
//       // Create payment order
//       final paymentOrder = await _createPaymentOrder(
//         orderId: orderId,
//         items: items,
//         totalAmount: totalAmount,
//         paymentMethod: paymentMethod,
//       );
//
//       if (!paymentOrder) {
//         throw Exception('Failed to create payment order');
//       }
//
//       // Create kitchen order
//       final kitchenOrder = await _createKitchenOrder(
//         orderId: orderId,
//         items: items,
//         restaurantName: restaurantName,
//       );
//
//       if (!kitchenOrder) {
//         _setError('Kitchen order failed but payment was successful');
//         return false;
//       }
//
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   Future<bool> _createPaymentOrder({
//     required String orderId,
//     required List<OrderItem> items,
//     required double totalAmount,
//     required String paymentMethod,
//   }) async {
//     try {
//       _paymentState.setLoading(true);
//
//       final paymentOrderData = _transformer.createPaymentOrderData(
//         orderId: orderId,
//         items: items,
//         totalAmount: totalAmount,
//         paymentMethod: paymentMethod,
//       );
//
//       final result = await _paymentRepository.createOrder(paymentOrderData);
//       _paymentState.setOrder(result);
//       return true;
//     } catch (e) {
//       _paymentState.setError(e.toString());
//       rethrow;
//     } finally {
//       _paymentState.setLoading(false);
//     }
//   }
//
//   Future<bool> _createKitchenOrder({
//     required String orderId,
//     required List<OrderItem> items,
//     required String restaurantName,
//   }) async {
//     try {
//       _kitchenState.setLoading(true);
//
//       final kitchenOrderData = _transformer.createKitchenOrderData(
//         orderId: orderId,
//         items: items,
//         restaurantName: restaurantName,
//       );
//
//       final result = await _kitchenRepository.createOrder(kitchenOrderData);
//       _kitchenState.setOrder(result);
//       return true;
//     } catch (e) {
//       _kitchenState.setError(e.toString());
//       rethrow;
//     } finally {
//       _kitchenState.setLoading(false);
//     }
//   }
//
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
//
//   void _setError(String message) {
//     _errorMessage = message;
//     notifyListeners();
//   }
//
//   void _clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }
