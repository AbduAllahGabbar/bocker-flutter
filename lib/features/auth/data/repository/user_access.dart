import 'package:boker/core/config/local/cache_service.dart';
import 'package:boker/features/auth/cubit/auth_state.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/network/dio/session_manager.dart';
import '../../cubit/auth_cubit.dart';
import '../models/user_model.dart';

class UserAccess {
  UserAccess._();

  static UserModel? get user =>
      di<AuthCubit>().state.mapOrNull(authenticated: (value) => value.user);

  /// The live session token. Sourced from [SessionManager] so it is correct
  /// even before/after the auth state has settled.
  static String? get accessToken => SessionManager.instance.accessToken;

  /// This backend issues no refresh token; the getter is kept for call sites
  /// that still read it and always reports `null`.
  static String? get refreshToken => null;

  static bool get isAuthenticated =>
      di<AuthCubit>().state.mapOrNull(authenticated: (value) => true) ?? false;
  static Future<void> setIsViewedOnboarding(bool value) async {
    await CacheService.saveData("onBoarding", value);
  }

  static Future<bool> get checkIf async =>
      (await CacheService.getData("onBoarding")) ?? false;
}
