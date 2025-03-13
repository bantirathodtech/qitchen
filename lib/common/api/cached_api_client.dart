// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio = Dio();
  ApiClient() {
    dio.interceptors.add(CacheInterceptor());
  }

  Future<List<dynamic>> fetchPosts() async {
    try {
      Response response =
          await dio.get('https://jsonplaceholder.typicode.com/users');
      print(response.data);
      return response.data;
    } catch (e) {
      print('Error while fetching data: $e');
      return [];
    }
  }
}

class CacheInterceptor extends Interceptor {
  final SharedPreferencesCacheService _cacheService =
      SharedPreferencesCacheService();
  final Duration cacheDuration;

  CacheInterceptor({this.cacheDuration = const Duration(minutes: 10)});

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final statusCode = response.statusCode;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      await _cacheService.putEntry(response, cacheDuration);
    }
    return handler.next(response);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = options.uri.toString();
    final entry = await _cacheService.getEntry(cacheKey);
    if (entry != null) {
      return handler.resolve(Response(requestOptions: options, data: entry));
    }
    return handler.next(options);
  }
}

class SharedPreferencesCacheService {
  bool _initialized = false;
  bool get initialized => _initialized;
  late SharedPreferences _preferences;

  Future<void> _init() async {
    if (_initialized) return;
    _preferences = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<List<dynamic>?> getEntry(String cacheKey) async {
    if (!_initialized) await _init();

    final entry = _preferences.getString(cacheKey);
    if (entry == null) return null;
    final decodedJson = jsonDecode(entry);
    bool isValid =
        DateTime.now().isBefore(DateTime.parse(decodedJson['expiry']));

    if (!isValid) {
      await _preferences.remove(cacheKey);
      return null;
    }
    return decodedJson['value'] as List<dynamic>;
  }

  Future<bool> putEntry(Response response, Duration cacheDuration) async {
    final key = response.realUri.toString();
    final entry = {
      'key': key,
      'status_code': response.statusCode,
      'value': response.data,
      'expiry': DateTime.now().add(cacheDuration).toIso8601String(),
    };
    if (!_initialized) await _init();
    return await _preferences.setString(key, jsonEncode(entry));
  }
}
