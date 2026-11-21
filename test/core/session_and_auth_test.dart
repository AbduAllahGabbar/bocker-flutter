import 'package:boker/core/config/env/app_config.dart';
import 'package:boker/core/network/dio/dio_factory.dart';
import 'package:boker/core/network/dio/session_manager.dart';
import 'package:boker/core/utils/password_policy.dart';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the request that reached the transport layer so the interceptor
/// behaviour can be asserted without touching the network.
class _RecordingAdapter implements HttpClientAdapter {
  /// `Set-Cookie` values the fake server answers with.
  List<String>? setCookie;
  int statusCode = 200;
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      '{"done": true}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'set-cookie': ?setCookie,
      },
    );
  }
}

void main() {
  group('AppConfig', () {
    test('defaults to the production host', () {
      expect(AppConfig.environment, AppEnvironment.production);
      expect(AppConfig.baseUrl, 'https://atm-crm.egytag.com');
      expect(AppConfig.apiBaseUrl, 'https://atm-crm.egytag.com/api');
      expect(
        AppConfig.uploadBaseUrl,
        'https://atm-crm.egytag.com/x-api/upload',
      );
    });

    test('resolveUrl builds absolute URLs and passes through full ones', () {
      expect(
        AppConfig.resolveUrl('/uploads/a.png'),
        'https://atm-crm.egytag.com/uploads/a.png',
      );
      expect(
        AppConfig.resolveUrl('uploads/a.png'),
        'https://atm-crm.egytag.com/uploads/a.png',
      );
      expect(
        AppConfig.resolveUrl('https://cdn.example.com/a.png'),
        'https://cdn.example.com/a.png',
      );
      expect(AppConfig.resolveUrl(''), isNull);
      expect(AppConfig.resolveUrl(null), isNull);
    });
  });

  group('AuthInterceptor session cookie', () {
    late Dio dio;
    late _RecordingAdapter adapter;

    setUp(() {
      // Exercise the interceptor in isolation: SessionManager is the single
      // source of truth, so seeding it in memory is enough.
      dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      dio.interceptors.add(AuthInterceptor());
      adapter = _RecordingAdapter();
      dio.httpClientAdapter = adapter;
    });

    tearDown(() => SessionManager.instance.debugSetToken(null));

    test('attaches the stored session token to every request', () async {
      SessionManager.instance.debugSetToken('token-abc');

      await dio.post('/user/view');

      expect(adapter.lastRequest!.headers['Cookie'], 'access_token=token-abc');
    });

    test('uses the current token, not one captured at construction', () async {
      SessionManager.instance.debugSetToken('first-token');
      await dio.post('/user/view');
      expect(
        adapter.lastRequest!.headers['Cookie'],
        'access_token=first-token',
      );

      // A new sign-in replaces the session; the same Dio instance must pick
      // the new token up. This is the regression the old interceptor had.
      SessionManager.instance.debugSetToken('second-token');
      await dio.post('/user/view');
      expect(
        adapter.lastRequest!.headers['Cookie'],
        'access_token=second-token',
      );
    });

    test('never sends an empty cookie when there is no session', () async {
      SessionManager.instance.debugSetToken(null);

      await dio.post('/user/view');

      expect(adapter.lastRequest!.headers.containsKey('Cookie'), isFalse);
    });

    test('treats an empty token as no session', () async {
      SessionManager.instance.debugSetToken('');

      await dio.post('/user/view');

      expect(adapter.lastRequest!.headers.containsKey('Cookie'), isFalse);
      expect(SessionManager.instance.hasSession, isFalse);
    });
  });

  group('AuthInterceptor session cookie capture', () {
    late Dio dio;
    late _RecordingAdapter adapter;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      dio.interceptors.add(AuthInterceptor());
      adapter = _RecordingAdapter();
      dio.httpClientAdapter = adapter;
      SessionManager.instance.debugSetToken(null);
    });

    tearDown(() => SessionManager.instance.debugSetToken(null));

    test('picks the session up from a Set-Cookie login response', () async {
      adapter.setCookie = [
        'access_token=cookie-token; Path=/; HttpOnly; SameSite=Lax',
      ];

      await dio.post('/user/login');

      // This is the bug behind "I have to reopen the app after logging in":
      // the session arrived as a cookie and nothing kept it.
      expect(SessionManager.instance.accessToken, 'cookie-token');

      // The very next request must already be authenticated - no restart.
      adapter.setCookie = null;
      await dio.post('/user/view');
      expect(
        adapter.lastRequest!.headers['Cookie'],
        'access_token=cookie-token',
      );
    });

    test('reads the session cookie among other cookies', () async {
      adapter.setCookie = [
        'csrf=abc; Path=/',
        'access_token=second-cookie; Path=/; Max-Age=86400',
      ];

      await dio.post('/user/login');

      expect(SessionManager.instance.accessToken, 'second-cookie');
    });

    test('ignores a cookie that only clears the session', () async {
      SessionManager.instance.debugSetToken('live-token');
      adapter.setCookie = ['access_token=; Path=/; Max-Age=0'];

      await dio.post('/user/view');

      expect(SessionManager.instance.accessToken, 'live-token');
    });

    test('ignores unrelated cookies', () async {
      adapter.setCookie = ['other_token=nope; Path=/'];

      await dio.post('/user/login');

      expect(SessionManager.instance.hasSession, isFalse);
    });
  });

  group('SessionManager 401 handling', () {
    tearDown(() {
      SessionManager.instance
        ..debugSetToken(null)
        ..onUnauthorized = null;
    });

    test('clears the session and signals the app exactly once', () async {
      SessionManager.instance.debugSetToken('expired');
      var calls = 0;
      SessionManager.instance.onUnauthorized = () async => calls++;

      // Several requests can fail with 401 at the same time; the teardown must
      // not run repeatedly.
      await Future.wait([
        SessionManager.instance.handleUnauthorized(),
        SessionManager.instance.handleUnauthorized(),
        SessionManager.instance.handleUnauthorized(),
      ]);

      expect(calls, 1);
      expect(SessionManager.instance.hasSession, isFalse);
    });

    test('does nothing when there is no session to tear down', () async {
      SessionManager.instance.debugSetToken(null);
      var calls = 0;
      SessionManager.instance.onUnauthorized = () async => calls++;

      await SessionManager.instance.handleUnauthorized();

      expect(calls, 0);
    });
  });

  group('DioFactory', () {
    test('builds instances with the configured API base URL', () {
      final dio = DioFactory().getDio();
      expect(dio.options.baseUrl, AppConfig.apiBaseUrl);
      expect(dio.interceptors.whereType<AuthInterceptor>(), isNotEmpty);
    });
  });

  group('PasswordPolicy', () {
    test('accepts a password meeting every backend rule', () {
      expect(PasswordPolicy.isValid('Str0ng!Pass'), isTrue);
      expect(PasswordPolicy.validate('Str0ng!Pass'), isNull);
    });

    test('rejects passwords that are too short', () {
      expect(PasswordPolicy.isValid('Ab1!c'), isFalse);
    });

    test('requires an uppercase letter', () {
      expect(PasswordPolicy.isValid('str0ng!pass'), isFalse);
    });

    test('requires a lowercase letter', () {
      expect(PasswordPolicy.isValid('STR0NG!PASS'), isFalse);
    });

    test('requires a number', () {
      expect(PasswordPolicy.isValid('Strong!Pass'), isFalse);
    });

    test('requires a special character', () {
      expect(PasswordPolicy.isValid('Str0ngPass'), isFalse);
    });

    test('reports all five requirements for the checklist', () {
      final requirements = PasswordPolicy.requirements('Str0ng!Pass');
      expect(requirements, hasLength(5));
      expect(requirements.every((r) => r.isMet), isTrue);

      final empty = PasswordPolicy.requirements('');
      expect(empty.every((r) => r.isMet), isFalse);
    });
  });
}
