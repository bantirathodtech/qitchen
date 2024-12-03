// import 'package:cw_food_ordering/features/8.payment/ui/view/payment_method_option.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../../../../common/styles/ElevatedButton.dart';
// import '../../../../common/styles/app_text_styles.dart';
// import '../../../../common/widgets/custom_app_bar.dart';
// import '../../../../data/db/app_preferences.dart';
// import '../../../1.auth/verify/model/verify_model.dart';
// import '../../../3.home/cart/models/cart_item.dart';
// import '../../../3.home/cart/multiple/cart_manager.dart';
// import '../../../9.wallet/view/wallet_view.dart';
// import '../../../9.wallet/viewmodel/wallet_viewmodel.dart';
// import '../../data/model/order_data_model.dart';
// import '../../service/razorpay_service.dart';
// import '../viewmodel/order_create_viewmodel.dart';
// import '../viewmodel/redis_order_viewmodel.dart';
// import 'order_screen.dart';
//
// class PaymentScreen extends StatefulWidget {
//   final double totalAmount;
//   final String businessUnitId;
//
//   const PaymentScreen({
//     super.key,
//     required this.totalAmount,
//     required this.businessUnitId,
//   });
//
//   @override
//   State<PaymentScreen> createState() => PaymentScreenState();
// }
//
// class PaymentScreenState extends State<PaymentScreen> {
//   static const String TAG = "PaymentScreen";
//   String _selectedPaymentMethod = '';
//   bool _isLoading = false;
//   final String _orderNumber = DateTime.now().millisecondsSinceEpoch.toString();
//   late final OrderViewModel _orderViewModel;
//   late final RedisOrderViewModel _redisOrderViewModel;
//   late final CartManager _cartManager;
//
//   @override
//   void initState() {
//     super.initState();
//     _orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
//     _cartManager = Provider.of<CartManager>(context, listen: false);
//     _redisOrderViewModel =
//         Provider.of<RedisOrderViewModel>(context, listen: false);
//     _initializeWallet();
//   }
//
//   Future<void> _initializeWallet() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final customer = await _getCustomerData();
//       if (customer?.b2cCustomerId != null) {
//         await _fetchWalletBalance(customer!.b2cCustomerId!);
//       }
//     } catch (e) {
//       _handleError('Failed to initialize wallet: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _fetchWalletBalance(String customerId) async {
//     try {
//       await Provider.of<WalletViewModel>(context, listen: false)
//           .fetchWalletBalance(customerId);
//     } catch (e) {
//       AppLogger.logError('Error fetching wallet balance: $e');
//       _handleError('Unable to fetch wallet balance');
//     }
//   }
//
//   Future<CustomerModel?> _getCustomerData() async {
//     try {
//       final userData = await AppPreference.getUserData();
//       if (userData == null) {
//         _handleError('User data not found');
//         return null;
//       }
//
//       return CustomerModel.fromJson(userData);
//     } catch (e) {
//       AppLogger.logError('Error retrieving customer data: $e');
//       return null;
//     }
//   }
//
//   void _handleRazorpayPayment() async {
//     setState(() => _isLoading = true);
//
//     try {
//       await RazorpayUtility.openRazorpayCheckout(
//         amount: widget.totalAmount.toString(),
//         orderNumber: _orderNumber,
//         onSuccess: (PaymentSuccessResponse response) {
//           _handlePaymentSuccess(response);
//         },
//         onError: (PaymentFailureResponse response) {
//           _handlePaymentError(response);
//         },
//         onExternalWallet: (ExternalWalletResponse response) {
//           _handleExternalWalletResponse(response);
//         },
//       );
//     } catch (e) {
//       _handleError('Failed to initialize Razorpay payment: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _handleCreateOrder({
//     required String paymentMethodId,
//     required CustomerModel customer,
//   }) async {
//     try {
//       final restaurantItems = _cartManager.cartItemsByRestaurant;
//       if (restaurantItems.isEmpty) {
//         _handleError('No items in cart');
//         return;
//       }
//
//       // Get restaurant name before we clear the cart
//       final restaurantName = restaurantItems.keys.first;
//
//       // Static product ID to be used for all products and addons
//       const mProductId = "21280F0192C1430CA9A5B69D01A7D626";
//       const addonProductId = "21280F0192C1430CA9A5B69D01A7D626";
//
//       // Assuming we're dealing with a single restaurant's order
//       final items = restaurantItems[restaurantName] ?? [];
//
//       // Convert cart items to order lines
//       final orderLines = items.map((item) {
//         // Calculate line totals
//         final lineTotal = item.totalPrice;
//         final lineTax = lineTotal * 0.05; // 5% tax
//         final lineNet = lineTotal - lineTax;
//
//         // Convert addons to SubProduct list, using static product ID
//         final subProducts = item.selectedAddons.entries.expand((entry) {
//           return entry.value.map((addon) => SubProduct(
//                 // addonProductId: addon.id,
//                 addonProductId: addonProductId,
//                 name: addon.name,
//                 price: num.tryParse(addon.price.toString()) ?? 0,
//                 qty: 1,
//               ));
//         }).toList();
//
//         return OrderLine(
//           // mProductId: item.product.productId,
//           mProductId: mProductId,
//           qty: item.quantity,
//           unitprice: num.tryParse(item.product.unitprice.toString()) ?? 0,
//           linenet: lineNet,
//           linetax: lineTax,
//           linegross: lineTotal,
//           subProducts: subProducts,
//         );
//       }).toList();
//
//       final success = await _orderViewModel.createOrder(
//         documentNo: _orderNumber,
//         businessUnitId: widget.businessUnitId,
//         paymentMethodId: paymentMethodId,
//         mobileNo: customer.mobileNo ?? '',
//         orderLines: orderLines,
//         totalAmount: widget.totalAmount.toInt(),
//         taxAmount: (widget.totalAmount * 0.05).toInt(), // 5% tax
//       );
//
//       if (success) {
//         _cartManager.clearCart();
//         _showOrderConfirmation(restaurantName); // Pass the restaurant name
//       } else {
//         throw Exception('Failed to create order');
//       }
//     } catch (e) {
//       _handleError('Error creating order: $e');
//     }
//   }
//
//   void _showOrderConfirmation(String restaurantName) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OrderConfirmationScreen(
//           itemCount: _cartManager.itemCount.toInt(),
//           // Convert num to int
//           totalAmount: widget.totalAmount,
//           paymentMethodId: _selectedPaymentMethod,
//           date: DateTime.now(),
//           restaurantName: restaurantName, // Use passed restaurantName
//           orderData: {'documentno': _orderNumber},
//           businessUnitId: widget.businessUnitId,
//           mobileNo: '', // Will be filled from customer data
//         ),
//       ),
//     );
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     AppLogger.logInfo('Payment successful: ${response.paymentId}');
//
//     try {
//       final customer = await _getCustomerData();
//       if (customer == null) {
//         _handleError('User data not found');
//         return;
//       }
//
//       // Create order and Redis order after payment success
//       final success = await _createOrderAndRedisOrder(
//         paymentMethodId: '5C2FB7612B5C48C9BF7ADB1C41D27849',
//         customer: customer,
//       );
//
//       if (success) {
//         _showMessage('Payment and order creation successful!');
//       }
//     } catch (e) {
//       _handleError('Error processing order after payment: $e');
//     }
//   }
//
//   void _handleWalletPaymentSync() async {
//     final walletViewModel =
//         Provider.of<WalletViewModel>(context, listen: false);
//
//     if (walletViewModel.walletBalance?.balanceAmt == null) {
//       _handleError('Unable to fetch wallet balance');
//       return;
//     }
//
//     if ((walletViewModel.walletBalance?.balanceAmt ?? 0) < widget.totalAmount) {
//       _showMessage('Insufficient wallet balance');
//       return;
//     }
//
//     try {
//       final customer = await _getCustomerData();
//       if (customer == null) {
//         _handleError('User data not found');
//         return;
//       }
//
//       // Create order and Redis order for wallet payment
//       final success = await _createOrderAndRedisOrder(
//         paymentMethodId: '5C2FB7612B5C48C9BF7ADB1C41D27849',
//         customer: customer,
//       );
//
//       if (success) {
//         _showMessage('Wallet payment and order creation successful!');
//       }
//     } catch (e) {
//       _handleError('Wallet payment and order creation failed: $e');
//     }
//   }
//
//   // New unified method for creating both orders
//   Future<bool> _createOrderAndRedisOrder({
//     required String paymentMethodId,
//     required CustomerModel customer,
//   }) async {
//     try {
//       final restaurantItems = _cartManager.cartItemsByRestaurant;
//       if (restaurantItems.isEmpty) {
//         _handleError('No items in cart');
//         return false;
//       }
//
//       final restaurantName = restaurantItems.keys.first;
//       const mProductId = "21280F0192C1430CA9A5B69D01A7D626";
//
//       final items = restaurantItems[restaurantName] ?? [];
//       final orderLines = _createOrderLines(items, mProductId);
//
//       // 1. Create main order
//       final orderSuccess = await _orderViewModel.createOrder(
//         documentNo: _orderNumber,
//         businessUnitId: widget.businessUnitId,
//         paymentMethodId: paymentMethodId,
//         mobileNo: customer.mobileNo ?? '',
//         orderLines: orderLines,
//         totalAmount: widget.totalAmount.toInt(),
//         taxAmount: (widget.totalAmount * 0.05).toInt(),
//       );
//
//       if (!orderSuccess) {
//         throw Exception('Failed to create main order');
//       }
//
//       // 2. Create Redis order for the same order
//       final redisSuccess = await _redisOrderViewModel.createRedisOrder(
//         customerId: customer.b2cCustomerId ?? '',
//         documentno: _orderNumber,
//         businessUnitId: widget.businessUnitId,
//         customerName: '${customer.firstName} ${customer.lastName}'.trim(),
//         orderLines: _createRedisOrderLines(items, _orderNumber),
//       );
//
//       if (!redisSuccess) {
//         AppLogger.logWarning(
//             'Redis order creation failed but main order was successful');
//       }
//
//       // Clear cart and navigate only after both orders are processed
//       _cartManager.clearCart();
//       _navigateToOrderConfirmation(restaurantName);
//
//       return true;
//     } catch (e) {
//       _handleError('Error creating order: $e');
//       return false;
//     }
//   }
//
//   // Helper method to create order lines
//   List<OrderLine> _createOrderLines(List<CartItem> items, String mProductId) {
//     return items.map((item) {
//       final lineTotal = item.totalPrice;
//       final lineTax = lineTotal * 0.05;
//       final lineNet = lineTotal - lineTax;
//
//       final subProducts = item.selectedAddons.entries.expand((entry) {
//         return entry.value.map((addon) => SubProduct(
//               addonProductId: mProductId,
//               name: addon.name,
//               price: num.tryParse(addon.price.toString()) ?? 0,
//               qty: 1,
//             ));
//       }).toList();
//
//       return OrderLine(
//         mProductId: mProductId,
//         qty: item.quantity,
//         unitprice: num.tryParse(item.product.unitprice.toString()) ?? 0,
//         linenet: lineNet,
//         linetax: lineTax,
//         linegross: lineTotal,
//         subProducts: subProducts,
//       );
//     }).toList();
//   }
//
//   void _navigateToOrderConfirmation(String restaurantName) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OrderConfirmationScreen(
//           itemCount: _cartManager.itemCount.toInt(),
//           totalAmount: widget.totalAmount,
//           paymentMethodId: _selectedPaymentMethod,
//           date: DateTime.now(),
//           restaurantName: restaurantName,
//           orderData: {'documentno': _orderNumber},
//           businessUnitId: widget.businessUnitId,
//           mobileNo: '', // Will be filled from customer data
//         ),
//       ),
//     );
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     AppLogger.logError('Payment failed: ${response.message}');
//     _handleError(
//         'Payment failed: ${response.message ?? "Unknown error occurred"}');
//   }
//
//   void _handleExternalWalletResponse(ExternalWalletResponse response) {
//     AppLogger.logInfo('External wallet selected: ${response.walletName}');
//     _showMessage('Processing payment through ${response.walletName}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         logoPath: 'assets/images/cw_image.png',
//         onBackPressed: () => Navigator.of(context).pop(),
//       ),
//       body: Consumer<WalletViewModel>(
//         builder: (context, walletViewModel, _) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildTotalAmount(),
//                 const SizedBox(height: 24),
//                 Text('Choose Payment Method', style: AppTextStyles.subheading),
//                 const SizedBox(height: 16),
//                 _buildPaymentMethods(walletViewModel),
//                 const Spacer(),
//                 CustomElevatedButton(
//                   onPressed: () {
//                     if (!_isLoading) {
//                       _handlePayNow();
//                     }
//                   },
//                   color: _isLoading ? Colors.grey : Colors.deepOrangeAccent,
//                   text: _isLoading ? 'Processing...' : 'Pay Now',
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _handlePayNow() {
//     if (_isLoading) return;
//
//     try {
//       if (_selectedPaymentMethod.isEmpty) {
//         _showMessage('Please select a payment method');
//         return;
//       }
//
//       switch (_selectedPaymentMethod) {
//         case 'Wallet':
//           _handleWalletPaymentSync();
//           break;
//         case 'Razorpay':
//           _handleRazorpayPayment();
//           break;
//         default:
//           _showMessage('Invalid payment method selected');
//       }
//     } catch (e) {
//       _handleError('Payment processing failed: $e');
//     }
//   }
//
//   Widget _buildPaymentMethods(WalletViewModel walletViewModel) {
//     return Column(
//       children: [
//         PaymentMethodOption(
//           title: 'Wallet',
//           icon: Icons.account_balance_wallet,
//           isSelected: _selectedPaymentMethod == 'Wallet',
//           isWallet: true,
//           isLoading: walletViewModel.isLoading || _isLoading,
//           walletBalance: walletViewModel.walletBalance?.balanceAmt,
//           onSelect: () => setState(() => _selectedPaymentMethod = 'Wallet'),
//           onAddMoney: () => _handleAddMoneyToWallet(context),
//         ),
//         const SizedBox(height: 8),
//         PaymentMethodOption(
//           title: 'Razorpay',
//           icon: Icons.credit_card,
//           isSelected: _selectedPaymentMethod == 'Razorpay',
//           onSelect: () {
//             setState(() => _selectedPaymentMethod = 'Razorpay');
//           },
//         ),
//       ],
//     );
//   }
//
//   Future<void> _handleAddMoneyToWallet(BuildContext context) async {
//     try {
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => WalletPaymentHandler(
//             amount: widget.totalAmount,
//             onComplete: (success) async {
//               if (success) {
//                 await _refreshWalletBalance();
//               }
//             },
//           ),
//         ),
//       );
//
//       if (result == true) {
//         await _refreshWalletBalance();
//       }
//     } catch (e) {
//       _handleError('Error handling wallet payment: $e');
//     }
//   }
//
//   Future<void> _refreshWalletBalance() async {
//     try {
//       final customer = await _getCustomerData();
//       if (customer?.b2cCustomerId != null) {
//         final walletViewModel = Provider.of<WalletViewModel>(
//           context,
//           listen: false,
//         );
//         await walletViewModel.fetchWalletBalance(customer!.b2cCustomerId!);
//       }
//     } catch (e) {
//       _handleError('Error refreshing wallet balance: $e');
//     }
//   }
//
//   Widget _buildTotalAmount() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text('Total Amount', style: AppTextStyles.h4),
//           Text(
//             'Rs.${widget.totalAmount.toStringAsFixed(2)}',
//             style: AppTextStyles.h1,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _handleError(String message) {
//     AppLogger.logError(message);
//     _showMessage(message, isError: true);
//   }
//
//   void _showMessage(String message, {bool isError = false}) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.black,
//       ),
//     );
//   }
// }
