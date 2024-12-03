// VerifyService.dart
import 'package:dio/dio.dart';

import '../../../../common/log/loggers.dart';
import '../../../../core/api/api_base_service.dart';
import '../../../../core/api/api_url_manager.dart';
import '../model/verify_model.dart';

class VerifyService {
  final ApiBaseService _apiBaseService;

  VerifyService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  Future<CustomerModel> verifyCustomer(String phoneNumber) async {
    try {
      AppLogger.logInfo('Sending REST request to verify customer...');
      AppLogger.logInfo('Verifying customer with phone number: $phoneNumber');

      // Properly encode the phone number for URL
      final encodedPhoneNumber = Uri.encodeQueryComponent(phoneNumber);

      // First check if user exists using the getCustomerByPhone endpoint
      final String verifyUrl =
          '${AppUrls.verifyCustomer}?mobile_number=$encodedPhoneNumber';

      // First check if user exists using the getCustomerByPhone endpoint
      // final String customerCheckUrl =
      //     '${AppUrls.verifyCustomer}?mobile_number=$phoneNumber';

      AppLogger.logInfo('Verifying customer...');
      final result = await _apiBaseService.sendRestRequest(
        method: 'GET',
        body: null,
        endpoint: verifyUrl,
      );

      AppLogger.logDebug('Verification response: $result');

      // If customer exists in database
      // Check if we have a valid response
      if (result != null &&
          result['data'] != null &&
          result['data']['verifyCustomer'] != null) {
        var customerData = result['data']['verifyCustomer'];

        AppLogger.logInfo('Existing customer data: $customerData');

        return CustomerModel(
          otp: customerData['otp'] ?? 0,
          token: customerData['token'],
          b2cCustomerId: customerData['b2cCustomerId'],
          // If b2cCustomerId exists and newCustomer is false, this is an existing customer
          newCustomer: customerData['b2cCustomerId'] == null ||
              customerData['newCustomer'] == true,
          mobileNo: phoneNumber,
          firstName: customerData['firstName'],
          lastName: customerData['lastName'],
          email: customerData['email'],
          walletId: customerData['walletId'],
        );
      }

      // If we reach here, something went wrong with the response format
      throw Exception('Invalid response format from server');
    } on DioException catch (e) {
      AppLogger.logError('Network error in verifyCustomer: ${e.message}');
      AppLogger.logError('Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      AppLogger.logError('Error in verifyCustomer: $e');
      rethrow;
    }
  }
}
