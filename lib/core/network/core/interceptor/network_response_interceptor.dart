import 'package:dio/dio.dart';

class NetworkResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('Response [${response.statusCode}] => ${response.data}');
    return super.onResponse(response, handler);
  }
}
