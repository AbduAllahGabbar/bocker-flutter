import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/env/app_config.dart';
import '../../data/constants/apis_constants.dart';
import 'session_manager.dart';

/// Builds the application's [Dio] instances.
///
/// Every instance produced here shares the exact same interceptor stack, so
/// authentication behaves identically no matter which data source issues the
/// request.
class DioFactory {
  static const Duration _timeout = Duration(seconds: 30);

  Dio getDio({String? accessToken}) {
    // A token passed in explicitly (e.g. right after login, before the session
    // has been persisted) seeds the session so the very next request is
    // already authenticated.
    if (accessToken != null && accessToken.isNotEmpty) {
      SessionManager.instance.saveToken(accessToken);
    }

    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );


    dio.interceptors.add(AuthInterceptor());
    String? pendingBracket;
    bool inBytesBlock = false;
    final StringBuffer logBuffer = StringBuffer();

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        logPrint: (object) {
          final msg = object.toString();
          // Strip box-drawing chars to inspect the raw content
          final content =
          msg.replaceAll(RegExp(r'[║╔╚╗═]'), '').trim();

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
    ); dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        logPrint: (object) {
          final msg = object.toString();
          // Strip box-drawing chars to inspect the raw content
          final content =
          msg.replaceAll(RegExp(r'[║╔╚╗═]'), '').trim();

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
    if (AppConfig.enableNetworkLogging) {
      dio.interceptors.add(_buildLogger());
    }

    return dio;
  }

  /// Kept for call sites that want to be sure the persisted session has been
  /// loaded before the instance is used.
  Future<Dio> getDioWithToken() async {
    await SessionManager.instance.restore();
    return getDio();
  }

  PrettyDioLogger _buildLogger() {
    String? pendingBracket;
    bool inBytesBlock = false;
    final StringBuffer logBuffer = StringBuffer();

    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      logPrint: (object) {
        final msg = object.toString();

        // Never let credentials reach the log, even in non-production builds.
        if (_isSensitiveLogLine(msg)) {
          logBuffer.writeln('║     <redacted>');
          return;
        }

        // Strip box-drawing chars to inspect the raw content
        final content = msg.replaceAll(RegExp(r'[║╔╚╗═]'), '').trim();

        // ── Inside a byte block ────────────────────────────────────────────
        if (inBytesBlock) {
          if (content == ']') {
            inBytesBlock = false; // block ended
            logBuffer.writeln('║     [ <Binary Data Suppressed> ]');
          }
          return; // suppress the ']' line too
        }

        // ── Byte-content line: only digits and commas ──────────────────────
        if (RegExp(r'^\d+(?:,\s*\d+)+,?\s*$').hasMatch(content)) {
          pendingBracket = null; // discard the buffered '['
          inBytesBlock = true;
          return;
        }

        // ── Flush any buffered '[' that turned out NOT to be a byte block ──
        if (pendingBracket != null) {
          logBuffer.writeln(pendingBracket!);
          pendingBracket = null;
        }

        // ── Buffer a lone '[' — decide on the next call ────────────────────
        if (content == '[') {
          pendingBracket = msg;
          return;
        }

        logBuffer.writeln(msg);

        // ── Flush to dev.log when we hit the bottom border ─────────────────
        if (msg.trimLeft().startsWith('╚')) {
          dev.log('\n${logBuffer.toString().trimRight()}', name: 'DIO');
          logBuffer.clear();
        }
      },
    );
  }

  static final RegExp _sensitiveKeys = RegExp(
    r'(cookie|set-cookie|authorization|access_token|accessToken|refresh_token|'
    r'refreshToken|password|oldPassword|newPassword|confirmPassword|otp|token)',
    caseSensitive: false,
  );

  static bool _isSensitiveLogLine(String line) => _sensitiveKeys.hasMatch(line);
}

/// Attaches the session cookie to every outgoing request and reacts to 401.
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read the live session token - never a value captured when the Dio
    // instance was constructed, which is what made requests fall back to an
    // empty cookie after the session changed.
    final token = await SessionManager.instance.readToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Cookie'] = 'access_token=$token';
    } else {
      // Never send an empty cookie - that overwrites a valid server-side
      // session on some gateways. Simply omit the header instead.
      options.headers.remove('Cookie');
    }

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    // The backend issues the session as a `Set-Cookie: access_token=...`
    // header on login and registration; the JSON body does not always repeat
    // it. Dio keeps no cookie jar, so without capturing the header here the
    // session was only picked up on the next app start - which is exactly why
    // a fresh login looked unauthenticated until the app was reopened.
    await _captureSessionCookie(response);
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // No refresh endpoint exists on this backend (verified: /auth/refresh and
      // friends return 404). Drop the session and let the app route back to
      // login. The failing request is NOT retried, so no retry loop is possible,
      // and simultaneous 401s collapse into one teardown inside SessionManager.
      if (!_isAuthEndpoint(err.requestOptions.path)) {
        await SessionManager.instance.handleUnauthorized();
      }
    }
    return handler.next(err);
  }

  /// Stores the session token carried by a `Set-Cookie` response header.
  ///
  /// A cookie that clears the session (empty value, `deleted`, or `Max-Age=0`)
  /// is ignored here: tearing the session down is the job of [onError] and of
  /// the explicit sign-out call, never of a stray header.
  Future<void> _captureSessionCookie(Response<dynamic> response) async {
    final token = _tokenFromSetCookie(response.headers.map[_setCookieHeader]);
    if (token != null) {
      await SessionManager.instance.saveToken(token);
    }
  }

  static const String _setCookieHeader = 'set-cookie';

  /// Cookie names the backend has been seen to issue the session under.
  static const Set<String> _sessionCookieNames = {
    'access_token',
    'accesstoken',
  };

  /// Extracts the `access_token` value from raw `Set-Cookie` header values.
  static String? _tokenFromSetCookie(List<String>? setCookieHeaders) {
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
      return null;
    }

    for (final header in setCookieHeaders) {
      // Only the first `name=value` pair of a Set-Cookie header is the cookie;
      // everything after the first `;` is an attribute (Path, Max-Age, ...).
      final firstPair = header.split(';').first.trim();
      final separator = firstPair.indexOf('=');
      if (separator <= 0) continue;

      final name = firstPair.substring(0, separator).trim().toLowerCase();
      if (!_sessionCookieNames.contains(name)) continue;

      final value = firstPair.substring(separator + 1).trim();
      if (value.isEmpty || value == 'null' || value == 'deleted') {
        // An expiring cookie - not a new session.
        continue;
      }
      return value;
    }

    return null;
  }

  /// Login/registration endpoints legitimately answer 401 for bad credentials;
  /// that must surface as a form error, not as a session teardown.
  bool _isAuthEndpoint(String path) {
    const authPaths = <String>[
      '/user/login',
      '/user/register',
      '/user/verifyEmailOtp',
      '/otpMails/add',
      '/user/updatePasswordWithOtp',
    ];
    return authPaths.any(path.contains);
  }
}
