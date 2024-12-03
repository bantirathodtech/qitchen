import 'package:dio/dio.dart';

class NetworkErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print('Error occurred: ${err.message}');
    // Optionally, you can handle different error types (timeouts, 404, etc.) here
    return super.onError(err, handler);
  }
}
