// Fix for PaymentApiService
import 'package:logger/logger.dart';
import '../../../../common/log/loggers.dart';
import '../../../../core/api/api_base_service.dart';
import '../../../../core/api/api_url_manager.dart';
import '../data/models/order_response.dart';
import '../data/models/payment_order.dart';

class PaymentApiService {
  static const String TAG = '[PaymentApiService]';
  final ApiBaseService _apiService;
  final Logger _logger;

  PaymentApiService({
    required ApiBaseService apiService,
    Logger? logger,
  })
      : _apiService = apiService,
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

      AppLogger.logInfo('$TAG Raw API response: $response');

      if (response == null) {
        throw Exception('Server returned null response');
      }

      return OrderResponse.fromJson(response);
    } catch (e) {
      AppLogger.logError('$TAG Failed to create payment order: $e');
      AppLogger.logError('$TAG Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
