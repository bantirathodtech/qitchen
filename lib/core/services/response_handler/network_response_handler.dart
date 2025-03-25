// Processes HTTP responses and handles status codes consistently.
import 'package:dio/dio.dart';

import '../../../common/log/loggers.dart';
import '../errors/network_exception.dart';

class NetworkResponseHandler {
  static const String _tag = '[NetworkResponseHandler]';

  static dynamic processResponse(Response response) {
    AppLogger.logInfo('$_tag: Response status: ${response.statusCode}');

    switch (response.statusCode) {
    // Success (2xx)
      case 200:
        AppLogger.logInfo('$_tag: OK (200): Request succeeded.');
        return response.data;
      case 201:
        AppLogger.logInfo('$_tag: Created (201): Resource created.');
        return response.data;
      case 202:
        AppLogger.logInfo('$_tag: Accepted (202): Request accepted.');
        return response.data;
      case 204:
        AppLogger.logInfo('$_tag: No Content (204): No content returned.');
        return null;
      case 205:
        AppLogger.logInfo('$_tag: Reset Content (205): Content reset.');
        return null;
      case 206:
        AppLogger.logInfo('$_tag: Partial Content (206): Partial data sent.');
        return response.data;

    // Redirects (3xx)
      case 300:
        _handleRedirect('Multiple Choices', 300, response);
      case 301:
        _handleRedirect('Moved Permanently', 301, response);
      case 302:
        _handleRedirect('Found', 302, response);
      case 303:
        _handleRedirect('See Other', 303, response);
      case 304:
        _handleRedirect('Not Modified', 304, response);
      case 307:
        _handleRedirect('Temporary Redirect', 307, response);
      case 308:
        _handleRedirect('Permanent Redirect', 308, response);

    // Client Errors (4xx)
      case 400:
        _throwError('Bad Request: Invalid request data.', 400, response.data);
      case 401:
        _throwError('Unauthorized: Authentication required.', 401, response.data);
      case 402:
        _throwError('Payment Required: Payment needed.', 402, response.data);
      case 403:
        _throwError('Forbidden: Access denied.', 403, response.data);
      case 404:
        _throwError('Not Found: Resource unavailable.', 404, response.data);
      case 405:
        _throwError('Method Not Allowed: Invalid method.', 405, response.data);
      case 406:
        _throwError('Not Acceptable: Unacceptable request.', 406, response.data);
      case 408:
        _throwError('Request Timeout: Request took too long.', 408, response.data);
      case 409:
        _throwError('Conflict: Resource conflict occurred.', 409, response.data);
      case 410:
        _throwError('Gone: Resource no longer available.', 410, response.data);
      case 411:
        _throwError('Length Required: Content length missing.', 411, response.data);
      case 412:
        _throwError('Precondition Failed: Condition not met.', 412, response.data);
      case 413:
        _throwError('Payload Too Large: Request too big.', 413, response.data);
      case 414:
        _throwError('URI Too Long: Request URI too long.', 414, response.data);
      case 415:
        _throwError('Unsupported Media Type: Invalid format.', 415, response.data);
      case 416:
        _throwError('Range Not Satisfiable: Invalid range.', 416, response.data);
      case 417:
        _throwError('Expectation Failed: Expectation not met.', 417, response.data);
      case 422:
        _throwError('Unprocessable Entity: Invalid data.', 422, response.data);
      case 429:
        _throwError('Too Many Requests: Rate limit exceeded.', 429, response.data);

    // Server Errors (5xx)
      case 500:
        _throwError('Internal Server Error: Server failed.', 500, response.data);
      case 501:
        _throwError('Not Implemented: Feature not supported.', 501, response.data);
      case 502:
        _throwError('Bad Gateway: Invalid server response.', 502, response.data);
      case 503:
        _throwError('Service Unavailable: Server down.', 503, response.data);
      case 504:
        _throwError('Gateway Timeout: Server took too long.', 504, response.data);
      case 505:
        _throwError('HTTP Version Not Supported: Invalid version.', 505, response.data);
      case 511:
        _throwError('Network Authentication Required: Auth needed.', 511, response.data);

    // Default: Unexpected status codes
      default:
        AppLogger.logError(
            '$_tag: Unexpected status code: ${response.statusCode}');
        throw NetworkException(
          message: 'Unexpected server response: ${response.statusCode}',
          code: response.statusCode?.toString(),
          data: response.data,
          statusCode: response.statusCode,
        );
    }
    return null; // Unreachable, but Dart requires a return
  }

  static dynamic _handleRedirect(String message, int statusCode, Response response) {
    AppLogger.logWarning('$_tag: $message ($statusCode): ${response.realUri}');
    throw NetworkException(
      message: '$message: ${response.realUri}',
      code: statusCode.toString(),
      statusCode: statusCode,
      data: response.data,
    );
  }

  static Never _throwError(String message, int statusCode, dynamic data) {
    AppLogger.logError('$_tag: $message ($statusCode)');
    throw NetworkException(
      message: message,
      code: statusCode.toString(),
      statusCode: statusCode,
      data: data,
    );
  }

  // Utility method to check if a status code indicates success
  static bool isSuccessStatus(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }
}