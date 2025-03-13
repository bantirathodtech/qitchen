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

  // Future<CustomerModel> verifyCustomer(String phoneNumber) async {
  //   try {
  //     AppLogger.logInfo('Sending REST request to verify customer...');
  //     AppLogger.logInfo('Verifying customer with phone number: $phoneNumber');
  //
  //     // Properly encode the phone number for URL
  //     final encodedPhoneNumber = Uri.encodeQueryComponent(phoneNumber);
  //
  //     // First check if user exists using the getCustomerByPhone endpoint
  //     final String verifyUrl =
  //         '${AppUrls.verifyCustomer}?mobile_number=$encodedPhoneNumber';
  //
  //     // First check if user exists using the getCustomerByPhone endpoint
  //     // final String customerCheckUrl =
  //     //     '${AppUrls.verifyCustomer}?mobile_number=$phoneNumber';
  //
  //     AppLogger.logInfo('Verifying customer...');
  //     final result = await _apiBaseService.sendRestRequest(
  //       method: 'GET',
  //       body: null,
  //       endpoint: verifyUrl,
  //     );
  //     AppLogger.logDebug('Raw response: ${result.toString()}');
  //     AppLogger.logDebug('Verification response: $result');
  //
  //     // // If customer exists in database
  //     // // Check if we have a valid response
  //     // if (result != null &&
  //     //     result['data'] != null &&
  //     //     result['data']['verifyCustomer'] != null) {
  //     //
  //     //
  //     //   var customerData = result['data']['verifyCustomer'];
  //     //   AppLogger.logDebug('Raw response: ${result.toString()}');
  //     //   AppLogger.logInfo('Existing customer data: $customerData');
  //     //
  //     //   return CustomerModel(
  //     //     otp: customerData['otp'] ?? 0,
  //     //     token: customerData['token'],
  //     //     b2cCustomerId: customerData['b2cCustomerId'],
  //     //     // If b2cCustomerId exists and newCustomer is false, this is an existing customer
  //     //     newCustomer: customerData['b2cCustomerId'] == null ||
  //     //         customerData['newCustomer'] == true,
  //     //     mobileNo: phoneNumber,
  //     //     firstName: customerData['firstName'],
  //     //     lastName: customerData['lastName'],
  //     //     email: customerData['email'],
  //     //     walletId: customerData['walletId'],
  //     //   );
  //     // }
  //
  //     // First check if we have a valid response
  //     if (result != null && result['data'] != null) {
  //       // Check different possible response structures
  //       var customerData;
  //       if (result['data'] is Map && result['data']['verifyCustomer'] != null) {
  //         customerData = result['data']['verifyCustomer'];
  //       } else if (result['data'] is Map && result['data'] is! List) {
  //         // If data is directly a customer object
  //         customerData = result['data'];
  //       } else {
  //         throw Exception('Unexpected response format: ${result.toString()}');
  //       }
  //
  //       AppLogger.logInfo('Existing customer data: $customerData');
  //
  //       return CustomerModel(
  //         otp: customerData['otp'] is int ? customerData['otp'] : 0,
  //         token: customerData['token']?.toString(),
  //         b2cCustomerId: customerData['b2cCustomerId']?.toString(),
  //         newCustomer: customerData['b2cCustomerId'] == null || customerData['newCustomer'] == true,
  //         mobileNo: phoneNumber,
  //         firstName: customerData['firstName']?.toString(),
  //         lastName: customerData['lastName']?.toString(),
  //         email: customerData['email']?.toString(),
  //         walletId: customerData['walletId']?.toString(),
  //       );
  //     }
  //
  //     // If we reach here, something went wrong with the response format
  //     throw Exception('Invalid response format from server');
  //   } on DioException catch (e) {
  //     AppLogger.logError('Network error in verifyCustomer: ${e.message}');
  //     AppLogger.logError('Response data: ${e.response?.data}');
  //     rethrow;
  //   } catch (e) {
  //     AppLogger.logError('Error in verifyCustomer: $e');
  //     rethrow;
  //   }
  // }

  Future<CustomerModel> verifyCustomer(String phoneNumber) async {
    try {
      AppLogger.logInfo('Sending REST request to verify customer...');
      AppLogger.logInfo('Verifying customer with phone number: $phoneNumber');

      // Properly encode the phone number for URL
      final encodedPhoneNumber = Uri.encodeQueryComponent(phoneNumber);
      final String verifyUrl = '${AppUrls.verifyCustomer}?mobile_number=$encodedPhoneNumber';

      AppLogger.logInfo('Verifying customer...');
      final result = await _apiBaseService.sendRestRequest(
        method: 'GET',
        body: null,
        endpoint: verifyUrl,
      );

      // Add these debug logs right after getting the result
      AppLogger.logDebug('Raw API response: ${result.toString()}');
      AppLogger.logDebug('Response type: ${result.runtimeType}');

      if (result is Map) {
        AppLogger.logDebug('Result keys: ${result.keys.toList()}');
        if (result.containsKey('data')) {
          AppLogger.logDebug('Data type: ${result['data'].runtimeType}');

          if (result['data'] is Map) {
            AppLogger.logDebug('Data keys: ${(result['data'] as Map).keys.toList()}');
          } else if (result['data'] is List) {
            AppLogger.logDebug('Data is a List with length: ${(result['data'] as List).length}');
            if ((result['data'] as List).isNotEmpty) {
              AppLogger.logDebug('First item type: ${(result['data'] as List)[0].runtimeType}');
            }
          } else if (result['data'] is String) {
            AppLogger.logDebug('Data is a String: ${result['data']}');
          } else {
            AppLogger.logDebug('Data is neither Map, List, nor String: ${result['data']}');
          }
        }
      }

      // Create a default customer model with the phone number as fallback
      CustomerModel defaultCustomerModel = CustomerModel(
        mobileNo: phoneNumber,
        newCustomer: true,
      );

      // First check if we have a valid response
      if (result != null) {
        // Try to parse the response data
        if (result is Map && result.containsKey('data')) {
          var data = result['data'];

          // Handle different response structures
          if (data is Map && data.containsKey('verifyCustomer')) {
            var customerData = data['verifyCustomer'];
            AppLogger.logDebug('Customer data: $customerData');

            if (customerData is Map) {
              return CustomerModel(
                otp: customerData['otp'] is int ? customerData['otp'] : 0,
                token: customerData['token']?.toString(),
                b2cCustomerId: customerData['b2cCustomerId']?.toString(),
                newCustomer: customerData['b2cCustomerId'] == null || customerData['newCustomer'] == true,
                mobileNo: phoneNumber,
                firstName: customerData['firstName']?.toString(),
                lastName: customerData['lastName']?.toString(),
                email: customerData['email']?.toString(),
                walletId: customerData['walletId']?.toString(),
              );
            }
          } else if (data is Map) {
            // Direct data format
            AppLogger.logDebug('Direct data format: $data');

            return CustomerModel(
              otp: data['otp'] is int ? data['otp'] : 0,
              token: data['token']?.toString(),
              b2cCustomerId: data['b2cCustomerId']?.toString(),
              newCustomer: data['b2cCustomerId'] == null || data['newCustomer'] == true,
              mobileNo: phoneNumber,
              firstName: data['firstName']?.toString(),
              lastName: data['lastName']?.toString(),
              email: data['email']?.toString(),
              walletId: data['walletId']?.toString(),
            );
          } else if (data is List && data.isNotEmpty) {
            // List format - take first item
            var customerData = data[0]; // This is where the error is likely occurring
            AppLogger.logDebug('List data format, first item: $customerData');

            if (customerData is Map) {
              return CustomerModel(
                otp: customerData['otp'] is int ? customerData['otp'] : 0,
                token: customerData['token']?.toString(),
                b2cCustomerId: customerData['b2cCustomerId']?.toString(),
                newCustomer: customerData['b2cCustomerId'] == null || customerData['newCustomer'] == true,
                mobileNo: phoneNumber,
                firstName: customerData['firstName']?.toString(),
                lastName: customerData['lastName']?.toString(),
                email: customerData['email']?.toString(),
                walletId: customerData['walletId']?.toString(),
              );
            }
          } else if (data is String) {
            // Handle the case where data is a String
            AppLogger.logWarning('Data is a string: $data');
            // Just return the default model in this case
          }
        }

        // If we couldn't parse the data properly, return a default model
        AppLogger.logWarning('Could not parse customer data properly. Using default values.');
        return defaultCustomerModel;
      }

      // If result is null, return the default model
      AppLogger.logWarning('API response was null. Using default values.');
      return defaultCustomerModel;
    } on DioException catch (e) {
      AppLogger.logError('Network error in verifyCustomer: ${e.message}');
      AppLogger.logError('Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      AppLogger.logError('Error in verifyCustomer: $e');
      // Return the default model instead of rethrowing the error
      return CustomerModel(
        mobileNo: phoneNumber,
        newCustomer: true,
      );
    }
  }
}
