import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boker/core/config/language/language_manager.dart';
import '../../core/config/local/cache_service.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {

  AppCubit({
    required String languageCode,
    bool isDarkMode = false,
  }) :
       super(
         AppState(
           languageCode: languageCode,
           isDarkMode: isDarkMode,
         ),
       );



  void changeThemeMode(ThemeMode mode) {
    emit(state.copyWith(isDarkMode: mode == ThemeMode.dark));
  }

  void changeLanguage(LanguageType language) {
    emit(state.copyWith(languageCode: language.value));
    AppCache.setLanguage(language.value);
  }

  String get languageLocaleCode =>LanguageType.fromValue( state.languageCode).locale.toLanguageTag();


}
