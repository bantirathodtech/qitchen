// ViewModel update
import 'package:flutter/cupertino.dart';

import '../../../../data/db/app_preferences.dart';
import '../../verify/model/verify_model.dart';
import '../idgenerate/generate_32bit_id.dart';
import '../repository/sign_up_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpRepository _signUpRepository;
  bool _isLoading = false;
  String? _error;
  CustomerModel? _customerData;

  SignUpViewModel({required SignUpRepository repository})
      : _signUpRepository = repository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CustomerModel? get customerData => _customerData;

  Future<bool> completeSignUp(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generate b2cCustomerId
      String b2cCustomerId = generateB2CCustomerId();

      // Create CustomerModel instance
      final customer = CustomerModel(
        b2cCustomerId: b2cCustomerId,
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        mobileNo: userData['mobileNo'],
      );

      // Create account
      _customerData = await _signUpRepository.createUserAccount(customer);

      // Save to local storage
      await AppPreference.saveUserData(_customerData!.toJson());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _signUpRepository.signOut();
    // await AppPreference.clearUserData();
    notifyListeners();
  }
}
