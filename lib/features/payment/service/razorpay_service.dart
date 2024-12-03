import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../common/log/loggers.dart';
import '../../../data/db/app_preferences.dart';

class RazorpayUtility {
  static const String TAG = '[RazorpayUtility]';

  static Future<void> openRazorpayCheckout({
    required String amount,
    required String orderNumber,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) async {
    AppLogger.logInfo('$TAG Opening Razorpay checkout');
    AppLogger.logDebug('$TAG Amount: $amount, OrderNumber: $orderNumber');

    // Fetch user data from preferences
    final userData = await AppPreference.getUserData();
    final phone = userData['phone'] ?? '';
    final email = userData['email'] ?? '';
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';

    AppLogger.logInfo(
        '$TAG Using saved user data - Phone: $phone, Email: $email');

    final razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      AppLogger.logInfo(
          '$TAG Payment success callback. OrderNumber: $orderNumber');
      onSuccess(response as PaymentSuccessResponse);
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      AppLogger.logError(
          '$TAG Payment error callback. OrderNumber: $orderNumber');
      onError(response as PaymentFailureResponse);
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

    var options = {
      'key': 'rzp_test_rJaKntRigIdq6s',
      'amount': (double.parse(amount) * 100).toInt(),
      'name': 'CW Food ordering',
      'description': 'Order: $orderNumber',
      'prefill': {
        'contact':
            phone.replaceAll('+91', ''), // Remove country code if present
        'email': email,
        'name': '$firstName $lastName'.trim(),
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    AppLogger.logDebug('$TAG Razorpay options configured: $options');

    try {
      razorpay.open(options);
      AppLogger.logInfo('$TAG Razorpay checkout opened with user data');
    } catch (e) {
      AppLogger.logError('$TAG Error opening Razorpay: $e');
      throw e;
    }
  }
}
