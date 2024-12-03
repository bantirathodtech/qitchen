import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/log/loggers.dart';
import '../../../../core/api/api_base_service.dart';
import '../../../../core/api/api_url_manager.dart';
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
        AppLogger.logInfo(
            'User already exists, returning existing customer data');
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

      final result = await _apiBaseService.sendRestRequest(
        method: 'POST',
        body: requestBody,
        endpoint: AppUrls.createUserAccount,
      );

      AppLogger.logInfo('Response received, processing result...');
      AppLogger.logDebug('Raw response: $result');

      if (result != null) {
        if (result['status'] == '200') {
          AppLogger.logInfo('User account created successfully');

          // Return updated CustomerModel with the response data
          // Preserving the input data and updating b2cCustomerId
          return CustomerModel(
              b2cCustomerId: result['b2cCustomerId'],
              firstName: customer.firstName,
              lastName: customer.lastName,
              email: customer.email,
              mobileNo: customer.mobileNo,
              newCustomer: false, // Account just created
              token: customer.token, // Preserve original values
              otp: customer.otp, // for fields not in response
              walletId: customer.walletId);
        } else {
          final errorMessage =
              result['message'] ?? 'Failed to create user account';
          AppLogger.logError('Failed to create user account: $errorMessage');
          throw Exception(errorMessage);
        }
      } else {
        throw Exception('Empty response received from server');
      }
    } on DioException catch (e) {
      AppLogger.logError('DioException in createUserAccount: ${e.message}');
      AppLogger.logError('Response data: ${e.response?.data}');
      AppLogger.logError('Response status: ${e.response?.statusCode}');

      if (e.response?.statusCode == 500) {
        throw Exception('Server error: Please try again later');
      }
      throw Exception('Failed to create account: ${e.message}');
    } catch (e) {
      AppLogger.logError('Error in createUserAccount: $e');
      throw Exception('Error creating account: $e');
    }
  }

  Future<CustomerModel?> _checkExistingUser(String mobileNo) async {
    try {
      final String urlWithParams =
          '${AppUrls.verifyCustomer}?mobile_number=$mobileNo';

      final result = await _apiBaseService.sendRestRequest(
        method: 'GET',
        body: null,
        endpoint: urlWithParams,
      );

      if (result != null &&
          result['data'] != null &&
          result['data']['verifyCustomer'] != null) {
        var customerData = result['data']['verifyCustomer'];

        if (customerData['newCustomer'] == false) {
          AppLogger.logInfo('Existing customer found');
          return CustomerModel(
            otp: customerData['otp'],
            token: customerData['token'],
            b2cCustomerId: customerData['b2cCustomerId'],
            newCustomer: false,
            mobileNo: mobileNo,
            firstName: customerData['firstName'],
            lastName: customerData['lastName'],
            email: customerData['email'],
            walletId: customerData['walletId'],
          );
        }
      }

      return null;
    } catch (e) {
      AppLogger.logError('Error checking existing user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }
}
