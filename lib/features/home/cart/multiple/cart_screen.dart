// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../common/log/loggers.dart';
// import '../../../../common/styles/ElevatedButton.dart';
// import '../../../../common/styles/app_text_styles.dart';
// import '../../../../common/widgets/custom_app_bar.dart';
// import '../../../../data/db/app_preferences.dart'; // Import AppPreference
// import '../../../ordering/order/data/models/kitchen_order.dart';
// import '../../../ordering/order/payment_processor.dart';
// import '../../../ordering/order/payment_screen.dart';
// import '../../../ordering/order/services/kitchen_api_service.dart';
// import '../../../store/provider/store_provider.dart';
// import '../models/cart_item.dart';
// import 'cart_manager.dart';
// import 'package:cw_food_ordering/features/home/location_selection_screen.dart';
//
// class CartScreen extends StatefulWidget {
//   final VoidCallback onBackPressed;
//   static const String TAG = "CartScreen";
//
//   const CartScreen({super.key, required this.onBackPressed});
//
//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   String _selectedPaymentMethod = '';
//   bool _isLoading = false;
//   String? selectedCity;
//   String? selectedArea;
//   // For instructions
//   final TextEditingController _generalInstructionsController = TextEditingController();
//   final Map<String, TextEditingController> _itemInstructionsControllers = {};
//   bool _instructionsExpanded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }
//
//   @override
//   void dispose() {
//     _generalInstructionsController.dispose();
//     _itemInstructionsControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }
//
//   // Load saved location and payment method
//   Future<void> _loadSavedData() async {
//     try {
//       // Load location
//       final savedLocation = await AppPreference.getSelectedLocation();
//       // Load payment method
//       final savedPaymentMethod = await AppPreference.getSelectedPaymentMethod();
//
//       if (mounted) {
//         setState(() {
//           selectedCity = savedLocation['city'];
//           selectedArea = savedLocation['area'];
//           _selectedPaymentMethod = savedPaymentMethod ?? '';
//         });
//       }
//     } catch (e) {
//       AppLogger.logError('${CartScreen.TAG}: Error loading saved data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         widget.onBackPressed();
//         return false;
//       },
//       child: Scaffold(
//         appBar: CustomAppBar(
//           logoPath: 'assets/images/cw_image.png',
//           onBackPressed: widget.onBackPressed,
//         ),
//         body: _buildBody(context),
//       ),
//     );
//   }
//
//   Widget _buildBody(BuildContext context) {
//     return Consumer2<StoreProvider, CartManager>(
//       builder: (context, storeProvider, cartManager, _) {
//         final cartItemsByRestaurant = cartManager.cartItemsByRestaurant;
//         AppLogger.logInfo('${CartScreen.TAG}: Cart Restaurant Info:');
//         AppLogger.logInfo('${CartScreen.TAG}: Cart Items By Restaurant: ${cartItemsByRestaurant.keys.join(', ')}');
//         storeProvider.storeData?.restaurants.forEach((r) {
//           AppLogger.logInfo('${CartScreen.TAG}: - ${r.name} (ID: ${r.storeId}, CSBunit: ${r.businessUnit.name})');
//         });
//         return Stack(
//           children: [
//             Container(
//               color: Colors.grey[100],
//               child: cartItemsByRestaurant.isNotEmpty
//                   ? _buildCartWithItems(context, cartManager, cartItemsByRestaurant)
//                   : _buildEmptyCartUI(),
//             ),
//             _buildPaymentBar(context, storeProvider, cartManager),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildCartWithItems(
//       BuildContext context,
//       CartManager cartManager,
//       Map<String, List<CartItem>> cartItemsByRestaurant,
//       ) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 8),
//           _buildLocationAreaChange(),
//           _buildEstimateTime(),
//           ...cartItemsByRestaurant.entries.map((entry) => Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.05),
//                   spreadRadius: 1,
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: _buildRestaurantSection(context, cartManager, entry.key, entry.value),
//           )),
//           Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.05),
//                   spreadRadius: 1,
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: _buildBillDetails(cartManager),
//           ),
//           const Padding(padding: EdgeInsets.only(left: 16.0), child: Text("Instructions")),
//           _buildInstructionUI(),
//           const SizedBox(height: 8),
//           const Padding(padding: EdgeInsets.only(left: 16.0), child: Text("Note")),
//           _buildNoteUI(),
//           const SizedBox(height: 80),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLocationAreaChange() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 9, 16, 0),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.location_on, size: 20, color: Colors.grey),
//               const SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     selectedCity != null && selectedArea != null ? 'Ordering from:' : 'Select your location',
//                     style: AppTextStyles.captionText,
//                   ),
//                   if (selectedCity != null && selectedArea != null)
//                     Text('$selectedArea, $selectedCity', style: AppTextStyles.h5b),
//                 ],
//               ),
//             ],
//           ),
//           CustomElevatedButton(
//             text: 'Change',
//             color: Colors.blueGrey.withOpacity(0.4),
//             width: 110,
//             height: 36,
//             elevation: 0,
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const LocationSelectionScreen()),
//               );
//               if (result != null && result is Map<String, dynamic>) {
//                 setState(() {
//                   selectedCity = result['city'] as String?;
//                   selectedArea = result['area'] as String?;
//                 });
//               }
//             },
//             padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEstimateTime() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 9, 16, 0),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.access_time, size: 20, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Text('Estimated Time for Entry in Cafe', style: AppTextStyles.captionText.copyWith(fontWeight: FontWeight.w500)),
//                   const SizedBox(width: 4),
//                 ],
//               ),
//               Text('06:22 PM', style: AppTextStyles.h5b.copyWith(fontSize: 12)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () {},
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10.0),
//                   child: Text(
//                     'Why am I seeing this?',
//                     style: AppTextStyles.smallerText.copyWith(color: Colors.blueGrey, decoration: TextDecoration.underline),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRestaurantSection(BuildContext context, CartManager cartManager, String restaurantName, List<CartItem> cartItems) {
//     return Column(
//       children: [
//         _buildRestaurantHeader(restaurantName),
//         const Divider(height: 1, color: Colors.grey),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: cartItems.length,
//           separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
//           itemBuilder: (context, index) => _buildCartItem(context, cartManager, restaurantName, cartItems[index]),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRestaurantHeader(String restaurantName) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//             child: const Icon(Icons.store, color: Colors.black, size: 24),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(restaurantName, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
//                 Text('Biryani • Tandoor • Kebabs', style: AppTextStyles.menuOptionStyle.copyWith(color: Colors.grey.withOpacity(0.85), fontSize: 12)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCartItem(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
//     // Create a controller for this item's notes if it doesn't exist yet
//     final String itemKey = '${restaurantName}_${cartItem.product.productId}';
//     if (!_itemInstructionsControllers.containsKey(itemKey)) {
//       _itemInstructionsControllers[itemKey] = TextEditingController(text: cartItem.specialInstructions);
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(cartItem.product.name, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
//                     if (cartItem.selectedAddons.isNotEmpty)
//                       Padding(padding: const EdgeInsets.only(top: 4), child: _buildAddonsList(cartItem)),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               _buildQuantityControl(context, cartManager, restaurantName, cartItem),
//               const SizedBox(width: 16),
//               Text('₹${cartItem.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           _buildNotesField(context, cartManager, restaurantName, cartItem),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotesField(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
//     final String itemKey = '${restaurantName}_${cartItem.product.productId}';
//     final controller = _itemInstructionsControllers[itemKey]!;
//
//     return InkWell(
//       onTap: () => _showNotesDialog(context, cartManager, restaurantName, cartItem),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.withOpacity(0.2)),
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.grey.withOpacity(0.05),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey[600]),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 cartItem.specialInstructions?.isNotEmpty == true ? cartItem.specialInstructions! : 'Add special instructions',
//                 style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: cartItem.specialInstructions?.isNotEmpty == true ? Colors.black87 : Colors.grey[600]),
//               ),
//             ),
//             Icon(Icons.edit, size: 16, color: Colors.grey[600]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showNotesDialog(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
//     final String itemKey = '${restaurantName}_${cartItem.product.productId}';
//     final controller = _itemInstructionsControllers[itemKey]!;
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Special Instructions'),
//         content: TextField(
//           controller: controller,
//           maxLines: 3,
//           decoration: const InputDecoration(hintText: 'Enter any special instructions...', border: OutlineInputBorder()),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           TextButton(
//             onPressed: () {
//               cartManager.updateItemNotes(restaurantName, cartItem, controller.text.trim());
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuantityControl(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
//     return Container(
//       height: 36,
//       decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             padding: const EdgeInsets.all(4),
//             constraints: const BoxConstraints(),
//             icon: const Icon(Icons.remove, size: 16),
//             onPressed: () => cartManager.decrementCartItem(restaurantName, cartItem),
//           ),
//           Text('${cartItem.quantity}', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14)),
//           IconButton(
//             padding: const EdgeInsets.all(4),
//             constraints: const BoxConstraints(),
//             icon: const Icon(Icons.add, size: 16),
//             onPressed: () => cartManager.incrementCartItem(restaurantName, cartItem),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddonsList(CartItem cartItem) {
//     return Text(
//       cartItem.selectedAddons.entries.expand((entry) => entry.value.map((addon) => addon.name)).join(', '),
//       style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
//     );
//   }
//
//   Widget _buildBillDetails(CartManager cartManager) {
//     final taxes = cartManager.getTotalTaxesByCategory();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Bill Details', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
//         const SizedBox(height: 12),
//         _buildBillRow('Subtotal', cartManager.subtotal),
//         ...taxes.entries.map((entry) => _buildBillRow(entry.key, entry.value)),
//         Divider(color: Colors.grey.withOpacity(0.2)),
//         _buildBillRow('Total', cartManager.total, isBold: true),
//       ],
//     );
//   }
//
//   Widget _buildInstructionUI() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: _generalInstructionsController,
//             decoration: InputDecoration(
//               hintText: 'Add Instructions',
//               hintStyle: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
//               contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//             ),
//             style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12),
//             maxLines: 1,
//             textAlignVertical: TextAlignVertical.center,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('To add item-specific instructions, click here', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[700])),
//               GestureDetector(
//                 onTap: () => setState(() => _instructionsExpanded = !_instructionsExpanded),
//                 child: Icon(_instructionsExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 24, color: Colors.grey[600]),
//               ),
//             ],
//           ),
//           if (_instructionsExpanded)
//             Consumer<CartManager>(
//               builder: (context, cartManager, _) {
//                 final allItems = cartManager.cartItemsByRestaurant.entries
//                     .expand((entry) => entry.value
//                     .map((item) => {'restaurant': entry.key, 'item': item}))
//                     .toList();
//
//                 return Column(
//                   children: allItems.map((itemData) {
//                     final restaurantName = itemData['restaurant'] as String;
//                     final item = itemData['item'] as CartItem;
//                     final itemKey = '${restaurantName}_${item.product.productId}';
//
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '${item.product.name} (${restaurantName})',
//                             style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 4),
//                           TextField(
//                             controller: _itemInstructionsControllers[itemKey],
//                             decoration: InputDecoration(
//                               hintText: 'Add instructions for ${item.product.name}',
//                               hintStyle: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                             ),
//                             style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12),
//                             maxLines: 1,
//                             onChanged: (value) {
//                               cartManager.updateItemNotes(restaurantName, item, value.trim());
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoteUI() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Review your cart carefully to avoid any cancellation', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
//           const SizedBox(height: 12),
//           Text(
//             'You can cancel your order within 30 seconds of order placement to get a 100% refund. To avoid food wastage, you cannot cancel after 30 seconds.',
//             style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBillRow(String label, num amount, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.black87 : Colors.grey[700])),
//           Text('₹${amount.toStringAsFixed(2)}', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.black87 : Colors.grey[700])),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentBar(BuildContext context, StoreProvider storeProvider, CartManager cartManager) {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -3))],
//         ),
//         child: Row(
//           children: [
//             Expanded(child: _buildPaymentMethodDropdown(context, storeProvider, cartManager)),
//             const SizedBox(width: 16),
//             IntrinsicWidth(child: _buildPayButton(context, storeProvider, cartManager)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethodDropdown(BuildContext context, StoreProvider storeProvider, CartManager cartManager) {
//     return GestureDetector(
//       onTap: () => _showPaymentMethodSelection(context, storeProvider, cartManager),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('Pay Using', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600])),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               Text(_selectedPaymentMethod.isEmpty ? 'Select Method' : _selectedPaymentMethod, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
//               const SizedBox(width: 4),
//               const Icon(Icons.arrow_drop_down, size: 24),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showPaymentMethodSelection(BuildContext context, StoreProvider storeProvider, CartManager cartManager) async {
//     if (cartManager.cartItemsByRestaurant.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
//       return;
//     }
//     try {
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PaymentScreen(totalAmount: cartManager.total.toDouble(), businessUnitId: '')),
//       );
//       if (result != null && result is String) {
//         // Save the selected payment method
//         await AppPreference.saveSelectedPaymentMethod(result);
//         setState(() => _selectedPaymentMethod = result);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to load payment methods: $e')));
//     }
//   }
//
//   Widget _buildPayButton(BuildContext context, StoreProvider storeProvider, CartManager cartManager) {
//     return CustomElevatedButton(
//       onPressed: () => _processPayment(context),
//       color: Colors.black.withOpacity(0.4),
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
//       text: 'Pay • ₹${cartManager.total.toStringAsFixed(2)}',
//     );
//   }
//
//   Future<void> _processPayment(BuildContext context) async {
//     AppLogger.logInfo('[CartScreen] Processing payment');
//     setState(() => _isLoading = true);
//     try {
//       final cartManager = Provider.of<CartManager>(context, listen: false);
//       final storeProvider = Provider.of<StoreProvider>(context, listen: false);
//       final totalAmount = cartManager.total;
//
//       if (totalAmount <= 0) {
//         _showError(context, 'Cart is empty or invalid total');
//         return;
//       }
//
//       // First process payment
//       await PaymentProcessor.processPayment(
//         context: context,
//         selectedPaymentMethod: _selectedPaymentMethod,
//         totalAmount: totalAmount.toDouble(),
//         businessUnitId: '',
//         cartItemsByRestaurant: cartManager.cartItemsByRestaurant,
//         clearCart: () => cartManager.clearCart(),
//         showMessage: (message, {bool isError = false}) => _showError(context, message, isError: isError),
//       );
//
//       // Now create kitchen orders with notes for each restaurant
//       for (var restaurantEntry in cartManager.cartItemsByRestaurant.entries) {
//         final restaurantName = restaurantEntry.key;
//         final cartItems = restaurantEntry.value;
//
//         // Find the restaurant details to get the CSBunitID
//         final restaurant = storeProvider.storeData?.restaurants.firstWhere(
//               (r) => r.name == restaurantName,
//           orElse: () => null,
//         );
//
//         if (restaurant != null) {
//           final businessUnitId = restaurant.businessUnit.csBunitId;
//           await _createKitchenOrder(
//             restaurantName: restaurantName,
//             cartItems: cartItems,
//             businessUnitId: businessUnitId,
//             generalInstructions: _generalInstructionsController.text.trim(),
//           );
//         }
//       }
//
//       setState(() => _isLoading = false);
//     } catch (e) {
//       AppLogger.logError('[CartScreen] Payment processing failed: $e');
//       setState(() => _isLoading = false);
//       _showError(context, 'Payment failed: $e', isError: true);
//     }
//   }
//
//   Future<void> _createKitchenOrder({
//     required String restaurantName,
//     required List<CartItem> cartItems,
//     required String businessUnitId,
//     required String generalInstructions,
//   }) async {
//     try {
//       final kitchenApiService = Provider.of<KitchenApiService>(context, listen: false);
//       final storeProvider = Provider.of<StoreProvider>(context, listen: false);
//
//       // Create kitchen order line items from cart items
//       final lineItems = cartItems.map((cartItem) {
//         // Get the item-specific instructions if any
//         final String itemKey = '${restaurantName}_${cartItem.product.productId}';
//         final String itemNotes = cartItem.specialInstructions ?? '';
//
//         // Create addons list
//         final addons = cartItem.selectedAddons.entries
//             .expand((entry) => entry.value)
//             .map((addon) => KitchenOrderAddon(
//           addonProductId: addon.id,
//           name: addon.name,
//           qty: 1, // Default quantity for addon
//         ))
//             .toList();
//
//         return KitchenOrderItem(
//           mProductId: cartItem.product.productId,
//           name: cartItem.product.name,
//           qty: cartItem.quantity.toInt(),
//           notes: itemNotes, // Use the specific notes for this item
//           productioncenter: cartItem.product.productionCenter ?? '',
//           tokenNumber: DateTime.now().millisecondsSinceEpoch % 1000, // Generate a token number
//           status: 'Pending',
//           subProducts: addons,
//         );
//       }).toList();
//
//       // Create the order
//       final order = KitchenOrder(
//         customerId: storeProvider.userId ?? 'guest',
//         documentno: 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
//         cSBunitID: businessUnitId,
//         customerName: storeProvider.userName ?? 'Guest User',
//         dateOrdered: DateTime.now().toIso8601String(),
//         status: 'Pending',
//         line: lineItems,
//       );
//
//       // Send the order to the kitchen API
//       final response = await kitchenApiService.createRedisOrder(order);
//       AppLogger.logInfo('[CartScreen] Kitchen order created: ${response.message}');
//     } catch (e) {
//       AppLogger.logError('[CartScreen] Failed to create kitchen order: $e');
//       throw e; // Rethrow to be handled by the caller
//     }
//   }
//
//   Widget _buildEmptyCartUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
//             ),
//             child: const Icon(Icons.shopping_cart_outlined, size: 36, color: Colors.black87),
//           ),
//           const SizedBox(height: 24),
//           Text('Your Cart is Empty', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               'Looks like you haven\'t added anything to your cart yet.',
//               textAlign: TextAlign.center,
//               style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showError(BuildContext context, String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.black,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }


/////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/log/loggers.dart';
import '../../../../common/styles/ElevatedButton.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../data/db/app_preferences.dart';
import '../../../ordering/order/payment_processor.dart';
import '../../../ordering/order/payment_screen.dart';
import '../../../store/provider/store_provider.dart';
import '../models/cart_item.dart';
import 'cart_manager.dart';
import 'package:cw_food_ordering/features/home/location_selection_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  static const String TAG = "CartScreen";

  const CartScreen({super.key, required this.onBackPressed});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _selectedPaymentMethod = '';
  bool _isLoading = false;
  String? selectedCity;
  String? selectedArea;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

// Add this method to CartScreen:
  Future<void> _loadSavedData() async {
    // Load location
    final savedLocation = await AppPreference.getSelectedLocation();
    // Load payment method
    final savedPaymentMethod = await AppPreference.getSelectedPaymentMethod();

    if (mounted) {
      setState(() {
        selectedCity = savedLocation['city'];
        selectedArea = savedLocation['area'];
        _selectedPaymentMethod = savedPaymentMethod ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          logoPath: 'assets/images/cw_image.png',
          onBackPressed: widget.onBackPressed,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer2<StoreProvider, CartManager>(
      builder: (context, storeProvider, cartManager, _) {
        final cartItemsByRestaurant = cartManager.cartItemsByRestaurant;
        AppLogger.logInfo('${CartScreen.TAG}: Cart Restaurant Info:');
        AppLogger.logInfo('${CartScreen.TAG}: Cart Items By Restaurant: ${cartItemsByRestaurant.keys.join(', ')}');
        storeProvider.storeData?.restaurants.forEach((r) {
          AppLogger.logInfo('${CartScreen.TAG}: - ${r.name} (ID: ${r.storeId}, CSBunit: ${r.businessUnit.name})');
        });
        return Stack(
          children: [
            Container(
              color: Colors.grey[100],
              child: cartItemsByRestaurant.isNotEmpty
                  ? _buildCartWithItems(context, cartManager, cartItemsByRestaurant)
                  : _buildEmptyCartUI(),
            ),
            _buildPaymentBar(context, storeProvider, cartManager),
          ],
        );
      },
    );
  }

  Widget _buildCartWithItems(
      BuildContext context,
      CartManager cartManager,
      Map<String, List<CartItem>> cartItemsByRestaurant,
      ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildLocationAreaChange(),
          _buildEstimateTime(),
          ...cartItemsByRestaurant.entries.map((entry) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildRestaurantSection(context, cartManager, entry.key, entry.value),
          )),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildBillDetails(cartManager),
          ),
          const Padding(padding: EdgeInsets.only(left: 16.0), child: Text("Instructions")),
          _buildInstructionUI(),
          const SizedBox(height: 8),
          const Padding(padding: EdgeInsets.only(left: 16.0), child: Text("Note")),
          _buildNoteUI(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLocationAreaChange() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 9, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCity != null && selectedArea != null ? 'Ordering from:' : 'Select your location',
                    style: AppTextStyles.captionText,
                  ),
                  if (selectedCity != null && selectedArea != null)
                    Text('$selectedArea, $selectedCity', style: AppTextStyles.h5b),
                ],
              ),
            ],
          ),
          CustomElevatedButton(
            text: 'Change',
            color: Colors.blueGrey.withOpacity(0.4),
            width: 110,
            height: 36,
            elevation: 0,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationSelectionScreen()),
              );
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  selectedCity = result['city'] as String?;
                  selectedArea = result['area'] as String?;
                });
              }
            },
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateTime() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 9, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Estimated Time for Entry in Cafe', style: AppTextStyles.captionText.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                ],
              ),
              Text('06:22 PM', style: AppTextStyles.h5b.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Why am I seeing this?',
                    style: AppTextStyles.smallerText.copyWith(color: Colors.blueGrey, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection(BuildContext context, CartManager cartManager, String restaurantName, List<CartItem> cartItems) {
    return Column(
      children: [
        _buildRestaurantHeader(restaurantName),
        const Divider(height: 1, color: Colors.grey),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartItems.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          itemBuilder: (context, index) => _buildCartItem(context, cartManager, restaurantName, cartItems[index]),
        ),
      ],
    );
  }

  Widget _buildRestaurantHeader(String restaurantName) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.store, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurantName, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('Biryani • Tandoor • Kebabs', style: AppTextStyles.menuOptionStyle.copyWith(color: Colors.grey.withOpacity(0.85), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cartItem.product.name, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                    if (cartItem.selectedAddons.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 4), child: _buildAddonsList(cartItem)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildQuantityControl(context, cartManager, restaurantName, cartItem),
              const SizedBox(width: 16),
              Text('₹${cartItem.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotesField(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
    return InkWell(
      onTap: () => _showNotesDialog(context, cartManager, restaurantName, cartItem),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cartItem.specialInstructions?.isNotEmpty == true ? cartItem.specialInstructions! : 'Add special instructions',
                style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: cartItem.specialInstructions?.isNotEmpty == true ? Colors.black87 : Colors.grey[600]),
              ),
            ),
            Icon(Icons.edit, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
    final notesController = TextEditingController(text: cartItem.specialInstructions);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Special Instructions'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Enter any special instructions...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              cartManager.updateItemNotes(restaurantName, cartItem, notesController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(BuildContext context, CartManager cartManager, String restaurantName, CartItem cartItem) {
    return Container(
      height: 36,
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.remove, size: 16),
            onPressed: () => cartManager.decrementCartItem(restaurantName, cartItem),
          ),
          Text('${cartItem.quantity}', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14)),
          IconButton(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => cartManager.incrementCartItem(restaurantName, cartItem),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonsList(CartItem cartItem) {
    return Text(
      cartItem.selectedAddons.entries.expand((entry) => entry.value.map((addon) => addon.name)).join(', '),
      style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
    );
  }

  Widget _buildBillDetails(CartManager cartManager) {
    final taxes = cartManager.getTotalTaxesByCategory();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bill Details', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        _buildBillRow('Subtotal', cartManager.subtotal),
        ...taxes.entries.map((entry) => _buildBillRow(entry.key, entry.value)),
        Divider(color: Colors.grey.withOpacity(0.2)),
        _buildBillRow('Total', cartManager.total, isBold: true),
      ],
    );
  }

  Widget _buildInstructionUI() {
    bool isExpanded = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Add Instructions',
                  hintStyle: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                ),
                style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12),
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('To add item-specific instructions, click here', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[700])),
                  GestureDetector(
                    onTap: () => setState(() => isExpanded = !isExpanded),
                    child: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 24, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (isExpanded)
                Column(
                  children: List.generate(5, (index) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add item-specific instruction ${index + 1}',
                        hintStyle: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12),
                      maxLines: 1,
                    ),
                  )),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteUI() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review your cart carefully to avoid any cancellation', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Text(
            'You can cancel your order within 30 seconds of order placement to get a 100% refund. To avoid food wastage, you cannot cancel after 30 seconds.',
            style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, num amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.black87 : Colors.grey[700])),
          Text('₹${amount.toStringAsFixed(2)}', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.black87 : Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildPaymentBar(BuildContext context, StoreProvider storeProvider, CartManager cartManager) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -3))],
        ),
        child: Row(
          children: [
            Expanded(child: _buildPaymentMethodDropdown(context, storeProvider, cartManager)),
            const SizedBox(width: 16),
            IntrinsicWidth(child: _buildPayButton(context, storeProvider, cartManager)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(BuildContext context, StoreProvider storeProvider, CartManager cartManager) {
    return GestureDetector(
      onTap: () => _showPaymentMethodSelection(context, storeProvider, cartManager),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pay Using', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(_selectedPaymentMethod.isEmpty ? 'Select Method' : _selectedPaymentMethod, style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodSelection(BuildContext context, StoreProvider storeProvider, CartManager cartManager) async {
    if (cartManager.cartItemsByRestaurant.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentScreen(totalAmount: cartManager.total.toDouble(), businessUnitId: '')),
      );
      if (result != null && result is String) {
        // Save the selected payment method
        await AppPreference.saveSelectedPaymentMethod(result);
        setState(() => _selectedPaymentMethod = result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to load payment methods: $e')));
    }
  }

  Widget _buildPayButton(BuildContext context, StoreProvider storeProvider, CartManager cartManager) {
    return CustomElevatedButton(
      onPressed: () => _processPayment(context),
      color: Colors.black.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      text: 'Pay • ₹${cartManager.total.toStringAsFixed(2)}',
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    AppLogger.logInfo('[CartScreen] Processing payment');
    setState(() => _isLoading = true);
    try {
      final cartManager = Provider.of<CartManager>(context, listen: false);
      final totalAmount = cartManager.total; // Changed from totalCartPrice
      if (totalAmount <= 0) {
        _showError(context, 'Cart is empty or invalid total');
        return;
      }
      await PaymentProcessor.processPayment(
        context: context,
        selectedPaymentMethod: _selectedPaymentMethod,
        totalAmount: totalAmount.toDouble(),
        businessUnitId: '',
        cartItemsByRestaurant: cartManager.cartItemsByRestaurant,
        clearCart: () => cartManager.clearCart(), // Simplified clearCart callback
        showMessage: (message, {bool isError = false}) => _showError(context, message, isError: isError),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      AppLogger.logError('[CartScreen] Payment processing failed: $e');
      setState(() => _isLoading = false);
      _showError(context, 'Payment failed: $e', isError: true);
    }
  }

  Widget _buildEmptyCartUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 36, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Text('Your Cart is Empty', style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Looks like you haven\'t added anything to your cart yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.menuOptionStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.black,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
