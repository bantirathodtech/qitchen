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

  Future<void> verifyCustomer(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.logInfo('VerifyViewModel: Verifying customer...');
      _customerData = await _verifyRepository.verifyCustomer(phoneNumber);
      AppLogger.logInfo(
          'VerifyViewModel: Customer verification process completed');
    } catch (e) {
      AppLogger.logError('VerifyViewModel: Error verifying customer: $e');
      _error = e.toString();

      // Check if error indicates existing user
      if (_error!.contains("code_unique") ||
          _error!.contains("already exists")) {
        _customerData = CustomerModel(
          mobileNo: phoneNumber,
          newCustomer: false,
        );
        _error = null; // Clear error since this is an expected case
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isNewCustomer {
    return _customerData?.b2cCustomerId == null;
  }

  void reset() {
    _customerData = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
