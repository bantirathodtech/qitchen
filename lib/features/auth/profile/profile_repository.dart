// profile_repository.dart
import '../signup/service/signup_service.dart';
import '../verify/model/verify_model.dart';

class ProfileRepository {
  final SignUpService _signUpService;

  ProfileRepository({required SignUpService signUpService})
      : _signUpService = signUpService;

  Future<CustomerModel> updateUserProfile(CustomerModel customer) async {
    return await _signUpService.createUserAccount(customer);
  }
}
