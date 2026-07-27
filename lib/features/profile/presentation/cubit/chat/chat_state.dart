import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/message_model.dart';

part 'chat_state.freezed.dart';

@freezed
sealed class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.success(List<MessageModel> messages) = _Success;
  const factory ChatState.error(String message) = _Error;
}
