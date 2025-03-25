// Handles network-specific errors (e.g., Dio-related issues).
import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final String? code;
  final dynamic data;
  final int? statusCode; // HTTP status code, if applicable
  final DateTime timestamp;

  NetworkException({
    required this.message,
    this.code,
    this.data,
    this.statusCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory to convert DioException to NetworkException
  factory NetworkException.fromDioError(DioException error) {
    String message;
    String? code;
    int? statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out. Please check your network.';
        code = 'CONNECTION_TIMEOUT';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Failed to send request due to timeout.';
        code = 'SEND_TIMEOUT';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Failed to receive response due to timeout.';
        code = 'RECEIVE_TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        final response = error.response;
        message = response?.data?['message'] ??
            'Server returned an invalid response.';
        code = response?.statusCode?.toString() ?? 'BAD_RESPONSE';
        statusCode = response?.statusCode;
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        code = 'CANCELLED';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error occurred.';
        code = 'CONNECTION_ERROR';
        break;
      default:
        message = error.message ?? 'An unknown network error occurred.';
        code = 'UNKNOWN';
    }

    return NetworkException(
      message: message,
      code: code,
      data: error.response?.data,
      statusCode: statusCode,
    );
  }

  // Check if this is a retryable error
  bool get isRetryable {
    return code == 'CONNECTION_TIMEOUT' ||
        code == 'SEND_TIMEOUT' ||
        code == 'RECEIVE_TIMEOUT' ||
        code == 'CONNECTION_ERROR' ||
        statusCode == 503; // Service Unavailable
  }

  @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    final statusStr = statusCode != null ? ' [Status: $statusCode]' : '';
    return 'NetworkException: $message$codeStr$statusStr [$timestamp]';
  }
}