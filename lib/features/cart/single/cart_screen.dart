// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../../../common/styles/app_text_styles.dart';
// import '../../../../common/widgets/custom_app_bar.dart';
// import '../manager/cart_manager.dart';
// import '../models/cart_item.dart';
//
// class CartScreen extends StatelessWidget {
//   static const String TAG = '[CartScreen]';
//
//   final VoidCallback onBackPressed;
//
//   const CartScreen({
//     super.key,
//     required this.onBackPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         onBackPressed();
//         return false;
//       },
//       child: Scaffold(
//         appBar: CustomAppBar(
//           onBackPressed: onBackPressed,
//           logoPath: 'assets/images/cw_image.png',
//         ),
//         body: _buildBody(context),
//       ),
//     );
//   }
//
//   Widget _buildBody(BuildContext context) {
//     return Consumer<CartManager>(
//       builder: (context, cartManager, child) {
//         if (cartManager.itemCount == 0) {
//           return _buildEmptyCart();
//         }
//         return _buildCartContent(context, cartManager);
//       },
//     );
//   }
//
//   Widget _buildEmptyCart() {
//     return const Center(
//       child: Text('Your cart is empty'),
//     );
//   }
//
//   Widget _buildCartContent(BuildContext context, CartManager cartManager) {
//     final currentRestaurant = cartManager.currentRestaurant;
//     if (currentRestaurant == null) return _buildEmptyCart();
//
//     final cartItems =
//         cartManager.cartItemsByRestaurant[currentRestaurant] ?? [];
//     final totalPrice = cartManager.getTotalPrice(currentRestaurant);
//
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildRestaurantHeader(currentRestaurant),
//               const SizedBox(height: 16),
//               ...cartItems.map((item) => _buildCartItem(
//                     context,
//                     cartManager,
//                     currentRestaurant,
//                     item,
//                   )),
//               const SizedBox(height: 16),
//               _buildTotalSection(totalPrice),
//               const SizedBox(height: 80), // Space for bottom button
//             ],
//           ),
//         ),
//         _buildCheckoutButton(context, totalPrice),
//       ],
//     );
//   }
//
//   Widget _buildRestaurantHeader(String restaurantName) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             const Icon(Icons.restaurant),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 restaurantName,
//                 style: AppTextStyles.h4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCartItem(
//     BuildContext context,
//     CartManager cartManager,
//     String restaurantName,
//     CartItem item,
//   ) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     item.product.name,
//                     style: AppTextStyles.h5,
//                   ),
//                 ),
//                 Text(
//                   '₹${(item.totalPrice * item.quantity).toStringAsFixed(2)}',
//                   style: AppTextStyles.h5,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildQuantityControls(
//                   context,
//                   cartManager,
//                   restaurantName,
//                   item,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline),
//                   onPressed: () =>
//                       cartManager.removeFromCart(restaurantName, item),
//                 ),
//               ],
//             ),
//             if (item.selectedAddons.isNotEmpty) ...[
//               const Divider(),
//               _buildAddons(item),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuantityControls(
//     BuildContext context,
//     CartManager cartManager,
//     String restaurantName,
//     CartItem item,
//   ) {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.remove),
//           onPressed: () => cartManager.decrementCartItem(restaurantName, item),
//         ),
//         Text('${item.quantity}', style: AppTextStyles.h5),
//         IconButton(
//           icon: const Icon(Icons.add),
//           onPressed: () {
//             // Since addToCart handles validation, we'll use the same pattern
//             cartManager.addToCart(
//               context,
//               restaurantName,
//               item.product,
//               item.selectedAddons,
//               1,
//               item.totalPrice,
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAddons(CartItem item) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Add-ons:', style: AppTextStyles.h6),
//         ...item.selectedAddons.entries.expand((group) {
//           return group.value.map((addon) {
//             return Padding(
//               padding: const EdgeInsets.only(left: 8, top: 4),
//               child: Text(
//                 '• ${addon.name} (₹${addon.price})',
//                 style: AppTextStyles.body2,
//               ),
//             );
//           });
//         }).toList(),
//       ],
//     );
//   }
//
//   Widget _buildTotalSection(double totalPrice) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Total:', style: AppTextStyles.h4),
//             Text(
//               '₹${totalPrice.toStringAsFixed(2)}',
//               style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCheckoutButton(BuildContext context, double totalPrice) {
//     return Positioned(
//       left: 16,
//       right: 16,
//       bottom: 16,
//       child: ElevatedButton(
//         onPressed: () => _handleCheckout(context, totalPrice),
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           backgroundColor: Theme.of(context).primaryColor,
//         ),
//         child: const Text(
//           'Proceed to Checkout',
//           style: TextStyle(fontSize: 16, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   void _handleCheckout(BuildContext context, double totalPrice) {
//     AppLogger.logInfo('$TAG: Proceeding to checkout with total: $totalPrice');
//     // Implement your checkout navigation logic here
//     // This should align with your app's navigation pattern
//   }
// }
