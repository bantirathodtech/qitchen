// lib/features/order/ui/screens/payment_screen.dart

import 'dart:async';

import 'package:cw_food_ordering/features/order/ui/screens/confirmation_display_screen.dart';
import 'package:cw_food_ordering/features/order/viewmodel/kitchen_order_viewmodel.dart';
import 'package:cw_food_ordering/features/order/viewmodel/payment_order_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/log/loggers.dart';
import '../../common/styles/ElevatedButton.dart';
import '../../common/styles/app_text_styles.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../data/db/app_preferences.dart';
import '../auth/verify/model/verify_model.dart';
import '../home/cart/models/cart_item.dart';
import '../home/cart/multiple/cart_manager.dart';
import '../payment/service/razorpay_service.dart';
import '../payment/ui/view/payment_method_option.dart';
import '../payment/utils/order_number_generator.dart';
import '../wallet/view/wallet_view.dart';
import '../wallet/viewmodel/wallet_viewmodel.dart';
import 'data/models/kitchen_order.dart';
import 'data/models/payment_order.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String businessUnitId;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.businessUnitId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const String TAG = '[PaymentScreen]';
  late final PaymentOrderViewModel _paymentViewModel;
  late final KitchenOrderViewModel _kitchenViewModel;
  late final CartManager _cartManager;

  String _selectedPaymentMethod = '';
  bool _isLoading = false;
  // final String _orderNumber = DateTime.now().millisecondsSinceEpoch.toString();

  // Replace the existing orderNumber with the new generator
  final String _orderNumber = OrderNumberGenerator.generateOrderNumber();

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('$TAG Initializing payment screen');
    _initializeViewModels();
    _initializeWallet();
  }

  void _initializeViewModels() {
    AppLogger.logInfo('$TAG Setting up view models');
    _paymentViewModel = context.read<PaymentOrderViewModel>();
    _kitchenViewModel = context.read<KitchenOrderViewModel>();
    _cartManager = context.read<CartManager>();
  }

  Future<void> _initializeWallet() async {
    setState(() => _isLoading = true);

    try {
      final customer = await _getCustomerData();
      if (customer?.b2cCustomerId != null) {
        await _fetchWalletBalance(customer!.b2cCustomerId!);
      }
    } catch (e) {
      _handleError('Failed to initialize wallet: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Future<void> _handlePayment() async {
  //   if (_selectedPaymentMethod.isEmpty) {
  //     _showMessage('Please select a payment method');
  //     return;
  //   }
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final customer = await _getCustomerData();
  //     if (customer == null) throw Exception('User data not found');
  //
  //     bool paymentSuccess = false;
  //
  //     // Handle payment based on selected method
  //     switch (_selectedPaymentMethod) {
  //       case 'Wallet':
  //         paymentSuccess = await _processWalletPayment();
  //         break;
  //       case 'Razorpay':
  //         paymentSuccess = await _processRazorpayPayment();
  //         break;
  //       default:
  //         throw Exception('Invalid payment method');
  //     }
  //
  //     if (!paymentSuccess) {
  //       throw Exception('Payment failed');
  //     }
  //
  //     // Create orders for each restaurant in cart
  //     for (var entry in _cartManager.cartItemsByRestaurant.entries) {
  //       await _createOrdersForRestaurant(
  //         customer: customer,
  //         restaurantName: entry.key,
  //         items: entry.value,
  //       );
  //     }
  //
  //     // Clear cart and show success
  //     _cartManager.clearCart();
  //     _showSuccess('Orders placed successfully!');
  //     _navigateToConfirmation();
  //   } catch (e) {
  //     AppLogger.logError('$TAG Payment processing failed: $e');
  //     _handleError(e.toString());
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<bool> _processWalletPayment() async {
  //   AppLogger.logInfo('$TAG Processing wallet payment');
  //
  //   final walletViewModel = context.read<WalletViewModel>();
  //   final balance = walletViewModel.walletBalance?.balanceAmt ?? 0;
  //
  //   if (balance < widget.totalAmount) {
  //     throw Exception('Insufficient wallet balance');
  //   }
  //
  //   return true;
  // }

  Future<void> _handlePayment() async {
    if (_selectedPaymentMethod.isEmpty) {
      _showMessage('Please select a payment method');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customer = await _getCustomerData();
      if (customer == null) throw Exception('User data not found');

      bool paymentSuccess = false;

      // Handle payment based on selected method
      switch (_selectedPaymentMethod) {
        case 'Wallet':
          paymentSuccess = await _processWalletPayment();
          break;
        case 'Razorpay':
          paymentSuccess = await _processRazorpayPayment();
          break;
        default:
          throw Exception('Invalid payment method');
      }

      if (!paymentSuccess) {
        throw Exception('Payment failed');
      }

      // Proceed with order creation and completion
      await _createOrders(customer);

      // Clear cart and show success
      _cartManager.clearCart();
      _showSuccess('Payment successful! Orders placed.');
      _navigateToConfirmation();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper method to create orders after successful payment
  Future<void> _createOrders(CustomerModel customer) async {
    // Create orders for each restaurant in cart
    for (var entry in _cartManager.cartItemsByRestaurant.entries) {
      await _createOrdersForRestaurant(
        customer: customer,
        restaurantName: entry.key,
        items: entry.value,
      );
    }
  }

  Future<bool> _processWalletPayment() async {
    AppLogger.logInfo('$TAG Processing wallet payment');

    try {
      final customer = await _getCustomerData();
      if (customer?.b2cCustomerId == null) {
        throw Exception('Customer ID not found');
      }

      final walletViewModel = context.read<WalletViewModel>();
      final balance = walletViewModel.walletBalance?.balanceAmt ?? 0;

      // First verify sufficient balance
      if (balance < widget.totalAmount) {
        throw Exception('Insufficient wallet balance');
      }

      // Process wallet payment first
      // Single wallet transaction for the order
      final result = await walletViewModel.spendFromWallet(
          customer!.b2cCustomerId!, widget.totalAmount, _orderNumber);

      if (!result.success) {
        throw Exception(result.error ?? 'Wallet transaction failed');
      }

      try {
        // Create orders only after successful payment
        await _createOrders(customer);
      } catch (e) {
        // If order creation fails, refund the wallet
        await walletViewModel.addMoneyToWallet(
          customer.b2cCustomerId!,
          widget.totalAmount,
        );
        throw Exception('Order creation failed, payment refunded: $e');
      }

      await _refreshWalletBalance();
      AppLogger.logInfo('$TAG Order created and wallet payment successful');
      return true;
    } catch (e) {
      AppLogger.logError('$TAG Payment processing failed: $e');
      _handleError(e.toString());
      return false;
    }
  }

  Future<bool> _processRazorpayPayment() async {
    AppLogger.logInfo('$TAG Processing Razorpay payment');

    final completer = Completer<bool>();

    await RazorpayUtility.openRazorpayCheckout(
      amount: widget.totalAmount.toString(),
      orderNumber: _orderNumber,
      onSuccess: (_) => completer.complete(true),
      onError: (e) => completer.completeError(e.message ?? 'Payment failed'),
      onExternalWallet: (_) {},
    );

    return completer.future;
  }

  Future<void> _createOrdersForRestaurant({
    required CustomerModel customer,
    required String restaurantName,
    required List<CartItem> items,
  }) async {
    AppLogger.logInfo('$TAG Creating orders for restaurant: $restaurantName');

    // 1. Create Payment Order
    final paymentOrderLines = _createPaymentOrderLines(items);
    final paymentOrder = await _paymentViewModel.createOrder(
      documentNo: _orderNumber,
      cSBunitID: widget.businessUnitId,
      dateOrdered: DateTime.now().toString(),
      discAmount: 0,
      grosstotal: widget.totalAmount,
      taxamt: widget.totalAmount * 0.05,
      mobileNo: customer.mobileNo ?? '',
      finPaymentmethodId: '5C2FB7612B5C48C9BF7ADB1C41D27849',
      isTaxIncluded: 'N',
      metaData: [OrderMetadata(key: "_dokan_vendor_id", value: "2")],
      lineItems: paymentOrderLines,
    );

    if (!paymentOrder) {
      throw Exception('Failed to create payment order');
    }

    // 2. Create Kitchen Order
    final kitchenOrderLines = _createKitchenOrderLines(items, restaurantName);
    final kitchenOrder = await _kitchenViewModel.createRedisOrder(
      customerId: customer.b2cCustomerId ?? '',
      documentNo: _orderNumber,
      cSBunitID: widget.businessUnitId,
      customerName: '${customer.firstName} ${customer.lastName}'.trim(),
      dateOrdered: DateTime.now().toString(),
      status: 'pending',
      lineItems: kitchenOrderLines,
    );

    if (!kitchenOrder) {
      throw Exception('Failed to create kitchen order');
    }
  }

// Helper methods for order creation
  List<PaymentOrderItem> _createPaymentOrderLines(List<CartItem> items) {
    AppLogger.logInfo('$TAG Creating payment order lines');

    return items.map((item) {
      // Convert string unitprice to num
      final unitPrice = num.tryParse(item.product.unitprice) ?? 0;
      final lineTotal = item.totalPrice; // Already num from CartItem
      final lineTax = lineTotal * 0.05; // Tax calculation
      final lineNet = lineTotal - lineTax;

      return PaymentOrderItem(
        mProductId: item.product.productId,
        name: item.product.name, // Explicitly set the product name
        qty: item.quantity.toInt(),
        unitprice: unitPrice,
        linenet: lineNet,
        linetax: lineTax,
        linegross: lineTotal,
        subProducts: item.selectedAddons.entries.expand((entry) {
          return entry.value.map((addon) => PaymentOrderAddon(
                addonProductId: item
                    .product.productId, // Use the mProductId as addonProductId
                name: addon.name,
                price: num.tryParse(addon.price) ?? 0,
                qty: 1,
              ));
        }).toList(),
      );
    }).toList();
  }

  List<KitchenOrderItem> _createKitchenOrderLines(
    List<CartItem> items,
    String restaurantName,
  ) {
    AppLogger.logInfo('$TAG Creating kitchen order lines for $restaurantName');

    int tokenCounter = 1;
    return items.map((item) {
      // Ensure product name is not empty
      final productName =
          item.product.name.isNotEmpty ? item.product.name : 'Unknown Product';

      return KitchenOrderItem(
        mProductId: item.product.productId,
        name: productName,
        qty: item.quantity.toInt(),
        notes: item.specialInstructions ??
            '', // Add special instructions if available
        productioncenter: restaurantName,
        tokenNumber: tokenCounter++,
        status: 'pending',
        subProducts: item.selectedAddons.entries.expand((entry) {
          return entry.value.map((addon) => KitchenOrderAddon(
                addonProductId: addon.id,
                name: addon.name.isNotEmpty ? addon.name : 'Unknown Addon',
                qty: 1,
              ));
        }).toList(),
      );
    }).toList();
  }

  Future<CustomerModel?> _getCustomerData() async {
    AppLogger.logInfo('$TAG Retrieving customer data');
    try {
      final userData = await AppPreference.getUserData();
      if (userData == null) return null;
      return CustomerModel.fromJson(userData);
    } catch (e) {
      AppLogger.logError('$TAG Error retrieving customer data: $e');
      return null;
    }
  }

  Future<void> _fetchWalletBalance(String customerId) async {
    AppLogger.logInfo('$TAG Fetching wallet balance for customer: $customerId');
    try {
      await Provider.of<WalletViewModel>(context, listen: false)
          .fetchWalletBalance(customerId);
    } catch (e) {
      AppLogger.logError('$TAG Error fetching wallet balance: $e');
    }
  }

  void _navigateToConfirmation() {
    AppLogger.logInfo('$TAG Navigating to confirmation screen');

    if (!mounted) return;

    // Get the latest payment order from the view model
    final paymentOrder = _paymentViewModel.order;

    if (paymentOrder == null) {
      AppLogger.logError('$TAG Payment order not found');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConfirmationDisplayScreen(order: paymentOrder.order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, walletViewModel, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalAmount(),
                const SizedBox(height: 24),
                Text('Choose Payment Method', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _buildPaymentMethods(walletViewModel),
                const Spacer(),
                _buildPayButton(), // Use the method
              ],
            ),
          );
        },
      ),
    );
  }

// UI Building Methods
  Widget _buildTotalAmount() {
    AppLogger.logDebug(
        '$TAG Building total amount display: ${widget.totalAmount}');

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromRGBO(225, 227, 242, 1),
            const Color.fromRGBO(237, 237, 241, 1),
            const Color.fromRGBO(225, 227, 242, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Amount', style: AppTextStyles.h2),
          Text(
            '₹${widget.totalAmount.toStringAsFixed(2)}',
            style: AppTextStyles.h1,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(WalletViewModel walletViewModel) {
    AppLogger.logDebug(
        '$TAG Building payment methods. Selected: $_selectedPaymentMethod');

    return Column(
      children: [
        PaymentMethodOption(
          title: 'Wallet',
          icon: Image.asset(
            'assets/images/ic_wallet.png',
            width: 80,
            height: 60,
          ),
          isSelected: _selectedPaymentMethod == 'Wallet',
          isWallet: true,
          isLoading: walletViewModel.isLoading || _isLoading,
          walletBalance: walletViewModel.walletBalance?.balanceAmt,
          onSelect: () => setState(() => _selectedPaymentMethod = 'Wallet'),
          onAddMoney: () => _handleAddMoneyToWallet(context),
        ),
        const SizedBox(height: 8),
        PaymentMethodOption(
          title: "Razorpay",
          icon: Image.asset(
            'assets/images/ic_razorpay.png',
            width: 80,
            height: 60,
          ),
          isSelected: _selectedPaymentMethod == 'Razorpay',
          onSelect: () => setState(() => _selectedPaymentMethod = 'Razorpay'),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    // Create a void callback that's always valid
    void handlePress() {
      if (!_isLoading && _selectedPaymentMethod.isNotEmpty) {
        _handlePayment();
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 60),
      child: CustomElevatedButton(
        onPressed: handlePress, // Always pass a valid callback
        color: (_isLoading || _selectedPaymentMethod.isEmpty)
            ? Colors.grey
            : Colors.deepOrangeAccent,
        text: _isLoading ? 'Processing...' : 'Pay Now',
      ),
    );
  }

  Future<void> _handleAddMoneyToWallet(BuildContext context) async {
    AppLogger.logInfo('$TAG Opening add money to wallet flow');

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletPaymentHandler(
            amount: widget.totalAmount,
            onComplete: (success) async {
              if (success) {
                await _refreshWalletBalance();
              }
            },
          ),
        ),
      );

      if (result == true) {
        await _refreshWalletBalance();
      }
    } catch (e) {
      AppLogger.logError('$TAG Error handling wallet payment: $e');
      _handleError('Error handling wallet payment: $e');
    }
  }

  Future<void> _refreshWalletBalance() async {
    AppLogger.logInfo('$TAG Refreshing wallet balance');

    try {
      final customer = await _getCustomerData();
      if (customer?.b2cCustomerId != null) {
        await Provider.of<WalletViewModel>(context, listen: false)
            .fetchWalletBalance(customer!.b2cCustomerId!);
      }
    } catch (e) {
      AppLogger.logError('$TAG Error refreshing wallet balance: $e');
      _handleError('Error refreshing wallet balance: $e');
    }
  }

  void _handleError(String message) {
    AppLogger.logError('$TAG Error: $message');
    _showMessage(message, isError: true);
  }

  void _showSuccess(String message) {
    AppLogger.logInfo('$TAG Success: $message');
    _showMessage(message);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.black,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
