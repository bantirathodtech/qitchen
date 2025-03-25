// lib/features/order_shared_common/ui/screens/payment_screen.dart

import 'dart:async';
import 'package:cw_food_ordering/features/ordering/kicken_order/viewmodel/kitchen_order_viewmodel.dart';
import 'package:cw_food_ordering/features/ordering/order_shared_common/service/payment_method_option.dart';
import 'package:cw_food_ordering/features/ordering/order_shared_common/utils/order_number_generator.dart';
import 'package:cw_food_ordering/features/ordering/sales_order/viewmodel/payment_order_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/log/loggers.dart';
import '../../../common/styles/ElevatedButton.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../data/db/app_preferences.dart';
import '../../auth/verify/model/verify_model.dart';
import '../../cart/multiple/cart_manager.dart';
import '../wallet/view/wallet_view.dart';
import '../wallet/viewmodel/wallet_viewmodel.dart';
import '../kicken_order/model/kitchen_order.dart';
import '../sales_order/model/payment_order.dart';

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
                // _buildPayButton(), // Use the method
                _buildSelectButton(), // Changed from Pay Now to Select button

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

  Widget _buildSelectButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      child: CustomElevatedButton(
        onPressed: () {
          if (_selectedPaymentMethod.isNotEmpty) {
            Navigator.pop(context, _selectedPaymentMethod);
          } else {
            _showMessage('Please select a payment method');
          }
        },
        color: _selectedPaymentMethod.isEmpty ? Colors.grey : Colors.black,
        text: 'Select Payment Method',
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
