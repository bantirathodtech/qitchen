// VerifyService.dart with optimized performance and fixed user verification
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
      AppLogger.logInfo('Verifying customer with mobile number: $phoneNumber');

      // Properly encode the phone number for URL
      final encodedPhoneNumber = Uri.encodeQueryComponent(phoneNumber);
      final String verifyUrl = '${AppUrls.verifyCustomer}?mobile_number=$encodedPhoneNumber';

      // Log the exact URL we're hitting for debugging
      AppLogger.logDebug('Verification URL: $verifyUrl');

      // Make the API call with a quick timeout
      final result = await _apiBaseService.sendRestRequest(
        method: 'GET',
        body: null,
        endpoint: verifyUrl,
        timeout: const Duration(seconds: 4),
      );

      // Log the raw API response
      AppLogger.logDebug('Raw API response: $result');

      // Default to new user if we can't verify
      CustomerModel defaultCustomerModel = CustomerModel(
        mobileNo: phoneNumber, // Ensure mobile number is included
        newCustomer: true,     // Default to treating as new user
      );

      // Quick check for empty or null result
      if (result == null) {
        AppLogger.logWarning('API response was null for phone $phoneNumber. Using default values.');
        return defaultCustomerModel;
      }

      // Simplified parsing logic - faster execution
      if (result is Map && result.containsKey('data')) {
        var data = result['data'];

        // Handle the most common response structure first
        if (data is Map && data.containsKey('verifyCustomer')) {
          var customerData = data['verifyCustomer'];

          // Add detailed logging for the customer data
          AppLogger.logInfo('Customer data for $phoneNumber: $customerData');

          if (customerData is Map) {
            return _createCustomerModel(customerData, phoneNumber);
          }
        }
        // Direct data format - second most common
        else if (data is Map) {
          AppLogger.logInfo('Data directly in the data field for $phoneNumber: $data');
          return _createCustomerModel(data, phoneNumber);
        }
        // List format - rare but possible
        else if (data is List && data.isNotEmpty && data[0] is Map) {
          AppLogger.logInfo('Data in list format for $phoneNumber: ${data[0]}');
          return _createCustomerModel(data[0], phoneNumber);
        }
      }

      // If we couldn't parse properly, return default model
      AppLogger.logWarning('Could not parse data properly for $phoneNumber. Using default values.');
      return defaultCustomerModel;
    } on DioException catch (e) {
      AppLogger.logError('Network error in verifyCustomer for $phoneNumber: ${e.message}');
      // Return default model instead of throwing error
      return CustomerModel(
        mobileNo: phoneNumber,
        newCustomer: true,
      );
    } catch (e) {
      AppLogger.logError('Error in verifyCustomer for $phoneNumber: $e');
      // Return default model instead of throwing error
      return CustomerModel(
        mobileNo: phoneNumber,
        newCustomer: true,
      );
    }
  }

  // Helper method to create customer model from data - reduces code duplication
// Add this improved method to your VerifyService class
  CustomerModel _createCustomerModel(Map customerData, String phoneNumber) {
    // Log raw values for debugging
    AppLogger.logInfo('VERIFY RESPONSE RAW DATA: ' +
        'b2cCustomerId: ${customerData['b2cCustomerId']}, ' +
        'newCustomer: ${customerData['newCustomer']}, ' +
        'type of newCustomer: ${customerData['newCustomer'].runtimeType}');

    // More robust check for existing users that handles various data types
    bool isExistingUser = false;

    // First check if b2cCustomerId exists (not null and not empty string)
    bool hasCustomerId = customerData['b2cCustomerId'] != null &&
        customerData['b2cCustomerId'].toString().isNotEmpty;

    // Then check if newCustomer is false (handling different possible formats)
    bool isMarkedAsExisting = false;
    var newCustomerValue = customerData['newCustomer'];

    if (newCustomerValue != null) {
      if (newCustomerValue is bool) {
        isMarkedAsExisting = newCustomerValue == false;
      } else if (newCustomerValue is String) {
        isMarkedAsExisting = newCustomerValue.toLowerCase() == 'false' ||
            newCustomerValue == '0';
      } else if (newCustomerValue is num) {
        isMarkedAsExisting = newCustomerValue == 0;
      }
    }

    // A user is existing only if they have an ID AND are marked as not new
    isExistingUser = hasCustomerId && isMarkedAsExisting;

    AppLogger.logInfo('VERIFICATION RESULT FOR $phoneNumber: hasCustomerId: $hasCustomerId, isMarkedAsExisting: $isMarkedAsExisting, FINAL DETERMINATION: ${isExistingUser ? 'EXISTING USER' : 'NEW USER'}');

    // Create the model with the determined user type
    return CustomerModel(
      otp: customerData['otp'] is int ? customerData['otp'] : 0,
      token: customerData['token']?.toString(),
      b2cCustomerId: customerData['b2cCustomerId']?.toString(),
      newCustomer: !isExistingUser,  // False means existing user
      mobileNo: phoneNumber,
      firstName: customerData['firstName']?.toString(),
      lastName: customerData['lastName']?.toString(),
      email: customerData['email']?.toString(),
      walletId: customerData['walletId']?.toString(),
    );
  }
}
