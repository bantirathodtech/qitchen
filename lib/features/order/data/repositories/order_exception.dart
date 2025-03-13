// lib/features/order/data/repositories/order_exception.dart

class OrderException implements Exception {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  OrderException(
    this.message, {
    this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'OrderException: $message';
}
