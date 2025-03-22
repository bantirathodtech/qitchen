// import 'package:dio/dio.dart';
//
// import '../../../features/3.home/api/api_constants.dart';
// import 'interceptor/network_error_interceptor.dart';
// import 'interceptor/network_request_interceptor.dart';
// import 'interceptor/network_response_interceptor.dart';
//
// class HttpClientInitializer {
//   static Dio? _dio;
//
//   // Singleton pattern to ensure only one instance of Dio is used throughout the app
//   static Dio getInstance() {
//     _dio ??= Dio(
//       BaseOptions(
//         baseUrl: ApiConstants.baseUrl, // Set the base URL for your API
//         connectTimeout: 5000, // Connection timeout in milliseconds
//         receiveTimeout: 3000, // Response timeout in milliseconds
//         headers: {
//           'Content-Type':
//               'application/json', // Default content type for requests
//         },
//       ),
//     );
//
//     // Adding interceptors to the Dio instance
//     _addInterceptors(_dio!);
//
//     return _dio!;
//   }
//
//   // Adds interceptors to handle requests, responses, and errors globally
//   static void _addInterceptors(Dio dio) {
//     dio.interceptors
//         .add(NetworkRequestInterceptor()); // Intercepts requests for logging
//     dio.interceptors
//         .add(NetworkResponseInterceptor()); // Intercepts responses for logging
//     dio.interceptors
//         .add(NetworkErrorInterceptor()); // Intercepts errors globally
//   }
//
//   // Optionally, a method to reset Dio client (for example, in testing or resetting configurations)
//   static void resetClient() {
//     _dio = null; // Resets the Dio instance
//   }
// }
