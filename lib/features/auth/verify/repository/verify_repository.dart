import 'package:cw_food_ordering/common/log/loggers.dart';

import '../model/verify_model.dart';
import '../service/verify_service.dart';

class VerifyRepository {
  final VerifyService _verifyService;

  VerifyRepository({required VerifyService verifyService})
      : _verifyService = verifyService;

  Future<CustomerModel?> verifyCustomer(String phoneNumber) async {
    try {
      return await _verifyService.verifyCustomer(phoneNumber);
    } catch (e) {
      AppLogger.logError('Error verifying customer in VerifyRepository: $e');
      rethrow;
    }
  }
}
