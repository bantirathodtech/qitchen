import 'package:dio/dio.dart';

class NetworkRequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('Request [${options.method}] => ${options.uri}');
    print('Headers: ${options.headers}');
    return super.onRequest(options, handler);
  }
}
