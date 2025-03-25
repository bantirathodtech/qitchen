import 'package:dio/dio.dart';

import '../../../common/log/loggers.dart';
import '../endpoints/api_url_manager.dart';
import '../constants/api_constants.dart';
import '../errors/network_exception.dart';
import '../response_handler/network_response_handler.dart';

// Step 1: Base API Service for handling REST requests
class ApiBaseService {
  static const String tag = '[ApiBaseService]';
  final Dio dio;

  // Step 2: Constructor to initialize Dio instance
  ApiBaseService({required this.dio}) {
    _initializeDio();
  }

  // Step 3: Configure Dio with base options and interceptors
  void _initializeDio() {
    dio.options.baseUrl = AppUrls.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'api_key': ApiConstants.apiKey,
    };

    // Step 3.1: Add interceptors for logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.logInfo('$tag: Starting request to ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.logInfo(
              '$tag: Response from ${response.requestOptions.path} with status ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.logError(
              '$tag: Error in request to ${e.requestOptions.path}: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Step 4: Send REST API requests
  Future<dynamic> sendRestRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParams,
    dynamic body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Step 4.1: Log request details
      AppLogger.logInfo('$tag: Sending $method request to $endpoint');
      AppLogger.logDebug('$tag: Query params: $queryParams');
      AppLogger.logDebug('$tag: Body: $body');

      // Step 4.2: Set request options
      final options = Options(
        method: method,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

      // Step 4.3: Send request
      final response = await dio.request(
        endpoint,
        options: options,
        queryParameters: method == 'GET' ? queryParams : null,
        data: method != 'GET' ? body : null,
      );

      // Step 4.4: Process response with NetworkResponseHandler
      AppLogger.logDebug('$tag: Raw response: ${response.data}');
      return NetworkResponseHandler.processResponse(response);
    } on DioException catch (e) {
      // Step 4.5: Handle Dio exceptions
      AppLogger.logError(
          '$tag: DioException - Response: ${e.response?.data}, Status: ${e.response?.statusCode}, Message: ${e.message}');
      throw NetworkException.fromDioError(e);
    } catch (e) {
      // Step 4.6: Handle unexpected errors
      AppLogger.logError('$tag: Unexpected error: $e');
      throw NetworkException(
        message: 'Unexpected error occurred: $e',
        code: 'UNKNOWN',
      );
    }
  }
}
