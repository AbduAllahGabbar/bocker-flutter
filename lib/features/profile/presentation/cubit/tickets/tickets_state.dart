import 'package:freezed_annotation/freezed_annotation.dart';

part 'tickets_state.freezed.dart';

@freezed
sealed class TicketsState with _$TicketsState {
  const factory TicketsState.initial() = _Initial;
  const factory TicketsState.loading() = _Loading;
  const factory TicketsState.success(List<dynamic> tickets) = _Success;
  const factory TicketsState.error(String message) = _Error;
  const factory TicketsState.createLoading() = _CreateLoading;
  const factory TicketsState.createSuccess() = _CreateSuccess;
  const factory TicketsState.createError(String message) = _CreateError;
}
