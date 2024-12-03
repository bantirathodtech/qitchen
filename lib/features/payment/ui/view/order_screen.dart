// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../../../common/styles/app_text_styles.dart';
// import '../../../../common/widgets/custom_app_bar.dart';
// import '../../../../data/db/app_preferences.dart';
// import '../../../1.auth/verify/model/verify_model.dart';
// import '../../../3.home/cart/models/cart_item.dart';
// import '../../../3.home/cart/multiple/cart_manager.dart';
// import '../../../3.home/loading_indicator.dart';
// import '../../data/model/order_data_model.dart';
// import '../../data/model/redis_order_model.dart';
// import '../../data/provider/order_provider.dart';
// import '../../data/provider/redis_order_provider.dart';
// import '../viewmodel/order_create_viewmodel.dart';
// import '../viewmodel/redis_order_viewmodel.dart';
//
// class OrderConfirmationScreen extends StatefulWidget {
//   static const String TAG = '[OrderConfirmationScreen]';
//
//   final int itemCount;
//   final double totalAmount;
//   final String paymentMethodId;
//   final DateTime date;
//   final String restaurantName;
//   final Map<String, dynamic> orderData;
//   final String businessUnitId;
//   final String mobileNo;
//
//   const OrderConfirmationScreen({
//     super.key,
//     required this.itemCount,
//     required this.totalAmount,
//     required this.paymentMethodId,
//     required this.date,
//     required this.restaurantName,
//     required this.orderData,
//     required this.businessUnitId,
//     required this.mobileNo,
//   });
//
//   @override
//   State<OrderConfirmationScreen> createState() =>
//       _OrderConfirmationScreenState();
// }
//
// class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
//   static const String TAG = '[OrderConfirmationScreen]';
//   late final OrderViewModel _orderViewModel;
//   late final RedisOrderViewModel _redisOrderViewModel;
//   bool _isCreatingOrder = false;
//   String _error = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
//     _redisOrderViewModel =
//         Provider.of<RedisOrderViewModel>(context, listen: false);
//     _createOrder();
//   }
//
//   Future<void> _createOrder() async {
//     setState(() {
//       _isCreatingOrder = true;
//       _error = '';
//     });
//
//     try {
//       final cartManager = context.read<CartManager>();
//       final customer = await _getCustomerData();
//
//       if (customer == null) {
//         throw Exception('User data not found');
//       }
//
//       // Create main order
//       final orderSuccess = await _orderViewModel.createOrder(
//         documentNo: widget.orderData['documentno'],
//         businessUnitId: widget.businessUnitId,
//         paymentMethodId: widget.paymentMethodId,
//         mobileNo: widget.mobileNo,
//         orderLines: _convertCartItemsToOrderLines(cartManager),
//         totalAmount: widget.totalAmount.toInt(),
//         taxAmount: (widget.totalAmount * 0.05).toInt(),
//       );
//
//       if (!orderSuccess) {
//         throw Exception('Failed to create main order');
//       }
//
//       AppLogger.logInfo('$TAG Order created successfully');
//
//       // Create Redis order for the same order
//       final redisSuccess = await _redisOrderViewModel.createRedisOrder(
//         customerId: customer.b2cCustomerId ?? '',
//         documentno: widget.orderData['documentno'],
//         businessUnitId: widget.businessUnitId,
//         customerName: '${customer.firstName} ${customer.lastName}'.trim(),
//         orderLines: _convertToRedisOrderLines(
//             cartManager.cartItemsByRestaurant[widget.restaurantName] ?? [],
//             widget.orderData['documentno']),
//       );
//
//       if (!redisSuccess) {
//         AppLogger.logWarning(
//             '$TAG Redis order creation failed but main order was successful');
//       }
//
//       // Clear cart after both orders are processed
//       cartManager.clearCart();
//     } catch (e) {
//       AppLogger.logError('$TAG Error creating order: $e');
//       setState(() => _error = e.toString());
//     } finally {
//       setState(() => _isCreatingOrder = false);
//     }
//   }
//
//   // Helper method to create order lines for main order
//   List<OrderLine> _convertCartItemsToOrderLines(CartManager cartManager) {
//     final cartItems =
//         cartManager.cartItemsByRestaurant[widget.restaurantName] ?? [];
//     AppLogger.logDebug(
//         '$TAG Converting ${cartItems.length} cart items to order lines');
//
//     return cartItems.map((item) {
//       final lineTotal = item.totalPrice;
//       final lineTax = lineTotal * 0.05;
//       final lineNet = lineTotal - lineTax;
//
//       return OrderLine(
//         mProductId: item.product.productId,
//         qty: item.quantity,
//         unitprice: num.tryParse(item.product.unitprice.toString()) ?? 0,
//         linenet: lineNet,
//         linetax: lineTax,
//         linegross: lineTotal,
//         subProducts: _convertAddonsToSubProducts(item),
//       );
//     }).toList();
//   }
//
//   // Helper method for Redis order lines
//   List<RedisOrderLine> _convertToRedisOrderLines(
//       List<CartItem> items, String documentNo) {
//     return items
//         .map((item) => RedisOrderLine(
//               mProductId: item.product.productId,
//               name: item.product.name,
//               qty: item.quantity.toInt(),
//               notes: '',
//               productioncenter: item.product.productionCenter ?? 'Main Kitchen',
//               tokenNumber:
//                   int.parse(documentNo.substring(documentNo.length - 3)),
//               status: 'pending',
//               subProducts: _convertAddonsToRedisSubProducts(item),
//             ))
//         .toList();
//   }
//
//   List<RedisSubProduct> _convertAddonsToRedisSubProducts(CartItem item) {
//     return item.selectedAddons.entries.expand((entry) {
//       return entry.value.map((addon) => RedisSubProduct(
//             addonProductId: addon.id,
//             name: addon.name,
//             qty: 1,
//           ));
//     }).toList();
//   }
//
//   // Add this method to get customer data
//   Future<CustomerModel?> _getCustomerData() async {
//     try {
//       final userData = await AppPreference.getUserData();
//       if (userData == null) return null;
//       return CustomerModel.fromJson(userData);
//     } catch (e) {
//       AppLogger.logError('$TAG Error retrieving customer data: $e');
//       return null;
//     }
//   }
//
//   // Helper methods for converting addons
//   List<SubProduct> _convertAddonsToSubProducts(CartItem item) {
//     return item.selectedAddons.entries.expand((entry) {
//       return entry.value.map((addon) => SubProduct(
//             addonProductId: addon.id,
//             name: addon.name,
//             price: num.tryParse(addon.price.toString()) ?? 0,
//             qty: 1,
//           ));
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async =>
//           !_isCreatingOrder && !_isCreatingRedisOrder, // Updated condition
//       child: Scaffold(
//         appBar: CustomAppBar(
//           logoPath: 'assets/images/cw_image.png',
//           onBackPressed: (_isCreatingOrder || _isCreatingRedisOrder)
//               ? null
//               : () => Navigator.pop(context),
//         ),
//         body: Consumer2<OrderProvider, RedisOrderProvider>(
//           // Updated to Consumer2
//           builder: (context, orderProvider, redisOrderProvider, _) {
//             if (_isCreatingOrder ||
//                 _isCreatingRedisOrder ||
//                 orderProvider.isLoading ||
//                 redisOrderProvider.isLoading) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     LoadingIndicator(),
//                     SizedBox(height: 8),
//                     Text('Processing order...'),
//                   ],
//                 ),
//               );
//             }
//
//             if (_error.isNotEmpty) {
//               return _buildErrorView();
//             }
//
//             return _buildSuccessView(orderProvider);
//           },
//         ),
//       ),
//     );
//   }
//
// // Fix the retry button action
//   Widget _buildErrorView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, color: Colors.red, size: 48),
//             const SizedBox(height: 16),
//             Text(
//               'Failed to create order',
//               style: AppTextStyles.h4.copyWith(color: Colors.red),
//             ),
//             const SizedBox(height: 8),
//             Text(_error, style: AppTextStyles.body2),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed:
//                   _createOrders, // Changed from _createOrder to _createOrders
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSuccessView(OrderProvider orderProvider) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildSuccessCard(),
//             const SizedBox(height: 24),
//             _buildOrderDetails(),
//             const SizedBox(height: 24),
//             _buildItemsList(),
//             const SizedBox(height: 24),
//             _buildFooter(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSuccessCard() {
//     return Card(
//       elevation: 4,
//       color: Colors.green[100],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 48),
//             const SizedBox(height: 16),
//             Text(
//               'Order Placed Successfully!',
//               style: AppTextStyles.h3.copyWith(color: Colors.green[800]),
//             ),
//             Text(
//               'Order ID: ${widget.orderData['documentno']}',
//               style: AppTextStyles.body2,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderDetails() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Order Details', style: AppTextStyles.h4),
//             const Divider(),
//             _buildDetailRow('Restaurant', widget.restaurantName),
//             _buildDetailRow('Date', _formatDate(widget.date)),
//             _buildDetailRow('Items', widget.itemCount.toString()),
//             // _buildDetailRow('Payment Method', _getPaymentMethodName()),
//             // Simply display Payment Method without conversion
//             _buildDetailRow('Payment Method', widget.paymentMethodId),
//             _buildDetailRow(
//               'Total Amount',
//               '₹${widget.totalAmount.toStringAsFixed(2)}',
//               isTotal: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: AppTextStyles.body2),
//           Text(
//             value,
//             style: isTotal ? AppTextStyles.h4 : AppTextStyles.body2,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemsList() {
//     final cartManager = context.read<CartManager>();
//     final items =
//         cartManager.cartItemsByRestaurant[widget.restaurantName] ?? [];
//
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Order Items', style: AppTextStyles.h4),
//             const Divider(),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 final item = items[index];
//                 return _buildItemRow(item);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildItemRow(CartItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Text('${item.quantity}x ', style: AppTextStyles.body2),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.product.name, style: AppTextStyles.body2),
//                 if (item.selectedAddons.isNotEmpty)
//                   ...item.selectedAddons.entries
//                       .expand((entry) => entry.value)
//                       .map(
//                         (addon) => Text(
//                           '  + ${addon.name}',
//                           style: AppTextStyles.body2
//                               .copyWith(color: Colors.grey[600]),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//           Text(
//             '₹${item.totalPrice.toStringAsFixed(2)}',
//             style: AppTextStyles.body2,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFooter() {
//     return ElevatedButton(
//       onPressed: () => Navigator.of(context).pop(true),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.green,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//       ),
//       child: const Text('Back to Home'),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
//   }
// }
