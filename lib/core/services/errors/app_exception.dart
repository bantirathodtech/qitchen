// App-wide exception for business logic and generic errors.
import 'network_exception.dart';

class AppException implements Exception {
  final String message;
  final dynamic error; // Underlying error (e.g., NetworkException, custom error)
  final StackTrace? stackTrace; // For debugging
  final String? code; // Error category (e.g., "VALIDATION", "PERMISSION")
  final DateTime timestamp; // When the error occurred
  final bool isCritical; // Indicates if this error should halt execution

  AppException(
      this.message, {
        this.error,
        this.stackTrace,
        this.code,
        DateTime? timestamp,
        this.isCritical = false,
      }) : timestamp = timestamp ?? DateTime.now();

  // From generic exception
  factory AppException.from(dynamic exception, {
    String? message,
    String? code,
    StackTrace? stackTrace,
    bool isCritical = false,
  }) {
    if (exception is AppException) return exception;
    return AppException(
      message ?? exception.toString(),
      error: exception,
      stackTrace: stackTrace ?? (exception is Error ? exception.stackTrace : null),
      code: code,
      isCritical: isCritical,
    );
  }

  // From NetworkException
  factory AppException.fromNetworkException(NetworkException networkException, {
    String? message,
    bool isCritical = false,
  }) {
    return AppException(
      message ?? networkException.message,
      error: networkException,
      code: networkException.code,
      timestamp: networkException.timestamp,
      isCritical: isCritical,
    );
  }

  // Helper to check if this exception wraps a NetworkException
  bool get isNetworkRelated => error is NetworkException;

  @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    final criticalStr = isCritical ? ' [CRITICAL]' : '';
    return 'AppException: $message$codeStr$criticalStr [$timestamp]';
  }
}