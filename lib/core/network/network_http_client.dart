import 'dart:convert';

import 'package:dio/dio.dart';

class NetworkHttpClient {
  final Dio _dio;
  static const String apiKey = 'ud9u9de93302';

  NetworkHttpClient({required Dio dio}) : _dio = dio;

  Future<dynamic> sendGraphQLRequest({
    required String url,
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'query': query,
        'variables': variables,
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'api_key': apiKey,
      };

      var response = await _dio.post(
        url,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        if (response.data['errors'] != null) {
          throw Exception('GraphQL errors: ${response.data['errors']}');
        }
        return response.data['data'];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'GraphQL request failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
