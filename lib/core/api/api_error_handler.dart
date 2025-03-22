// lib/core/errors/api_error_handler.dart

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  ApiException({
    required this.message,
    this.code,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    String message;
    String? code;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        code = 'TIMEOUT';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        code = 'TIMEOUT';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        code = 'TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        final response = error.response;
        message = response?.data?['message'] ?? 'Bad response';
        code = response?.statusCode?.toString();
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        code = 'CANCELLED';
        break;
      default:
        message = error.message ?? 'Unknown error occurred';
        code = 'UNKNOWN';
    }

    return ApiException(
      message: message,
      code: code,
      data: error.response?.data,
    );
  }

  @override
  String toString() => 'ApiException: $message (Code: $code)';
}
