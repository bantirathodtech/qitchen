// profile_viewmodel.dart
import 'package:flutter/material.dart';

import '../../../data/db/app_preferences.dart';
import '../verify/model/verify_model.dart';
import './profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  bool _isLoading = false;
  String? _error;
  CustomerModel? _userData;

  ProfileViewModel({required ProfileRepository repository})
      : _repository = repository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CustomerModel? get userData => _userData;

  Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get existing user data
      final existingData = await AppPreference.getUserData();

      // Create CustomerModel with updated data
      final customerData = CustomerModel(
        b2cCustomerId: existingData['b2cCustomerId'],
        firstName: updatedData['firstName'],
        lastName: updatedData['lastName'],
        email: updatedData['email'],
        mobileNo: existingData['mobileNo'],
        token: existingData['token'],
        walletId: existingData['walletId'],
      );

      // Update profile using signup service
      _userData = await _repository.updateUserProfile(customerData);

      // Save updated data to local storage
      await AppPreference.saveUserData(_userData!.toJson());

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
}
