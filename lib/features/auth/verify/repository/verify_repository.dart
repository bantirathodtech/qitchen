// VerifyRepository.dart with timeout and error handling
import 'dart:async';
import 'package:cw_food_ordering/common/log/loggers.dart';

import '../model/verify_model.dart';
import '../service/verify_service.dart';

class VerifyRepository {
  final VerifyService _verifyService;

  VerifyRepository({required VerifyService verifyService})
      : _verifyService = verifyService;

  Future<CustomerModel> verifyCustomer(String phoneNumber) async {
    try {
      // Add timeout to prevent hanging
      return await _verifyService.verifyCustomer(phoneNumber)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        AppLogger.logWarning('Customer verification timed out');
        // Return a default model on timeout instead of throwing an error
        return CustomerModel(
          mobileNo: phoneNumber,
          newCustomer: true, // Default to new customer
        );
      });
    } catch (e) {
      AppLogger.logError('Error in VerifyRepository: $e');
      // Return a default model on error instead of rethrowing
      return CustomerModel(
        mobileNo: phoneNumber,
        newCustomer: true,
      );
    }
  }

  // Add this method to VerifyRepository
  Future<CustomerModel> refreshUserProfile(String phoneNumber) async {
    try {
      AppLogger.logInfo('[VerifyRepository] Refreshing user profile with phone: $phoneNumber');

      // Call service to verify customer and get updated profile
      final updatedCustomer = await _verifyService.verifyCustomer(phoneNumber);

      // Update the local storage with the latest data
      if (updatedCustomer.walletId != null) {
        AppLogger.logInfo('[VerifyRepository] Updated wallet ID: ${updatedCustomer.walletId}');
      }

      return updatedCustomer;
    } catch (e) {
      AppLogger.logError('[VerifyRepository] Error refreshing profile: $e');
      rethrow;
    }
  }
}

// import 'package:cw_food_ordering/common/log/loggers.dart';
//
// import '../model/verify_model.dart';
// import '../service/verify_service.dart';
//
// class VerifyRepository {
//   final VerifyService _verifyService;
//
//   VerifyRepository({required VerifyService verifyService})
//       : _verifyService = verifyService;
//
//   Future<CustomerModel?> verifyCustomer(String phoneNumber) async {
//     try {
//       return await _verifyService.verifyCustomer(phoneNumber);
//     } catch (e) {
//       AppLogger.logError('Error verifying customer in VerifyRepository: $e');
//       rethrow;
//     }
//   }
// }
