import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../common/log/loggers.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../data/db/app_preferences.dart';
import '../../auth/verify/model/verify_model.dart';
import '../../payment/service/razorpay_service.dart';
import '../viewmodel/wallet_viewmodel.dart';
import '../widgets/wallet_balance_card.dart';

class WalletPaymentHandler extends StatefulWidget {
  final double amount;
  final Function(bool success) onComplete;

  const WalletPaymentHandler({
    super.key,
    required this.amount,
    required this.onComplete,
  });

  @override
  State<WalletPaymentHandler> createState() => _WalletPaymentHandlerState();
}

class _WalletPaymentHandlerState extends State<WalletPaymentHandler> {
  // Core state management
  late final WalletViewModel _viewModel;
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  double _trxValue = 0; // Single source of truth for transaction amount

  /// Initialize state and begin payment flow
  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<WalletViewModel>(context, listen: false);
    _initializeAmount();
    _fetchWalletBalance();
  }

  /// Set initial amount values
  void _initializeAmount() {
    _trxValue = widget.amount;
    _amountController.text = _trxValue.toString();
    AppLogger.logInfo('Initialized transaction value: $_trxValue');
  }

  /// Fetch current wallet balance
  /// Flow: Local Storage -> Customer Model -> Fetch Balance
  Future<void> _fetchWalletBalance() async {
    try {
      // Get customer ID
      final userData = await AppPreference.getUserData();
      final customer = CustomerModel.fromJson(userData);

      if (customer.b2cCustomerId != null) {
        // Fetch balance directly through viewmodel
        await _viewModel.fetchWalletBalance(customer.b2cCustomerId!);
      }
    } catch (e) {
      _handleError('Error fetching wallet balance: $e');
    }
  }

  /// Main build method - Constructs the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current balance display
                WalletBalanceCard(
                  walletBalance: viewModel.walletBalance,
                  isLoading: viewModel.isLoading,
                ),
                const SizedBox(height: 40),
                Card(
                  color: Colors.white,
                  elevation:
                      4, // You can adjust the elevation for a shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Optional: rounded corners
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(8.0), // Padding inside the card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text('Topup Wallet', style: AppTextStyles.h3),
                        ),
                        const SizedBox(height: 60),
                        _buildCustomAmountField(),
                        const SizedBox(height: 16),
                        // Amount selection options
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Opt2: Recommended',
                              style: AppTextStyles.h6),
                        ),
                        _buildAmountOptions(),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                _buildAddMoneyButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Quick amount selection buttons
  Widget _buildAmountOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [100, 200, 500, 1000].map((amount) {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _trxValue = amount.toDouble();
              _amountController.text = amount.toString();
              AppLogger.logInfo('Selected transaction value: ₹$_trxValue');
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _trxValue == amount
                ? Color.fromRGBO(55, 84, 211, 1) // Selected background color
                : Colors.white, // Not selected background color
            foregroundColor: _trxValue == amount
                ? Colors.white // Selected text color (white)
                : Color.fromRGBO(55, 84, 211,
                    1), // Not selected text color (same as background)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // Reduced border radius
            ),
            padding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 16), // Reduced padding
          ),
          child: Text('₹$amount'),
        );
      }).toList(),
    );
  }

  /// Custom amount input field
  Widget _buildCustomAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Opt1: Enter Amount',
        hintText: 'Enter Amount', // Added hint text
        border: OutlineInputBorder(),
        prefixText: '₹',
      ),
      onChanged: (value) {
        setState(() {
          _trxValue = double.tryParse(value) ?? 0;
          AppLogger.logInfo('Custom transaction value entered: ₹$_trxValue');
        });
      },
    );
  }

  /// Primary action button
  Widget _buildAddMoneyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleAddMoney(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: const Text(
            'Add Money',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Primary flow handler for adding money
  /// Flow: Validate -> Get Customer -> Initialize Payment
  void _handleAddMoney(BuildContext context) async {
    // 1. Validate Amount
    if (!_validateAmount()) return;

    // 2. Get User Data
    final customer = await _getCustomerData();
    if (customer == null) {
      _handleError('Customer data not found');
      return;
    }

    // 3. Initialize Payment
    _initiateRazorpayPayment(customer);
  }

  /// Amount validation with user feedback
  bool _validateAmount() {
    if (_trxValue <= 0) {
      AppLogger.logWarning('Invalid amount entered: $_trxValue');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return false;
    }
    return true;
  }

  /// Retrieve and validate customer data
  Future<CustomerModel?> _getCustomerData() async {
    try {
      final userData = await AppPreference.getUserData();
      if (userData == null) return null;

      final customer = CustomerModel.fromJson(userData);
      if (customer.b2cCustomerId?.isEmpty ?? true) {
        _handleError('Invalid customer ID');
        return null;
      }

      return customer;
    } catch (e) {
      AppLogger.logError('Error retrieving customer data: $e');
      return null;
    }
  }

  /// Initialize Razorpay payment flow
  void _initiateRazorpayPayment(CustomerModel customer) {
    AppLogger.logInfo(
        'Initiating Razorpay payment with transaction value: $_trxValue');

    RazorpayUtility.openRazorpayCheckout(
      amount: _trxValue.toString(), // Use current transaction value
      onSuccess: (response) => _processPaymentSuccess(customer, response),
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
      orderNumber: '',
    );
  }

  /// Handle successful payment
  /// Flow: Payment Success -> Update Wallet -> Update UI
  Future<void> _processPaymentSuccess(
    CustomerModel customer,
    PaymentSuccessResponse response,
  ) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      AppLogger.logInfo('Processing payment: Amount: $_trxValue');

      // Add money to wallet through viewmodel
      final result = await _viewModel.addMoneyToWallet(
        customer.b2cCustomerId!,
        _trxValue,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Wallet update failed');
      }

      // Save transaction info
      await _updatePaymentInfo(
        paymentId: response.paymentId!,
        walletId: result.walletId!,
        amount: _trxValue,
        balance: result.balance!,
      );

      AppLogger.logInfo(
          '[WalletPaymentHandler] Updated balance after payment: ${result.balance}');

      _showSuccess('Added ₹$_trxValue to wallet successfully');
      widget.onComplete(true);
    } catch (e) {
      _handleError('Payment processing failed: $e');
      widget.onComplete(false);
    } finally {
      setState(() => _isProcessing = false);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Update local storage with payment information
  Future<void> _updatePaymentInfo({
    required String paymentId,
    required String walletId,
    required double amount,
    required double balance,
  }) async {
    try {
      // Save the wallet ID first
      await AppPreference.saveWalletId(walletId);

      // Update user data
      final userData = await AppPreference.getUserData() ?? {};
      final updatedData = {
        ...userData,
        'lastPaymentId': paymentId,
        'walletId': walletId,
        'walletBalance': balance.toString(), // Make sure we store as string
        'lastTransaction': {
          'type': 'CR',
          'value': amount,
          'timestamp': DateTime.now().toIso8601String(),
        }
      };

      await AppPreference.saveUserData(updatedData);
      AppLogger.logInfo('Payment info updated. New balance: $balance');
    } catch (e) {
      AppLogger.logError('Error updating payment info: $e');
      throw Exception('Failed to update payment information');
    }
  }

  /// Handle payment failures
  void _handlePaymentError(PaymentFailureResponse response) {
    _handleError('Payment failed: ${response.message}');
    widget.onComplete(false);
    Navigator.of(context).pop();
  }

  /// Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.logInfo('External wallet selected: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  /// Success feedback to user
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Error handling and user feedback
  void _handleError(String message) {
    AppLogger.logError(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
