import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/env/app_config.dart';
import '../../../core/config/routes/routes_manager.dart';
import '../data/models/notification_model.dart';

/// Decides where a tapped notification should take the user.
///
/// Rules:
///  * a notification's `url` is a **web** route — it is mapped onto the
///    equivalent Flutter route when one exists;
///  * an absolute URL is only ever opened when it points at the configured
///    backend host. Arbitrary/untrusted hosts are never opened;
///  * when nothing can be resolved the user stays on the notifications list.
class NotificationNavigator {
  const NotificationNavigator._();

  /// Known Boker web paths mapped onto this app's routes.
  /// Longest prefixes first so `/payment-methods` wins over `/payment`.
  static const Map<String, String> _webToFlutterRoutes = {
    '/payment-methods': RoutesNames.paymentDetails,
    '/payment-details': RoutesNames.paymentDetails,
    '/verification': RoutesNames.verificationStatus,
    '/transactions': RoutesNames.home,
    '/notifications': RoutesNames.notifications,
    '/agreements': RoutesNames.agreements,
    '/accounts': RoutesNames.accounts,
    '/messages': RoutesNames.supportChat,
    '/tickets': RoutesNames.helpCenter,
    '/support': RoutesNames.supportChat,
    '/profile': RoutesNames.profile,
    '/ib': RoutesNames.ibDashboard,
    '/mt5': RoutesNames.mt5Data,
    '/home': RoutesNames.home,
  };

  /// Resolves [notification] to a route name, or `null` when there is nothing
  /// safe to navigate to.
  static String? resolveRouteName(NotificationModel notification) {
    final path = _pathOf(notification);
    if (path == null) return null;

    for (final entry in _webToFlutterRoutes.entries) {
      if (path == entry.key || path.startsWith('${entry.key}/')) {
        return entry.value;
      }
    }
    return null;
  }

  /// Navigates to the destination of [notification].
  /// Returns `true` when navigation (or an external open) actually happened.
  static Future<bool> navigate(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final routeName = resolveRouteName(notification);
    if (routeName != null) {
      context.pushNamed(routeName);
      return true;
    }

    // Not a known in-app destination. Only same-host absolute links may be
    // opened externally; everything else is ignored rather than trusted.
    final external = _trustedExternalUri(notification.url);
    if (external == null) return false;

    return launchUrl(external, mode: LaunchMode.externalApplication);
  }

  /// The path part of the notification URL, normalised to start with `/`.
  static String? _pathOf(NotificationModel notification) {
    final raw = notification.url?.trim();
    if (raw == null || raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri == null) return null;

    final path = uri.path.isEmpty ? raw : uri.path;
    if (path.isEmpty) return null;
    final normalised = path.startsWith('/') ? path : '/$path';
    return normalised.length > 1 && normalised.endsWith('/')
        ? normalised.substring(0, normalised.length - 1)
        : normalised;
  }

  /// An absolute https/http URL on the configured backend host, or `null`.
  static Uri? _trustedExternalUri(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return null;
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;

    final backendHost = Uri.tryParse(AppConfig.baseUrl)?.host;
    if (backendHost == null || backendHost.isEmpty) return null;
    if (uri.host.toLowerCase() != backendHost.toLowerCase()) return null;

    return uri;
  }
}
