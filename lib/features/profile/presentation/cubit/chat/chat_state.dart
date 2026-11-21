import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/message_model.dart';
import '../../../data/models/outgoing_message.dart';

part 'chat_state.freezed.dart';

@freezed
sealed class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;

  /// The conversation, plus any messages that failed to send and are waiting
  /// for a retry.
  const factory ChatState.success(
    List<MessageModel> messages, {
    @Default(<OutgoingMessage>[]) List<OutgoingMessage> pending,
  }) = _Success;

  const factory ChatState.error(String message) = _Error;
}
