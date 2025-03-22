// File: common/services/api_response_processor.dart

import 'package:dio/dio.dart';

import '../../../common/log/loggers.dart';
import 'api_error_handler.dart';

class ApiResponseProcessor {
  static const String TAG = '[ApiResponseProcessor]';

  static dynamic processResponse(Response response) {
    AppLogger.logInfo('$TAG: Response status: ${response.statusCode}');

    switch (response.statusCode) {
      case 200:
        AppLogger.logInfo('$TAG: OK (200): Request was successful.');
        return response.data; // <--- Returns raw response.data
      case 201:
        AppLogger.logInfo(
            '$TAG: Created (201): Resource created successfully.');
        return response.data;
      case 202:
        AppLogger.logInfo(
            '$TAG: Accepted (202): Request has been accepted for processing.');
        return response.data;
      case 204:
        AppLogger.logInfo(
            '$TAG: No Content (204): No content to send for this request.');
        return null;
      case 205:
        AppLogger.logInfo(
            '$TAG: Reset Content (205): Reset content as per the request.');
        return null;
      case 206:
        AppLogger.logInfo(
            '$TAG: Partial Content (206): Partial response sent.');
        return response.data;

      // Redirects (3xx)
      case 300:
        _logAndThrowWarning('Multiple Choices', 300);
      case 301:
        _logAndThrowWarning('Moved Permanently', 301);
      case 302:
        _logAndThrowWarning('Found', 302);
      case 303:
        _logAndThrowWarning('See Other', 303);
      case 304:
        _logAndThrowWarning('Not Modified', 304);
      case 307:
        _logAndThrowWarning('Temporary Redirect', 307);
      case 308:
        _logAndThrowWarning('Permanent Redirect', 308);

      // Client errors (4xx)
      case 400:
        _logAndThrowError('Bad Request', 400);
      case 401:
        _logAndThrowError('Unauthorized', 401);
      case 402:
        _logAndThrowError('Payment Required', 402);
      case 403:
        _logAndThrowError('Forbidden', 403);
      case 404:
        _logAndThrowError('Not Found', 404);
      case 405:
        _logAndThrowError('Method Not Allowed', 405);
      case 406:
        _logAndThrowError('Not Acceptable', 406);
      case 408:
        _logAndThrowError('Request Timeout', 408);
      case 409:
        _logAndThrowError('Conflict', 409);
      case 410:
        _logAndThrowError('Gone', 410);
      case 411:
        _logAndThrowError('Length Required', 411);
      case 412:
        _logAndThrowError('Precondition Failed', 412);
      case 413:
        _logAndThrowError('Payload Too Large', 413);
      case 414:
        _logAndThrowError('URI Too Long', 414);
      case 415:
        _logAndThrowError('Unsupported Media Type', 415);
      case 416:
        _logAndThrowError('Range Not Satisfiable', 416);
      case 417:
        _logAndThrowError('Expectation Failed', 417);
      case 422:
        _logAndThrowError('Unprocessable Entity', 422);
      case 429:
        _logAndThrowError('Too Many Requests', 429);

      // Server errors (5xx)
      case 500:
        _logAndThrowError('Internal Server Error', 500);
      case 501:
        _logAndThrowError('Not Implemented', 501);
      case 502:
        _logAndThrowError('Bad Gateway', 502);
      case 503:
        _logAndThrowError('Service Unavailable', 503);
      case 504:
        _logAndThrowError('Gateway Timeout', 504);
      case 505:
        _logAndThrowError('HTTP Version Not Supported', 505);
      case 511:
        _logAndThrowError('Network Authentication Required', 511);

      // Default case for unexpected errors
      default:
        AppLogger.logError('$TAG: Unexpected error: ${response.statusCode}');
        throw ApiException(
          message: 'Unexpected error: ${response.statusCode}',
          code: response.statusCode?.toString(),
        );
    }
  }

  static void _logAndThrowWarning(String message, int code) {
    AppLogger.logWarning('$TAG: $message ($code)');
    throw ApiException(message: message, code: code.toString());
  }

  static void _logAndThrowError(String message, int code) {
    AppLogger.logError('$TAG: $message ($code)');
    throw ApiException(message: message, code: code.toString());
  }
}
