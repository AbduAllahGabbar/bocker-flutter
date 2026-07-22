import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/data/repository/user_access.dart';
import 'routes_manager.dart';

/// Router checker for authentication-based redirects
class RouterChecker {
  RouterChecker._();

  static bool _isAuthenticated() {
    final currentUser = UserAccess.user;
    return currentUser != null || UserAccess.isAuthenticated;
  }

  static bool _isAuthPath(String path) {
    return path == '/${RoutesNames.signIn}' ||
        path == '/${RoutesNames.signUp}' ||
        path == '/${RoutesNames.forgotPassword}';
  }

  /// Redirects to login if user is not authenticated
  /// Returns null if user is authenticated (no redirect needed)
  /// Returns login path if user is not authenticated
  static String? ifAlreadyLogin(BuildContext context, GoRouterState state) {
    final isAuthRoute = _isAuthPath(state.uri.path);
    if (!isAuthRoute) {
      return null;
    }

    if (_isAuthenticated()) {
      return RoutesNames.initialRoute;
    }

    return null;
  }

  /// Redirects to home if user is already authenticated
  /// Returns null if user is not authenticated (no redirect needed)
  /// Returns home path if user is authenticated
  static String? initialChecker(BuildContext context, GoRouterState state) {
    if (_isAuthenticated()) {
      return RoutesNames.initialRoute;
    }

    return '/${RoutesNames.onBoarding}';
  }

  static String? ifNotProduct(BuildContext context, GoRouterState state) {
    final extra = state.extra;


    return null;
  }

  static String? ifNotExtra(GoRouterState state, String page) {
    if (state.extra == null) return page;
    return null;
  }
}
