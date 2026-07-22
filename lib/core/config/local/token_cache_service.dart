import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenCacheService {
  const TokenCacheService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
   final String authTokenKey = 'auth_token';

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: authTokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: authTokenKey);
  }

  Future<Map<String, dynamic>?> getTokenPayload() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    return decodeJwtPayload(token);
  }

  bool isTokenExpired(String token) {
    final payload = decodeJwtPayload(token);
    if (payload == null) {
      return true;
    }

    final exp = payload['exp'];
    if (exp is! num) {
      return true;
    }

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );

    return DateTime.now().toUtc().isAfter(expiresAt);
  }

  Map<String, dynamic>? decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final jsonMap = json.decode(decoded);
      return jsonMap is Map<String, dynamic>
          ? jsonMap
          : Map<String, dynamic>.from(jsonMap as Map);
    } catch (_) {
      return null;
    }
  }
}
