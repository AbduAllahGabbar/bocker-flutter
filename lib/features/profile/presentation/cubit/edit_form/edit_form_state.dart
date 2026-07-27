import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_form_state.freezed.dart';

@freezed
sealed class EditFormState with _$EditFormState {
  const factory EditFormState.initial() = _Initial;
  const factory EditFormState.loading() = _Loading;
  const factory EditFormState.success() = _Success;
  const factory EditFormState.error(String message) = _Error;
}
