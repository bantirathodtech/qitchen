// VerifyViewModel.dart with faster verification
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../common/log/loggers.dart';
import '../model/verify_model.dart';
import '../repository/verify_repository.dart';

class VerifyViewModel extends ChangeNotifier {
  final VerifyRepository _verifyRepository;
  CustomerModel? _customerData;
  bool _isLoading = false;
  String? _error;

  VerifyViewModel({required VerifyRepository verifyRepository})
      : _verifyRepository = verifyRepository;

  CustomerModel? get customerData => _customerData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fast verification with timeout
  Future<void> verifyCustomer(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.logInfo('VerifyViewModel: Starting quick customer verification');

      // Use a strict timeout to prevent long verification times
      _customerData = await _verifyRepository.verifyCustomer(phoneNumber)
          .timeout(const Duration(seconds: 4), onTimeout: () {
        throw TimeoutException('Customer verification took too long');
      });

      AppLogger.logInfo('VerifyViewModel: Verification completed successfully');
    } catch (e) {
      AppLogger.logError('VerifyViewModel: Error verifying customer: $e');
      _error = e.toString();

      // Still create a default customer model on error
      if (_error!.contains("code_unique") ||
          _error!.contains("already exists") ||
          _error!.contains("timeout")) {

        _customerData = CustomerModel(
          mobileNo: phoneNumber,
          newCustomer: false,
        );

        // Only clear error for expected cases
        if (_error!.contains("code_unique") || _error!.contains("already exists")) {
          _error = null;
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check for verification status - added a stronger type check
  bool get isNewCustomer {
    return _customerData?.newCustomer == true || _customerData?.b2cCustomerId == null;
  }

  // Pre-create a basic customer model for faster UI updates
  CustomerModel getBasicCustomerModel(String phoneNumber) {
    return CustomerModel(
      mobileNo: phoneNumber,
      newCustomer: false,
    );
  }

  void reset() {
    _customerData = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

