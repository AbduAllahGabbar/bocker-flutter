import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../features/auth/data/repository/user_access.dart';
import '../../data/constants/apis_constants.dart';
import '../../config/local/token_cache_service.dart';

class DioFactory {
  Dio getDio({String? accessToken}) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Cookie': 'access_token=$accessToken;access_token=$accessToken',
        },
      ),
    );
    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = UserAccess.accessToken;
          if (token != null) {
            options.headers['Cookie'] = 'access_token=$accessToken';
          }
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

    String? pendingBracket;
    bool inBytesBlock = false;
    final StringBuffer logBuffer = StringBuffer();

    // Add logger interceptor (should be the last one for best output format)
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        logPrint: (object) {
          final msg = object.toString();
          // Strip box-drawing chars to inspect the raw content
          final content = msg.replaceAll(RegExp(r'[║╔╚╗═]'), '').trim();

          // ── Inside a byte block ──────────────────────────────────────────
          if (inBytesBlock) {
            if (content == ']') {
              inBytesBlock = false; // block ended
              logBuffer.writeln('║     [ <Binary Data Suppressed> ]');
            }
            return; // suppress the ']' line too
          }

          // ── Byte-content line: only digits and commas ────────────────────
          // e.g. "123, 34, 115, 99, 101,"
          if (RegExp(r'^\d+(?:,\s*\d+)+,?\s*$').hasMatch(content)) {
            pendingBracket = null; // discard the buffered '['
            inBytesBlock = true;
            return;
          }

          // ── Flush any buffered '[' that turned out NOT to be a byte block
          if (pendingBracket != null) {
            logBuffer.writeln(pendingBracket!);
            pendingBracket = null;
          }

          // ── Buffer a lone '[' — decide on the next call ──────────────────
          if (content == '[') {
            pendingBracket = msg;
            return;
          }

          logBuffer.writeln(msg);

          // ── Flush to dev.log when we hit the bottom border ───────────────
          // PrettyDioLogger always terminates a log box with '╚═══════...'
          if (msg.trimLeft().startsWith('╚')) {
            dev.log('\n${logBuffer.toString().trimRight()}', name: 'DIO');
            logBuffer.clear();
          }
        },
      ),
    );
    dio.interceptors.add(TokenRefreshInterceptor(dio));

    return dio;
  }

  Future<Dio> getDioWithToken() async {
    final accessToken =
        UserAccess.accessToken ?? await CacheSecureStorage.getAccessToken();

    return getDio(accessToken: accessToken);
  }
}

class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  TokenRefreshInterceptor(this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // if (err.response?.statusCode == 401 && !_isRefreshing) {
    //   _isRefreshing = true;
    //   try {
    //     final refreshToken = await CacheSecureStorage.getRefreshToken();
    //     final accessToken = await CacheSecureStorage.getAccessToken();
    //
    //     if (refreshToken == null) {
    //       _isRefreshing = false;
    //       return handler.next(err);
    //     }
    //
    //     final refreshDio = Dio();
    //     final refreshResponse = await refreshDio.post(
    //       '${ApiConstants.apiBaseUrl}/auth/refresh',
    //       options: Options(
    //         headers: {
    //           'Content-Type': 'application/json',
    //           if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    //         },
    //       ),
    //       data: json.encode({'refresh_token': refreshToken}),
    //     );
    //
    //     if (refreshResponse.statusCode == 200) {
    //       final data = refreshResponse.data['data'];
    //       final newAccessToken = data['token'] as String;
    //       final newRefreshToken = data['refreshToken'] as String;
    //
    //       await CacheSecureStorage.saveTokens(
    //         accessToken: newAccessToken,
    //         refreshToken: newRefreshToken,
    //       );
    //
    //       // Retry original request with new access token
    //       final retryOptions = err.requestOptions;
    //       retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
    //
    //       final retryResponse = await _dio.fetch(retryOptions);
    //       _isRefreshing = false;
    //       return handler.resolve(retryResponse);
    //     }
    //   } catch (e) {
    //     _isRefreshing = false;
    //     return handler.next(err);
    //   }
    //   _isRefreshing = false;
    // }
    return handler.next(err);
  }
}
