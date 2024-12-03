// import 'dart:convert';
//
// import 'package:dio/dio.dart';
//
// import '../log/loggers.dart';
//
// class ApiService {
//   final Dio dio;
//   // static const String X_API_KEY = 'ud9u9de93302';
//   static const String api_key = 'ud9u9de93302';
//   static const String X_TYPESENSE_API_KEY = 'exceloid-test-new';
//
//   ApiService({required Dio dio}) : dio = Dio() {
//     dio.options.receiveTimeout =
//         const Duration(seconds: 60); // Increase from 30s
//     dio.options.connectTimeout = const Duration(seconds: 60);
//     dio.options.sendTimeout = const Duration(seconds: 60);
//   }
//   //REST API calls
//   Future<dynamic> sendRestRequest({
//     required String url,
//     required String method,
//     Map<String, dynamic>? body,
//   }) async {
//     try {
//       AppLogger.logInfo('Sending request to $url');
//       AppLogger.logDebug('Request method: $method');
//       AppLogger.logDebug('Request body before encoding: $body');
//
//       // String encodedBody;
//       // try {
//       //   encodedBody = json.encode(body);
//       //   AppLogger.logDebug('Request body after encoding: $encodedBody');
//       // } catch (e) {
//       //   AppLogger.logError('Error encoding request body: $e');
//       //   rethrow;
//       // }
//
//       final Map<String, String> requestHeaders = {
//         'Content-Type': 'application/json',
//         // 'X-API-KEY': X_API_KEY,
//         'api_key': api_key,
//       };
//
//       AppLogger.logDebug('Request headers: $requestHeaders');
//
//       var response = await dio.request(
//         url,
//         options: Options(
//           method: method,
//           headers: requestHeaders,
//           sendTimeout: const Duration(seconds: 30),
//           receiveTimeout: const Duration(seconds: 30),
//         ),
//         queryParameters: method == 'GET' ? body : null,
//         data: method != 'GET' ? body : null,
//       );
//
//       AppLogger.logInfo('Response status code: ${response.statusCode}');
//       AppLogger.logDebug('Response headers: ${response.headers}');
//       AppLogger.logDebug('Response data: ${json.encode(response.data)}');
//
//       // Handle REST error codes and log their meaning
//       switch (response.statusCode) {
//         case 200:
//           return response.data;
//         case 400:
//           AppLogger.logError(
//               'Bad Request (400): The server could not understand the request.');
//           break;
//         case 401:
//           AppLogger.logError('Unauthorized (401): Authentication failed.');
//           break;
//         case 403:
//           AppLogger.logError('Forbidden (403): Access denied.');
//           break;
//         case 404:
//           AppLogger.logError(
//               'Not Found (404): The resource could not be found.');
//           break;
//         case 405:
//           AppLogger.logError(
//               'Method Not Allowed (405): The method is not allowed.');
//           break;
//         case 500:
//           AppLogger.logError(
//               'Internal Server Error (500): A server error occurred.');
//           break;
//         case 502:
//           AppLogger.logError(
//               'Bad Gateway (502): Invalid response from upstream server.');
//           break;
//         case 503:
//           AppLogger.logError(
//               'Service Unavailable (503): The server is temporarily unavailable.');
//           break;
//         case 504:
//           AppLogger.logError(
//               'Gateway Timeout (504): The server took too long to respond.');
//           break;
//         default:
//           throw DioException(
//             requestOptions: response.requestOptions,
//             response: response,
//             error:
//                 'REST request failed with status code: ${response.statusCode}',
//           );
//       }
//     } catch (e) {
//       AppLogger.logError('Error in REST sendRequest: $e');
//       rethrow;
//     }
//   }
// }
