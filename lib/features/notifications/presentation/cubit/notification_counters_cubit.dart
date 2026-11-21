import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_source/notifications_remote_data_source.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';

/// App-wide unread counters (notifications + messages).
///
/// Values come from `POST /api/notifications/summary`. While the app is in the
/// foreground they are also kept live by the `GET /api/activity/stream` SSE
/// endpoint, which pushes `counts`, `notification` and `message-new` events.
/// The SSE connection is purely an optimisation — the summary endpoint remains
/// the source of truth and is re-read whenever the stream drops.
class NotificationCountersCubit extends Cubit<NotificationSummary> {
  final NotificationsRepository _repository;

  /// Broadcasts every decoded activity event to the rest of the app (local
  /// notifications, the open chat page, ...) without duplicating the stream.
  final StreamController<ActivityEvent> _eventsController =
      StreamController<ActivityEvent>.broadcast();

  StreamSubscription<ActivityEvent>? _streamSubscription;
  CancelToken? _streamCancelToken;
  Timer? _reconnectTimer;
  bool _streamEnabled = false;
  int _reconnectAttempts = 0;

  NotificationCountersCubit({required NotificationsRepository repository})
    : _repository = repository,
      super(const NotificationSummary());

  /// The live activity events, as they arrive on the single SSE connection.
  Stream<ActivityEvent> get events => _eventsController.stream;

  Future<void> refresh() async {
    final result = await _repository.summary();
    result.fold(
      (_) {
        // Counters are decorative; a failure must not disturb the UI.
      },
      (summary) {
        if (!isClosed) emit(summary);
      },
    );
  }

  /// Applies a locally known change without waiting for a round trip.
  void setUnreadNotifications(int value) {
    if (isClosed) return;
    emit(state.copyWith(unreadNotifications: value < 0 ? 0 : value));
  }

  void setUnreadMessages(int value) {
    if (isClosed) return;
    emit(state.copyWith(unreadMessages: value < 0 ? 0 : value));
  }

  void clear() {
    if (isClosed) return;
    emit(const NotificationSummary());
  }

  /// Opens the SSE connection. Safe to call repeatedly.
  void startLiveUpdates() {
    if (_streamEnabled) return;
    _streamEnabled = true;
    _connect();
  }

  /// Closes the SSE connection (sign-out, or app going to the background).
  Future<void> stopLiveUpdates() async {
    _streamEnabled = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _streamCancelToken?.cancel('stopped');
    _streamCancelToken = null;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void _connect() {
    if (!_streamEnabled || isClosed) return;

    _streamCancelToken = CancelToken();
    _streamSubscription = _repository
        .activityStream(cancelToken: _streamCancelToken)
        .listen(
          _onEvent,
          onError: (_) => _scheduleReconnect(),
          onDone: _scheduleReconnect,
          cancelOnError: true,
        );
  }

  void _onEvent(ActivityEvent event) {
    if (isClosed) return;
    _reconnectAttempts = 0;

    if (!_eventsController.isClosed) _eventsController.add(event);

    switch (event.event) {
      case 'counts':
        emit(
          NotificationSummary(
            unreadNotifications: _readCount(event.data, const [
              'unreadNotifications',
              'notifications',
            ], state.unreadNotifications),
            unreadMessages: _readCount(event.data, const [
              'unreadMessages',
              'messages',
            ], state.unreadMessages),
          ),
        );
      case 'notification':
        emit(
          state.copyWith(unreadNotifications: state.unreadNotifications + 1),
        );
      case 'message-new':
        emit(state.copyWith(unreadMessages: state.unreadMessages + 1));
      default:
        break;
    }
  }

  int _readCount(Map<String, dynamic> data, List<String> keys, int fallback) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  void _scheduleReconnect() {
    _streamSubscription = null;
    if (!_streamEnabled || isClosed) return;

    // Backs off 2s, 4s, 8s ... capped at 60s so a down stream never turns into
    // a reconnect storm.
    _reconnectAttempts = (_reconnectAttempts + 1).clamp(1, 5);
    final delay = Duration(seconds: (1 << _reconnectAttempts).clamp(2, 60));

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_streamEnabled || isClosed) return;
      // Re-read authoritative counters, then re-open the stream.
      refresh();
      _connect();
    });
  }

  @override
  Future<void> close() async {
    await stopLiveUpdates();
    await _eventsController.close();
    return super.close();
  }
}
