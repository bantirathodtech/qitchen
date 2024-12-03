import 'package:logger/logger.dart';

import '../../../common/log/loggers.dart';
import '../../../core/api/api_base_service.dart';
import '../../../core/api/api_url_manager.dart';
import '../data/models/order_response.dart';
import '../data/models/payment_order.dart';

class PaymentApiService {
  static const String TAG = '[PaymentApiService]';
  final ApiBaseService _apiService;
  final Logger _logger;

  PaymentApiService({
    required ApiBaseService apiService,
    Logger? logger,
  })  : _apiService = apiService,
        _logger = logger ?? Logger();

  Future<OrderResponse> createOrder(PaymentOrder order) async {
    try {
      AppLogger.logInfo('$TAG Creating payment order');
      AppLogger.logDebug('$TAG Order data: ${order.toJson()}');

      final response = await _apiService.sendRestRequest(
        endpoint: AppUrls.createOrder,
        method: 'POST',
        body: order.toJson(),
      );

      return OrderResponse.fromJson(response);
    } catch (e) {
      AppLogger.logError('$TAG Failed to create payment order: $e');
      rethrow;
    }
  }
}
//
//   void _validateAddonProducts(PaymentOrder order) {
//     for (var item in order.order.line) {
//       for (var addon in item.subProducts) {
//         // Ensure addon ID matches parent product format
//         if (addon.addonProductId.length != 32) {
//           throw ApiException(
//               message:
//                   'Invalid addon product ID format: ${addon.addonProductId}',
//               code: 'INVALID_ADDON');
//         }
//
//         // Ensure required fields are present
//         if (addon.name.isEmpty || addon.price <= 0 || addon.qty <= 0) {
//           throw ApiException(
//               message: 'Invalid addon product data: Missing required fields',
//               code: 'INVALID_ADDON');
//         }
//       }
//     }
//   }
// }
