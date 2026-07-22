import '../../../features/app/app_cubit.dart';
import '../../di/di_container.dart';

// API endpoints
class ApiConstants {
  ApiConstants._();
  // static const String baseUrl = 'https://web-dev.malekmarkets.com';
  static const int defaultPageSize = 10;
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const String baseUrl = 'https://boker.egytag.com';
  static const String apiBaseUrl = 'https://boker.egytag.com/api';
  static const String signOut = '/user/logout';
  static const String account = '/user/account';
  static const String defaultLocale = 'en-US';
  static String get locale => di<AppCubit>().languageLocaleCode;



}

