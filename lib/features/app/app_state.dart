import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';

@freezed
sealed class AppState with _$AppState {
  const factory AppState({
    @Default('en')  String languageCode,
    @Default(false) bool isDarkMode,
  }) = _AppState;
}
