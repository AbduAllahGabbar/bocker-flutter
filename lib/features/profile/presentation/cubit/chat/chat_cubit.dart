import 'dart:async';

import 'package:boker/core/services/upload_files_services/upload_files_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/di_container.dart';
import '../../../../../core/services/notifications/notifications_bootstrap.dart';
import '../../../../notifications/data/data_source/notifications_remote_data_source.dart';
import '../../../../notifications/data/models/activity_message.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/outgoing_message.dart';
import '../../../data/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  /// Live support events, taken from the one activity stream the counters
  /// cubit already keeps open - no second connection is made here.
  StreamSubscription<ActivityEvent>? _activitySubscription;

  ChatCubit(this._repository) : super(const ChatState.initial()) {
    // While the conversation is open its messages are read on arrival, so the
    // bootstrap skips notifications for them.
    NotificationsBootstrap.instance.setSupportChatOpen(true);

    _activitySubscription = DI.initNotificationCounters().events.listen(
      _onActivityEvent,
    );
  }

  List<MessageModel> _messages = [];
  List<OutgoingMessage> _pending = [];
  int _localIdCounter = 0;
  bool _syncing = false;

  void _onActivityEvent(ActivityEvent event) {
    if (event.event != 'message-new') return;
    // The echo of a message this user just sent: `messages/add-user` already
    // returned it and it is in the list, so re-reading would be a wasted call.
    if (ActivityMessage.isFromCurrentUser(event.data)) return;
    unawaited(_syncMessages());
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(
      ChatState.success(
        List.unmodifiable(_messages),
        pending: List.unmodifiable(_pending),
      ),
    );
  }

  Future<void> fetchMessages() async {
    emit(const ChatState.loading());
    try {
      _messages = await _repository.fetchMessages();
      _emitSuccess();

      // Opening the conversation marks it as read server-side, so re-read the
      // counters that the bell, the profile tile and the nav bar display.
      unawaitedRefreshCounters();
    } catch (e) {
      emit(ChatState.error(e.toString()));
    }
  }

  /// Re-reads the unread counters without blocking the UI. The badge is also
  /// zeroed straight away, since reading the conversation is what cleared it.
  void unawaitedRefreshCounters() {
    final counters = DI.initNotificationCounters();
    counters.setUnreadMessages(0);
    counters.refresh();
  }

  /// Re-reads the conversation after a `message-new` event, without the
  /// loading state, so the open page shows the new message right away.
  /// Pending (unsent) messages are untouched.
  Future<void> _syncMessages() async {
    if (_syncing || isClosed) return;
    _syncing = true;
    try {
      final messages = await _repository.fetchMessages();
      if (isClosed) return;
      _messages = messages;
      _emitSuccess();
      // `messages/view-user` marked the conversation read, so the badge can be
      // zeroed from here - no second round trip for the summary.
      DI.initNotificationCounters().setUnreadMessages(0);
    } catch (_) {
      // A failed background refresh must not disturb the open conversation.
    } finally {
      _syncing = false;
    }
  }

  Future<void> sendTextMessage(String text) async {
    final body = text.trim();
    if (body.isEmpty) return;

    final outgoing = OutgoingMessage(
      localId: 'local-${_localIdCounter++}',
      text: body,
      isSending: true,
    );
    _pending = [..._pending, outgoing];
    _emitSuccess();

    await _deliver(outgoing);
  }

  Future<void> sendFileMessage(String filePath, {required bool isImage}) async {
    final outgoing = OutgoingMessage(
      localId: 'local-${_localIdCounter++}',
      filePath: filePath,
      isImage: isImage,
      isSending: true,
    );
    _pending = [..._pending, outgoing];
    _emitSuccess();

    await _deliver(outgoing);
  }

  /// Retries a message that previously failed to send.
  Future<void> retry(OutgoingMessage message) async {
    final index = _pending.indexWhere((m) => m.localId == message.localId);
    if (index == -1) return;

    _pending = [..._pending];
    _pending[index] = _pending[index].copyWith(
      isSending: true,
      clearError: true,
    );
    _emitSuccess();

    await _deliver(_pending[index]);
  }

  /// Drops a failed message without sending it.
  void discard(OutgoingMessage message) {
    _pending = _pending.where((m) => m.localId != message.localId).toList();
    _emitSuccess();
  }

  Future<void> _deliver(OutgoingMessage outgoing) async {
    try {
      final Map<String, dynamic> payload;

      if (outgoing.isText) {
        payload = {"messageType": "text", "message": outgoing.text};
      } else {
        // Reuses the shared upload service used across the app.
        final uploadResult = outgoing.isImage
            ? await UploadFilesServices.uploadImage(outgoing.filePath!)
            : await UploadFilesServices.uploadFile(outgoing.filePath!);

        final uploaded = uploadResult.fold<Map<String, dynamic>?>((failure) {
          _markFailed(outgoing, 'Upload failed: ${failure.message}');
          return null;
        }, (data) => data);
        if (uploaded == null) return;

        payload = {
          "messageType": outgoing.isImage ? "image" : "file",
          "message": uploaded,
        };
      }

      final sent = await _repository.addMessage(payload);

      _messages = [..._messages, sent];
      _pending = _pending.where((m) => m.localId != outgoing.localId).toList();
      _emitSuccess();
    } catch (e) {
      _markFailed(outgoing, e.toString());
    }
  }

  @override
  Future<void> close() async {
    NotificationsBootstrap.instance.setSupportChatOpen(false);
    await _activitySubscription?.cancel();
    _activitySubscription = null;
    return super.close();
  }

  void _markFailed(OutgoingMessage outgoing, String message) {
    final index = _pending.indexWhere((m) => m.localId == outgoing.localId);
    if (index == -1) return;

    _pending = [..._pending];
    _pending[index] = _pending[index].copyWith(
      isSending: false,
      errorMessage: message,
    );
    _emitSuccess();
  }
}
