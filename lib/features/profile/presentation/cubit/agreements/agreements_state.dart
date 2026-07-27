import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreements_state.freezed.dart';

@freezed
sealed class AgreementsState with _$AgreementsState {
  const factory AgreementsState.initial() = _Initial;
  const factory AgreementsState.loading() = _Loading;
  const factory AgreementsState.success(List<dynamic> agreements) = _Success;
  const factory AgreementsState.error(String message) = _Error;
}
