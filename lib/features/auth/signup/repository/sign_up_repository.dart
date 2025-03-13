// Repository update
import '../../verify/model/verify_model.dart';
import '../service/signup_service.dart';

class SignUpRepository {
  final SignUpService _signUpService;

  SignUpRepository({required SignUpService signUpService})
      : _signUpService = signUpService;

  Future<CustomerModel> createUserAccount(CustomerModel customer) async {
    return await _signUpService.createUserAccount(customer);
  }

  Future<void> signOut() async {
    await _signUpService.signOut();
  }
}
