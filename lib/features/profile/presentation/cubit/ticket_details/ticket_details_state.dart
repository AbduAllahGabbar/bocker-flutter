import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_details_state.freezed.dart';

@freezed
sealed class TicketDetailsState with _$TicketDetailsState {
  const factory TicketDetailsState.initial(Map<String, dynamic> ticket) = _Initial;
  const factory TicketDetailsState.loading(Map<String, dynamic> ticket) = _Loading;
  const factory TicketDetailsState.success(Map<String, dynamic> ticket) = _Success;
  const factory TicketDetailsState.error(Map<String, dynamic> ticket, String message) = _Error;
}
