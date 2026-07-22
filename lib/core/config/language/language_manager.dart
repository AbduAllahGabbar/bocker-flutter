import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const String ASSET_PATH_LOCALISATION = 'assets/translations';

enum LanguageType {
  english,
  arabic;

  const LanguageType();

  String get value => switch (this) {
    LanguageType.english => "en",
    LanguageType.arabic => "ar",
  };

  String get title => switch (this) {
    LanguageType.english => "English",
    LanguageType.arabic => "Arabic",
  };

  Locale get locale => switch (this) {
    LanguageType.english => Locale("en", "US"),
    LanguageType.arabic => Locale("ar", "SA"),
  };

  static LanguageType fromValue(String text) => switch (text) {
    "en" => LanguageType.english,
    "ar" => LanguageType.arabic,
    String() => LanguageType.english,
  };

  static LanguageType fromTitle(String text) => switch (text) {
    "English" => LanguageType.english,
    "Arabic" => LanguageType.arabic,
    String() => LanguageType.english,
  };
}

extension EasyLang on String {
  String get tran => tr(this);

  String tranArg({Map<String, String>? namedArgs}) =>
      tr(this, namedArgs: namedArgs);
}
