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
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    dio.options.headers = {
      'Content-Type': 'application/json',
      'api_key': ApiConstants.apiKey,
    };
    // Add interceptors for better debugging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.logInfo('$TAG: Starting request to ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.logInfo(
              '$TAG: Received response from ${response.requestOptions.path} with status ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.logError(
              '$TAG: Error in request to ${e.requestOptions.path}: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // 4. Method to send REST API requests using Dio
  Future<dynamic> sendRestRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParams,
    dynamic body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Logging request details
      AppLogger.logInfo('$TAG: Sending $method request to $endpoint');
      AppLogger.logDebug('$TAG: Query params: $queryParams');
      AppLogger.logDebug('$TAG: Body: $body');

      // Apply request-specific timeout
      final options = Options(
        method: method,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

      // 5. Send request based on the HTTP method
      final response = await dio.request(
        endpoint,
        // options: Options(method: method),
        options: options,

        queryParameters: method == 'GET' ? queryParams : null,
        data: method != 'GET' ? body : null,
      );

      // Process response
      AppLogger.logDebug(
          '$TAG: Raw response received with status: ${response.statusCode}');

      // 6. Use ApiResponseProcessor to handle and process the response
      AppLogger.logDebug(
          '$TAG: Raw response data: ${response.data}'); // Not reached      return ApiResponseProcessor.processResponse(response);
      // Fixed: Remove the comment and ensure processResponse is called
      return ApiResponseProcessor.processResponse(response);
    } on DioException catch (e) {
      // 7. Use ApiException.fromDioError to convert Dio error to ApiException directly
      AppLogger.logError(
          '$TAG: DioException caught - Response: ${e.response?.data}, Status: ${e.response?.statusCode}, Message: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      // 8. Handle any unexpected errors
      AppLogger.logError('$TAG: Unexpected error: $e');
      throw ApiException(message: 'Unexpected error occurred: $e');
    }
  }
}
