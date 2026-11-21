/// Centralised environment configuration.
///
/// Every network call in the application resolves its host through this class.
/// No service may contain a hardcoded host.
///
/// The active environment is chosen at build time:
///
/// ```sh
/// flutter run                                      # production (default)
/// flutter run --dart-define=BOKER_ENV=staging
/// flutter run --dart-define=BOKER_ENV=development \
///             --dart-define=BOKER_BASE_URL=https://my-local-host:3000
/// ```
///
/// `BOKER_BASE_URL` overrides the host of the selected environment, which is
/// how development and staging are pointed at their own servers. The staging
/// and development hosts are intentionally **not** hardcoded here: the only
/// host confirmed for this product is the production one, and inventing the
/// others would produce silently broken builds.
library;

enum AppEnvironment {
  development('development'),
  staging('staging'),
  production('production');

  const AppEnvironment(this.value);

  final String value;

  static AppEnvironment fromValue(String? value) {
    return AppEnvironment.values.firstWhere(
      (e) => e.value == value?.trim().toLowerCase(),
      orElse: () => AppEnvironment.production,
    );
  }
}

class AppConfig {
  const AppConfig._();

  /// Confirmed production host of the Boker backend.
  static const String _productionBaseUrl = 'https://atm-crm.egytag.com';

  static const String _envFromBuild = String.fromEnvironment(
    'BOKER_ENV',
    defaultValue: 'production',
  );

  static const String _baseUrlFromBuild = String.fromEnvironment(
    'BOKER_BASE_URL',
  );

  static final AppEnvironment environment = AppEnvironment.fromValue(
    _envFromBuild,
  );

  static bool get isProduction => environment == AppEnvironment.production;

  /// Scheme + host, without a trailing slash, e.g. `https://atm-crm.egytag.com`.
  static String get baseUrl {
    if (_baseUrlFromBuild.trim().isNotEmpty) {
      return _stripTrailingSlash(_baseUrlFromBuild.trim());
    }
    // Development and staging fall back to the production host until their own
    // hosts are supplied through BOKER_BASE_URL.
    return _productionBaseUrl;
  }

  /// JSON API root, e.g. `https://atm-crm.egytag.com/api`.
  static String get apiBaseUrl => '$baseUrl/api';

  /// File/image upload root, e.g. `https://atm-crm.egytag.com/x-api/upload`.
  static String get uploadBaseUrl => '$baseUrl/x-api/upload';

  /// Network request/response logging is only enabled outside production.
  static bool get enableNetworkLogging => !isProduction;

  /// Resolves a server-relative path (`/uploads/x.png`) to an absolute URL.
  /// Absolute URLs are returned unchanged. Returns `null` for empty input.
  static String? resolveUrl(String? pathOrUrl) {
    final value = pathOrUrl?.trim();
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }
    return value.startsWith('/') ? '$baseUrl$value' : '$baseUrl/$value';
  }

  static String _stripTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
