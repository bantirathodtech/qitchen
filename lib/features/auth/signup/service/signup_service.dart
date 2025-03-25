import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/log/loggers.dart';
import '../../../../core/services/base/api_base_service.dart';
import '../../../../core/services/endpoints/api_url_manager.dart';
import '../../verify/model/verify_model.dart';

class SignUpService {
  final ApiBaseService _apiBaseService;

  SignUpService({required ApiBaseService apiBaseService})
      : _apiBaseService = apiBaseService;

  Future<CustomerModel> createUserAccount(CustomerModel customer) async {
    try {
      // First, check if the user already exists
      final existingCustomer = await _checkExistingUser(customer.mobileNo!);

      if (existingCustomer != null) {
        AppLogger.logInfo('User already exists, returning existing customer data');
        return existingCustomer;
      }

      AppLogger.logInfo('User does not exist, creating new account...');
      AppLogger.logInfo('Sending REST request to create user account...');

      // Convert CustomerModel to request body
      final requestBody = {
        'b2cCustomerId': customer.b2cCustomerId,
        'firstName': customer.firstName,
        'lastName': customer.lastName,
        'mobileNo': customer.mobileNo,
        'email': customer.email,
      };

      AppLogger.logDebug('Request payload: $requestBody');

      try {
        final result = await _apiBaseService.sendRestRequest(
          method: 'POST',
          body: requestBody,
          endpoint: AppUrls.createUserAccount,
        );

        AppLogger.logInfo('Response received, processing result...');
        AppLogger.logDebug('Raw response: $result');

        // Check response format
        if (result != null) {
          AppLogger.logDebug('Response type: ${result.runtimeType}');
          if (result is Map) {
            AppLogger.logDebug('Result keys: ${result.keys.toList()}');
          }

          if (result is Map && result['status'] == '200') {
            AppLogger.logInfo('User account created successfully');

            // Return updated CustomerModel with the response data
            return CustomerModel(
              b2cCustomerId: result['b2cCustomerId']?.toString(),
              firstName: customer.firstName,
              lastName: customer.lastName,
              email: customer.email,
              mobileNo: customer.mobileNo,
              newCustomer: false, // Account just created
              token: customer.token, // Preserve original values
              otp: customer.otp, // for fields not in response
              walletId: customer.walletId,
            );
          } else {
            final errorMessage = result is Map ? (result['message'] ?? 'Failed to create user account') : 'Failed to create user account';
            AppLogger.logError('Failed to create user account: $errorMessage');
            throw Exception(errorMessage);
          }
        } else {
          throw Exception('Empty response received from server');
        }
      } catch (e) {
        AppLogger.logError('Error in API request: $e');
        // Return the customer object with a newCustomer flag set to true
        // This allows the flow to continue even if the API fails
        return CustomerModel(
          b2cCustomerId: customer.b2cCustomerId,
          firstName: customer.firstName,
          lastName: customer.lastName,
          email: customer.email,
          mobileNo: customer.mobileNo,
          newCustomer: false, // Treat as created anyway to allow the flow to continue
          token: customer.token,
          otp: customer.otp,
          walletId: customer.walletId,
        );
      }
    } on DioException catch (e) {
      AppLogger.logError('DioException in createUserAccount: ${e.message}');
      AppLogger.logError('Response data: ${e.response?.data}');
      AppLogger.logError('Response status: ${e.response?.statusCode}');

      if (e.response?.statusCode == 500) {
        throw Exception('Server error: Please try again later');
      }

      // Return the customer object with a newCustomer flag set to false
      // This allows the flow to continue even if the API fails
      return CustomerModel(
        b2cCustomerId: customer.b2cCustomerId,
        firstName: customer.firstName,
        lastName: customer.lastName,
        email: customer.email,
        mobileNo: customer.mobileNo,
        newCustomer: false,
        token: customer.token,
        otp: customer.otp,
        walletId: customer.walletId,
      );
    } catch (e) {
      AppLogger.logError('Error in createUserAccount: $e');
      // Return the customer object to allow the flow to continue
      return CustomerModel(
        b2cCustomerId: customer.b2cCustomerId,
        firstName: customer.firstName,
        lastName: customer.lastName,
        email: customer.email,
        mobileNo: customer.mobileNo,
        newCustomer: false,
        token: customer.token,
        otp: customer.otp,
        walletId: customer.walletId,
      );
    }
  }

  Future<CustomerModel?> _checkExistingUser(String mobileNo) async {
    try {
      final String urlWithParams = '${AppUrls.verifyCustomer}?mobile_number=$mobileNo';

      final result = await _apiBaseService.sendRestRequest(
        method: 'GET',
        body: null,
        endpoint: urlWithParams,
      );

      // Log detailed response info
      AppLogger.logDebug('Raw existing user response: ${result.toString()}');
      AppLogger.logDebug('Response type: ${result.runtimeType}');

      if (result is Map) {
        AppLogger.logDebug('Result keys: ${result.keys.toList()}');
        if (result.containsKey('data')) {
          AppLogger.logDebug('Data type: ${result['data'].runtimeType}');
        }
      }

      // Create a default customer model
      CustomerModel defaultModel = CustomerModel(
        mobileNo: mobileNo,
        newCustomer: true,
      );

      // Handle different response structures
      if (result != null) {
        if (result is Map && result.containsKey('data')) {
          var data = result['data'];

          if (data is Map && data.containsKey('verifyCustomer')) {
            var customerData = data['verifyCustomer'];

            if (customerData is Map) {
              return CustomerModel(
                otp: customerData['otp'] is int ? customerData['otp'] : 0,
                token: customerData['token']?.toString(),
                b2cCustomerId: customerData['b2cCustomerId']?.toString(),
                newCustomer: customerData['newCustomer'] == false ? false : true,
                mobileNo: mobileNo,
                firstName: customerData['firstName']?.toString(),
                lastName: customerData['lastName']?.toString(),
                email: customerData['email']?.toString(),
                walletId: customerData['walletId']?.toString(),
              );
            }
          } else if (data is Map) {
            // Direct data structure
            return CustomerModel(
              otp: data['otp'] is int ? data['otp'] : 0,
              token: data['token']?.toString(),
              b2cCustomerId: data['b2cCustomerId']?.toString(),
              newCustomer: data['newCustomer'] == false ? false : true,
              mobileNo: mobileNo,
              firstName: data['firstName']?.toString(),
              lastName: data['lastName']?.toString(),
              email: data['email']?.toString(),
              walletId: data['walletId']?.toString(),
            );
          } else if (data is List && data.isNotEmpty) {
            // Handle list data structure
            var customerData = data[0];
            if (customerData is Map) {
              return CustomerModel(
                otp: customerData['otp'] is int ? customerData['otp'] : 0,
                token: customerData['token']?.toString(),
                b2cCustomerId: customerData['b2cCustomerId']?.toString(),
                newCustomer: customerData['newCustomer'] == false ? false : true,
                mobileNo: mobileNo,
                firstName: customerData['firstName']?.toString(),
                lastName: customerData['lastName']?.toString(),
                email: customerData['email']?.toString(),
                walletId: customerData['walletId']?.toString(),
              );
            }
          }
        }
      }

      // No existing user found or couldn't parse response
      return null;
    } catch (e) {
      AppLogger.logError('Error checking existing user: $e');
      // Return null to indicate no existing user found
      return null;
    }
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }
}
