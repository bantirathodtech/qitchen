import 'package:dio/dio.dart';

import '../../../common/log/loggers.dart';
import 'api_constants.dart';
import 'api_error_handler.dart'; // Import the response processor
import 'api_response_processor.dart';
import 'api_url_manager.dart';

// 1. Base API Service
class ApiBaseService {
  static const String TAG = '[AppApiService]';
  final Dio dio;

  // 2. Constructor to initialize Dio instance and set up default configurations
  ApiBaseService({required this.dio}) {
    _initializeDio();
  }

  // 3. Configure Dio instance with base options (timeout, headers, etc.)
  void _initializeDio() {
    dio.options.baseUrl = AppUrls.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.sendTimeout = const Duration(seconds: 60);

    dio.options.headers = {
      'Content-Type': 'application/json',
      'api_key': ApiConstants.apiKey,
    };
  }

  // 4. Method to send REST API requests using Dio
  Future<dynamic> sendRestRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) async {
    try {
      // Logging request details
      AppLogger.logInfo('$TAG: Sending $method request to $endpoint');
      AppLogger.logDebug('$TAG: Query params: $queryParams');
      AppLogger.logDebug('$TAG: Body: $body');

      // 5. Send request based on the HTTP method
      final response = await dio.request(
        endpoint,
        options: Options(method: method),
        queryParameters: method == 'GET' ? queryParams : null,
        data: method != 'GET' ? body : null,
      );

      // 6. Use ApiResponseProcessor to handle and process the response
      return ApiResponseProcessor.processResponse(response);
    } on DioException catch (e) {
      // 7. Use ApiException.fromDioError to convert Dio error to ApiException directly
      throw ApiException.fromDioError(e);
    } catch (e) {
      // 8. Handle any unexpected errors
      AppLogger.logError('$TAG: Unexpected error: $e');
      throw ApiException(message: 'Unexpected error occurred: $e');
    }
  }
}
