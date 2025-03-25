import 'dart:async';
import 'package:cw_food_ordering/features/ordering/order_shared_common/service/razorpay_service.dart';
import 'package:cw_food_ordering/features/ordering/order_shared_common/utils/order_number_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Added for PaymentSuccessResponse
import '../../../common/log/loggers.dart';
import '../../../data/db/app_preferences.dart';
import '../../auth/verify/model/verify_model.dart';
import '../../cart/models/cart_item.dart';
import '../../store/provider/store_provider.dart';
import '../wallet/viewmodel/wallet_viewmodel.dart';
import '../kicken_order/model/kitchen_order.dart';
import '../sales_order/model/payment_order.dart';
import 'ui/screens/confirmation_display_screen.dart';
import '../kicken_order/viewmodel/kitchen_order_viewmodel.dart';
import '../sales_order/viewmodel/payment_order_viewmodel.dart';

class PaymentProcessor {
  static const String TAG = '[PaymentProcessor]';

  // Step 1: Main payment processing method
  static Future<void> processPayment({
    required BuildContext context,
    required String selectedPaymentMethod,
    required double totalAmount,
    required String businessUnitId,
    required Map<String, List<CartItem>> cartItemsByRestaurant,
    required Function() clearCart,
    required Function(String, {bool isError}) showMessage,
  }) async {
    AppLogger.logInfo('$TAG Starting payment process for method: $selectedPaymentMethod, Total: $totalAmount');

    // Step 1.1: Validate payment method
    if (selectedPaymentMethod.isEmpty) {
      showMessage('Please select a payment method', isError: true);
      return;
    }

    try {
      // Step 1.2: Fetch customer data
      final customer = await _getCustomerData();
      if (customer == null) throw Exception('User data not found');

      // Step 1.3: Process payment and get transaction details
      String? transactionId;
      bool paymentSuccess = false;
      switch (selectedPaymentMethod) {
        case 'Wallet':
          paymentSuccess = await _processWalletPayment(context, customer, totalAmount);
          transactionId = customer.b2cCustomerId ?? 'WALLET_DEFAULT'; // Wallet ID as transaction ID
          break;
        case 'Razorpay':
          final result = await _processRazorpayPayment(totalAmount);
          paymentSuccess = result.success;
          transactionId = result.transactionId;
          break;
        default:
          throw Exception('Invalid payment method');
      }

      if (!paymentSuccess) throw Exception('Payment failed');

      // Step 1.4: Create orders with transaction ID
      await _createSingleOrderForCart(
        context: context,
        customer: customer,
        cartItemsByRestaurant: cartItemsByRestaurant,
        primaryBusinessUnitId: businessUnitId,
        selectedPaymentMethod: selectedPaymentMethod,
        transactionId: transactionId,
      );

      // Step 1.5: Clear cart and notify user
      clearCart();
      showMessage('Payment successful! Order placed.');
      _navigateToConfirmation(context);
    } catch (e) {
      AppLogger.logError('$TAG Payment processing failed: $e');
      showMessage('Payment failed: $e', isError: true);
      rethrow;
    }
  }

  // Step 2: Process Wallet Payment
  static Future<bool> _processWalletPayment(BuildContext context, CustomerModel customer, double amount) async {
    AppLogger.logInfo('$TAG Processing wallet payment for amount: $amount');
    try {
      if (customer.b2cCustomerId == null) throw Exception('Customer ID not found');
      final walletViewModel = Provider.of<WalletViewModel>(context, listen: false);
      final balance = walletViewModel.walletBalance?.balanceAmt ?? 0;
      if (balance < amount) throw Exception('Insufficient wallet balance');
      final orderNumber = OrderNumberGenerator.generateOrderNumber();
      final result = await walletViewModel.spendFromWallet(customer.b2cCustomerId!, amount, orderNumber);
      if (!result.success) throw Exception(result.error ?? 'Wallet transaction failed');
      AppLogger.logInfo('$TAG Wallet payment successful');
      return true;
    } catch (e) {
      AppLogger.logError('$TAG Wallet payment failed: $e');
      return false;
    }
  }

  // Step 3: Process Razorpay Payment (Updated for PaymentSuccessResponse)
  static Future<({bool success, String? transactionId})> _processRazorpayPayment(double amount) async {
    AppLogger.logInfo('$TAG Processing Razorpay payment for amount: $amount');
    final completer = Completer<({bool success, String? transactionId})>();
    final orderNumber = OrderNumberGenerator.generateOrderNumber();
    await RazorpayUtility.openRazorpayCheckout(
      amount: amount.toString(),
      orderNumber: orderNumber,
      onSuccess: (PaymentSuccessResponse response) {
        final paymentId = response.paymentId; // Extract paymentId from PaymentSuccessResponse
        AppLogger.logInfo('$TAG Razorpay payment successful, Payment ID: $paymentId');
        completer.complete((success: true, transactionId: paymentId));
      },
      onError: (e) {
        AppLogger.logError('$TAG Razorpay payment failed: ${e.message}');
        completer.complete((success: false, transactionId: null));
      },
      onExternalWallet: (_) {
        completer.complete((success: true, transactionId: 'EXTERNAL_WALLET_$orderNumber'));
      },
    );
    return completer.future;
  }

  // Step 4: Create Single Order for Multi-Restaurant Cart
  static Future<void> _createSingleOrderForCart({
    required BuildContext context,
    required CustomerModel customer,
    required Map<String, List<CartItem>> cartItemsByRestaurant,
    required String primaryBusinessUnitId,
    required String selectedPaymentMethod,
    String? transactionId,
  }) async {
    // Step 4.1: Log the start of the order_shared_common creation process
    AppLogger.logInfo('$TAG Creating single order_shared_common for cart with ${cartItemsByRestaurant.length} restaurants');

    // Step 4.2: Fetch view models and generate order_shared_common number
    final paymentViewModel = Provider.of<PaymentOrderViewModel>(context, listen: false);
    final kitchenViewModel = Provider.of<KitchenOrderViewModel>(context, listen: false);
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final orderNumber = OrderNumberGenerator.generateOrderNumber();

    // Step 4.3: Calculate total amount and tax
    final totalAmount = cartItemsByRestaurant.values
        .expand((items) => items)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
    final taxAmount = totalAmount * 0.05;

    // Step 4.4: Determine primary csBunitId with fallback
    final firstRestaurantName = cartItemsByRestaurant.keys.first;
    final restaurant = storeProvider.storeData?.restaurants.firstWhere(
          (r) => r.name == firstRestaurantName,
      orElse: () => throw Exception('Restaurant $firstRestaurantName not found'),
    );
    final validBusinessUnitId = restaurant?.businessUnit?.csBunitId ?? primaryBusinessUnitId;
    AppLogger.logDebug('$TAG Using csBunitId: $validBusinessUnitId for order_shared_common');

    // Step 4.5: Prepare metadata for multi-restaurant order_shared_common and transaction
    final restaurantMetadata = cartItemsByRestaurant.keys.map((restaurantName) {
      final restaurantData = storeProvider.storeData?.restaurants.firstWhere(
            (r) => r.name == restaurantName,
        orElse: () => throw Exception('Restaurant $restaurantName not found'),
      );
      final csBunitId = restaurantData?.businessUnit?.csBunitId ?? primaryBusinessUnitId;
      return OrderMetadata(key: 'restaurant_${restaurantName}_bunit', value: csBunitId);
    }).toList();

    if (transactionId != null) {
      restaurantMetadata.add(OrderMetadata(key: 'transaction_id', value: transactionId));
    }

    // Step 4.6: Create payment order_shared_common lines
    final paymentOrderLines = cartItemsByRestaurant.entries.expand((entry) {
      return _createPaymentOrderLines(entry.value, entry.key);
    }).toList();

    // Step 4.7: Use hardcoded finPaymentmethodId
    const finPaymentmethodId = 'A9902C9C194D4EAEA39ECE0D38F2F995';
    AppLogger.logDebug('$TAG Using hardcoded finPaymentmethodId: $finPaymentmethodId');

    // Step 4.8: Create payment order_shared_common
    final paymentOrder = await paymentViewModel.createOrder(
      documentNo: orderNumber,
      cSBunitID: validBusinessUnitId,
      dateOrdered: DateTime.now().toIso8601String(),
      discAmount: 0,
      grosstotal: totalAmount,
      taxamt: taxAmount,
      mobileNo: customer.mobileNo ?? '',
      finPaymentmethodId: finPaymentmethodId,
      isTaxIncluded: 'N',
      metaData: [
        OrderMetadata(key: "_dokan_vendor_id", value: "2"),
        ...restaurantMetadata,
      ],
      lineItems: paymentOrderLines,
    );

    if (!paymentOrder) throw Exception('Failed to create payment order_shared_common');
    AppLogger.logInfo('$TAG Payment order_shared_common created successfully: $orderNumber');

    // Step 4.9: Create kitchen order_shared_common lines
    final kitchenOrderLines = cartItemsByRestaurant.entries.expand((entry) {
      return entry.value.map((item) => KitchenOrderItem(
        mProductId: item.product.productId,
        name: item.product.name,
        qty: item.quantity.toInt(), // Converts double to int
        notes: item.specialInstructions ?? '',
        productioncenter: entry.key,
        tokenNumber: 1, // Hardcoded int
        status: 'pending',
        subProducts: item.selectedAddons.entries.expand((addonEntry) {
          return addonEntry.value.map((addon) => KitchenOrderAddon(
            addonProductId: addon.id,
            name: addon.name,
            qty: 1, // Ensure int
          ));
        }).toList(),
      ));
    }).toList();

    // Step 4.10: Log kitchen order_shared_common lines for debugging
    AppLogger.logDebug('$TAG Kitchen order_shared_common lines: ${kitchenOrderLines.map((l) => l.toJson())}');

    // Step 4.11: Create kitchen order_shared_common
    final kitchenOrder = await kitchenViewModel.createRedisOrder(
      customerId: customer.b2cCustomerId ?? '',
      documentNo: orderNumber,
      cSBunitID: validBusinessUnitId,
      customerName: '${customer.firstName} ${customer.lastName}'.trim(),
      dateOrdered: DateTime.now().toIso8601String(),
      status: 'pending',
      lineItems: kitchenOrderLines,
    );

    if (!kitchenOrder) throw Exception('Failed to create kitchen order_shared_common');
    AppLogger.logInfo('$TAG Kitchen order_shared_common created successfully: $orderNumber');
  }

  // Step 5: Create Payment Order Lines
  static List<PaymentOrderItem> _createPaymentOrderLines(List<CartItem> items, String restaurantName) {
    AppLogger.logDebug('$TAG Creating payment order_shared_common lines for restaurant: $restaurantName');
    return items.map((item) {
      final unitPrice = num.tryParse(item.product.unitprice) ?? 0;
      final lineTotal = item.totalPrice;
      final lineTax = lineTotal * 0.05;
      final lineNet = lineTotal - lineTax;

      return PaymentOrderItem(
        mProductId: item.product.productId,
        name: item.product.name,
        qty: item.quantity.toInt(),
        unitprice: unitPrice,
        linenet: lineNet,
        linetax: lineTax,
        linegross: lineTotal,
        productioncenter: restaurantName,
        subProducts: item.selectedAddons.entries.expand((entry) {
          return entry.value.map((addon) => PaymentOrderAddon(
            addonProductId: addon.id,
            name: addon.name,
            price: num.tryParse(addon.price) ?? 0,
            qty: 1,
          ));
        }).toList(),
      );
    }).toList();
  }

  // Step 6: Fetch Customer Data
  static Future<CustomerModel?> _getCustomerData() async {
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

  // Step 7: Navigate to Confirmation Screen
  static void _navigateToConfirmation(BuildContext context) {
    AppLogger.logInfo('$TAG Navigating to confirmation screen');
    final paymentViewModel = Provider.of<PaymentOrderViewModel>(context, listen: false);
    final paymentOrder = paymentViewModel.order;
    if (paymentOrder == null) {
      AppLogger.logError('$TAG Payment order_shared_common not found');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationDisplayScreen(order: paymentOrder.order),
      ),
    );
  }
}