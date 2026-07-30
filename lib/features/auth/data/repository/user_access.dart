import 'package:boker/core/config/local/cache_service.dart';
import 'package:boker/features/auth/cubit/auth_state.dart';

import '../../../../core/di/di_container.dart';
import '../../cubit/auth_cubit.dart';
import '../models/user_model.dart';

class UserAccess {
  UserAccess._();

  static UserModel? get user =>
      di<AuthCubit>().state.mapOrNull(authenticated: (value) => value.user);

  static String? get accessToken => di<AuthCubit>().state.mapOrNull(authenticated: (value) => value.token);

  static String? get refreshToken => di<AuthCubit>().state.mapOrNull(
    authenticated: (value) => value.refreshToken,
  );

  static bool get isAuthenticated =>
      di<AuthCubit>().state.mapOrNull(authenticated: (value) => true) ?? false;
  static bool _isViewedOnboarding = false;

  static Future<void> setIsViewedOnboarding(bool value) async {
    _isViewedOnboarding = value;
    await CacheService.saveData("onBoarding", value);
  }

  static Future<bool> get checkIf async =>
      (await CacheService.getData("onBoarding")) ?? false;
}
