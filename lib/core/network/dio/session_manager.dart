import 'dart:async';

import '../../config/local/token_cache_service.dart';

/// Single source of truth for the authenticated session token.
///
/// The backend authenticates with an `access_token` cookie. The token is kept
/// both in secure storage (so it survives restarts) and in memory (so request
/// interceptors can read it synchronously on every request).
///
/// This class never logs the token.
class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  String? _accessToken;
  bool _restored = false;
  Future<void>? _restoring;

  /// Bumped by every [saveToken] / [clear]. An in-flight [restore] that
  /// finishes after one of those must not resurrect the old stored token.
  int _generation = 0;

  /// Invoked once when the backend rejects a request with HTTP 401.
  /// Registered by the app layer so this class stays free of UI imports.
  Future<void> Function()? onUnauthorized;

  bool _handlingUnauthorized = false;

  /// The current token, or `null` when there is no session.
  /// Empty strings are normalised to `null` so a cookie is never written empty.
  String? get accessToken {
    final token = _accessToken;
    if (token == null || token.isEmpty) return null;
    return token;
  }

  bool get hasSession => accessToken != null;

  /// Loads the persisted token into memory. Call once during start-up, before
  /// the first authenticated request is made.
  Future<void> restore() {
    if (_restored) return Future<void>.value();
    // Concurrent callers share the one read instead of racing past a flag that
    // was already flipped while the read was still in flight.
    return _restoring ??= _restore();
  }

  Future<void> _restore() async {
    final generation = _generation;
    try {
      final stored = await CacheSecureStorage.getAccessToken();
      if (generation == _generation &&
          _accessToken == null &&
          stored != null &&
          stored.isNotEmpty) {
        _accessToken = stored;
      }
    } catch (_) {
      // Secure storage can fail on a freshly wiped keystore; treat as no
      // session. A token saved while this read was in flight is kept.
    } finally {
      _restored = true;
      _restoring = null;
    }
  }

  /// Stores a freshly issued token in memory and in secure storage.
  /// A null/empty token is ignored so an existing session is never clobbered
  /// by a response that simply did not carry a token.
  Future<void> saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (_accessToken == token) return;
    _accessToken = token;
    _restored = true;
    _generation++;
    try {
      await CacheSecureStorage.saveTokens(accessToken: token);
    } catch (_) {
      // Secure storage can be unavailable (wiped keystore, restricted device).
      // The in-memory token still authenticates this session.
    }
  }

  /// Reads the token, loading it from secure storage on first use.
  Future<String?> readToken() async {
    if (!_restored) await restore();
    return accessToken;
  }

  /// Clears the session from memory and secure storage.
  Future<void> clear() async {
    _accessToken = null;
    _restored = true;
    _generation++;
    try {
      await CacheSecureStorage.clearTokens();
    } catch (_) {
      // Nothing more to do: the session is already gone from memory.
    }
  }

  /// Handles an HTTP 401.
  ///
  /// The backend exposes no token-refresh endpoint, so the only correct
  /// response is to drop the invalid session and send the user back to the
  /// login screen. Concurrent 401s collapse into a single handling pass, and
  /// the original request is never retried — that avoids the infinite retry
  /// loop a refresh-and-retry interceptor would otherwise create.
  Future<void> handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    if (!hasSession && _restored) {
      // Already signed out; nothing to tear down.
      return;
    }
    _handlingUnauthorized = true;
    try {
      await clear();
      await onUnauthorized?.call();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  /// Test seam.
  void debugSetToken(String? token) {
    _accessToken = token;
    _restored = true;
    _restoring = null;
    _generation++;
  }
}
