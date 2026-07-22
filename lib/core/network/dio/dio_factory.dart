import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../data/constants/apis_constants.dart';
import '../../di/di_container.dart';
import '../../config/local/token_cache_service.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static Future<Dio> getDio() async {
    if (_dio != null) {
      return _dio!;
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // Add interceptors
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await di<TokenCacheService>().getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add publishable key or any custom header if required
          // options.headers['x-publishable-api-key'] = 'your-key';

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Handle global response cases if needed
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Handle global errors, e.g., token expiration
          if (error.response?.statusCode == 401) {
            // Handle unauthorized access (e.g., refresh token, or logout)
          }
          return handler.next(error);
        },
      ),
    );

    // Add logger interceptor (should be the last one for best output format)
    _dio!.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    );

    return _dio!;
  }
}
