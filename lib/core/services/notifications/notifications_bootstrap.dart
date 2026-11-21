import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';

import '../../../features/auth/data/repository/user_access.dart';
import '../../../features/notifications/data/data_source/notifications_remote_data_source.dart';
import '../../../features/notifications/data/models/activity_message.dart';
import '../../../features/notifications/data/models/notification_model.dart';
import '../../../features/notifications/data/repositories/notifications_repository.dart';
import '../../../features/notifications/presentation/cubit/notification_counters_cubit.dart';
import '../../../features/notifications/presentation/notification_navigator.dart';
import '../../config/routes/routes_manager.dart';
import '../../config/language/language_manager.dart';
import '../../di/di_container.dart';
import 'local_notifications_service.dart';
import 'push_notifications_service.dart';

/// Ties the notification pieces together across the app lifecycle:
/// device-token registration, the live counters stream, and notification taps.
class NotificationsBootstrap {
  NotificationsBootstrap._();

  static final NotificationsBootstrap instance = NotificationsBootstrap._();

  final PushNotificationsService _push = PushNotificationsService.instance;
  final LocalNotificationsService _local = LocalNotificationsService.instance;

  StreamSubscription<ActivityEvent>? _activitySubscription;
  StreamSubscription<Map<String, dynamic>>? _localTapSubscription;
  StreamSubscription<Map<String, dynamic>>? _tapSubscription;
  StreamSubscription<String>? _tokenSubscription;

  /// The token currently registered with the backend, so it can be
  /// unregistered again on sign-out.
  String? _registeredToken;

  bool _started = false;

  /// How many support conversations are on screen (the page can be pushed
  /// more than once). While one is open its messages are read as they arrive,
  /// so they must not also ring as notifications.
  int _openSupportChats = 0;

  /// Open *and* on screen: with the app in the background the conversation is
  /// not being read, so its messages must still raise a notification.
  bool get _supportChatInView =>
      _openSupportChats > 0 &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  /// Called by `ChatCubit` when the support conversation opens and closes.
  void setSupportChatOpen(bool isOpen) {
    _openSupportChats = (_openSupportChats + (isOpen ? 1 : -1)).clamp(0, 99);
  }

  NotificationsRepository get _repository => DI.initNotificationsRepository();

  NotificationCountersCubit get _counters => DI.initNotificationCounters();

  /// Called once from `main()`.
  Future<void> onAppStart() async {
    if (_started) return;
    _started = true;

    // Local notifications stand on their own: they are shown for every event
    // that arrives on the activity stream, whether or not Firebase exists in
    // this build.
    await _local.initialize();
    _localTapSubscription ??= _local.onNotificationTapped.listen(_handleTap);

    // Each live activity event becomes a notification in the device's
    // notification area. The counters themselves are handled by the cubit.
    _activitySubscription ??= _counters.events.listen(_onActivityEvent);

    await _push.initialize();

    _tapSubscription ??= _push.onNotificationTapped.listen(_handleTap);
    _tokenSubscription ??= _push.onTokenRefresh.listen((token) {
      // Firebase rotated the token: register the new one and drop the old one.
      unawaited(_registerToken(token));
    });

    if (UserAccess.isAuthenticated) {
      await onSignedIn();
    }

    // A notification that launched the app from a terminated state.
    final initial = await _push.initialMessagePayload();
    if (initial != null) _handleTap(initial);
  }

  /// Called after a successful sign-in (and at start-up for a restored
  /// session): registers the device and starts the live counters.
  Future<void> onSignedIn() async {
    if (!UserAccess.isAuthenticated) return;

    unawaited(_counters.refresh());
    _counters.startLiveUpdates();

    // Asked once per install; later calls just report the current state.
    unawaited(_local.requestPermission());

    if (!_push.isAvailable) return;

    // Only register when the user has actually granted permission; otherwise
    // the backend would hold a token that can never deliver.
    final granted = await _push.hasPermission();
    if (!granted) return;

    final token = await _push.getToken();
    if (token != null) await _registerToken(token);
  }

  /// Called on sign-out and whenever the session is invalidated (HTTP 401).
  Future<void> onSignedOut() async {
    await _counters.stopLiveUpdates();
    _counters.clear();
    await unregisterCurrentDevice();
  }

  /// Requests OS permission and registers the device. Returns `true` when the
  /// device ends up registered with the backend.
  Future<bool> enablePushNotifications() async {
    if (!_push.isAvailable) return false;

    final granted = await _push.requestPermission();
    if (!granted) return false;

    final token = await _push.getToken();
    if (token == null) return false;

    return _registerToken(token);
  }

  /// Unregisters the device token from the backend.
  Future<void> unregisterCurrentDevice() async {
    final token = _registeredToken ?? await _push.getToken();
    _registeredToken = null;
    if (token == null) return;

    final result = await _repository.unregisterDevice(token: token);
    result.fold(
      (failure) => dev.log(
        'Failed to unregister device: ${failure.message}',
        name: 'PUSH',
      ),
      (_) {},
    );
  }

  /// `true` when the OS permission is granted AND a token is registered.
  Future<PushNotificationsStatus> currentStatus() async {
    if (!_push.isAvailable) {
      return const PushNotificationsStatus(
        isSupported: false,
        hasSystemPermission: false,
        isRegistered: false,
      );
    }
    return PushNotificationsStatus(
      isSupported: true,
      hasSystemPermission: await _push.hasPermission(),
      isRegistered: _registeredToken != null,
    );
  }

  Future<bool> _registerToken(String token) async {
    if (!UserAccess.isAuthenticated) return false;

    final result = await _repository.registerDevice(
      token: token,
      platform: _push.platform,
    );

    return result.fold(
      (failure) {
        dev.log('Failed to register device: ${failure.message}', name: 'PUSH');
        return false;
      },
      (_) {
        _registeredToken = token;
        return true;
      },
    );
  }

  /// Turns a live activity event into a device notification.
  ///
  /// `counts` carries no message of its own, so only `notification` and
  /// `message-new` are shown.
  void _onActivityEvent(ActivityEvent event) {
    if (!UserAccess.isAuthenticated) return;

    switch (event.event) {
      case 'notification':
        final data = _notificationPayload(event.data);
        unawaited(
          _local.show(
            id: LocalNotificationsService.idFor(data),
            title: _string(data['title']) ?? 'New notification'.tran,
            body: _string(data['body']) ?? _string(data['message']),
            payload: data,
          ),
        );
      case 'message-new':
        // Not for a message the user just sent themselves, and not while they
        // are looking at the conversation.
        if (_supportChatInView ||
            ActivityMessage.isFromCurrentUser(event.data)) {
          return;
        }
        final data = _messagePayload(event.data);
        unawaited(
          _local.show(
            id: LocalNotificationsService.idFor(data),
            title: _string(data['title']) ?? 'Support Messages'.tran,
            body: _string(data['body']) ?? 'You have a new message'.tran,
            payload: data,
          ),
        );
      default:
        break;
    }
  }

  /// The event may carry the notification inline or nested under
  /// `notification` / `doc`; both shapes end up as a flat payload map.
  Map<String, dynamic> _notificationPayload(Map<String, dynamic> data) {
    for (final key in const ['notification', 'doc', 'data']) {
      final nested = data[key];
      if (nested is Map) return Map<String, dynamic>.from(nested);
    }
    return data;
  }

  Map<String, dynamic> _messagePayload(Map<String, dynamic> data) {
    final payload = ActivityMessage.flatten(data);
    final preview = ActivityMessage.previewText(data);
    if (preview != null) payload['body'] = preview;
    // Routed by NotificationNavigator onto the support chat screen.
    payload['url'] = '/messages';
    payload['type'] = 'message';
    return payload;
  }

  String? _string(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty || text == 'null') ? null : text;
  }

  void _handleTap(Map<String, dynamic> payload) {
    // The push payload carries the same fields as a notification list entry.
    final notification = NotificationModel.fromJson(payload);

    unawaited(_counters.refresh());

    final context = RouterManger.rootNavigatorKey.currentContext;
    if (context == null || !UserAccess.isAuthenticated) return;

    // Mark the notification as read, then route to its destination.
    // Support messages are read by opening the conversation, not here: their
    // id belongs to the messages collection, not the notifications one.
    final isMessage = _string(payload['type'])?.toLowerCase() == 'message';
    if (!isMessage && notification.id.isNotEmpty) {
      unawaited(_repository.markSeen([notification.id]));
    }

    unawaited(
      NotificationNavigator.navigate(context, notification).then((navigated) {
        if (!navigated && context.mounted) {
          // Nothing specific to open - land on the notifications list.
          RouterManger.router.pushNamed(RoutesNames.notifications);
        }
      }),
    );
  }

  Future<void> dispose() async {
    await _tapSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _activitySubscription?.cancel();
    await _localTapSubscription?.cancel();
    _tapSubscription = null;
    _tokenSubscription = null;
    _activitySubscription = null;
    _localTapSubscription = null;
    _started = false;
  }
}

/// Snapshot of the push-notification state, used by the settings screen.
class PushNotificationsStatus {
  /// `false` when Firebase is not configured in this build.
  final bool isSupported;

  /// The OS-level notification permission.
  final bool hasSystemPermission;

  /// Whether the device token is registered with the Boker backend.
  final bool isRegistered;

  const PushNotificationsStatus({
    required this.isSupported,
    required this.hasSystemPermission,
    required this.isRegistered,
  });

  bool get isEnabled => isSupported && hasSystemPermission && isRegistered;
}
