import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'local_notifications_service.dart';

/// Firebase Cloud Messaging wrapper.
///
/// Firebase is **optional at build time**: `android/app/google-services.json`
/// and `ios/Runner/GoogleService-Info.plist` are not in the repository, so
/// `Firebase.initializeApp()` is expected to fail on a fresh clone. When it
/// does, [isAvailable] stays `false` and every method here becomes a no-op —
/// the app builds and runs normally, push is simply inactive.
///
/// Dropping the two config files in (and rebuilding) enables push with no code
/// change. Note that the server additionally needs its own Firebase Admin
/// service credentials configured before it will actually *send* anything —
/// registering a device token here does not by itself enable delivery.
class PushNotificationsService {
  PushNotificationsService._();

  static final PushNotificationsService instance = PushNotificationsService._();

  /// Shared with the activity stream: one plugin, one channel, one init.
  final LocalNotificationsService _local = LocalNotificationsService.instance;

  StreamSubscription<Map<String, dynamic>>? _localTapSubscription;

  bool _initialized = false;
  bool _isAvailable = false;

  /// Emits the payload of a notification the user tapped.
  final StreamController<Map<String, dynamic>> _tapController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Emits a new FCM token whenever Firebase rotates it.
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();

  /// `true` once Firebase initialised successfully on this device.
  bool get isAvailable => _isAvailable;

  Stream<Map<String, dynamic>> get onNotificationTapped =>
      _tapController.stream;

  Stream<String> get onTokenRefresh => _tokenController.stream;

  /// `android` or `ios`, as expected by the backend's device endpoints.
  String get platform => Platform.isIOS ? 'ios' : 'android';

  /// Initialises Firebase + the local-notification plugin.
  /// Never throws: a missing/invalid Firebase configuration disables push.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
      _isAvailable = true;
    } catch (e) {
      _isAvailable = false;
      dev.log(
        'Firebase is not configured - push notifications are disabled. '
        'Add google-services.json / GoogleService-Info.plist to enable them.',
        name: 'PUSH',
      );
      return;
    }

    try {
      await _local.initialize();
      // A tap on a notification we displayed locally is a tap on a push.
      _localTapSubscription ??= _local.onNotificationTapped.listen(
        _tapController.add,
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // App in the foreground: FCM does not show a system notification, so we
      // present a local one ourselves.
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);

      // App in the background and the user taps the notification.
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _tapController.add(_payloadOf(message)),
      );

      // NOTE: `onTokenRefresh` / `getToken` / `deleteToken` are deprecated in
      // favour of `register()` + `onRegistered`, but those emit the Firebase
      // Installation ID (FID), not an FCM registration token. The Boker
      // backend's `/notifications/device/register` endpoint stores an FCM
      // token, so the FCM token APIs are what must be used here.
      // ignore: deprecated_member_use
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (token.isNotEmpty) _tokenController.add(token);
      });
    } catch (e, st) {
      dev.log(
        'Failed to wire up push notifications',
        name: 'PUSH',
        error: e,
        stackTrace: st,
      );
      _isAvailable = false;
    }
  }

  /// The notification that launched a terminated app, if any.
  Future<Map<String, dynamic>?> initialMessagePayload() async {
    if (!_isAvailable) return null;
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      return message == null ? null : _payloadOf(message);
    } catch (_) {
      return null;
    }
  }

  /// Asks the OS for notification permission. Returns `true` when granted.
  Future<bool> requestPermission() async {
    if (!_isAvailable) return false;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return _isAuthorized(settings.authorizationStatus);
    } catch (_) {
      return false;
    }
  }

  /// The current OS-level permission state, without prompting.
  Future<bool> hasPermission() async {
    if (!_isAvailable) return false;
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return _isAuthorized(settings.authorizationStatus);
    } catch (_) {
      return false;
    }
  }

  /// The device's FCM registration token, or `null` when unavailable.
  Future<String?> getToken() async {
    if (!_isAvailable) return null;
    try {
      // See the note in initialize(): the backend expects an FCM token.
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      return (token == null || token.isEmpty) ? null : token;
    } catch (_) {
      return null;
    }
  }

  /// Invalidates the device token locally (used on sign-out).
  Future<void> deleteToken() async {
    if (!_isAvailable) return;
    try {
      // ignore: deprecated_member_use
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Nothing actionable - the backend unregister call is what matters.
    }
  }

  bool _isAuthorized(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    final payload = _payloadOf(message);

    await _local.show(
      // Same identity as the activity-stream copy of this event, so the two
      // never stack as two notifications for one thing.
      id: LocalNotificationsService.idFor(payload) ?? message.hashCode,
      title: title,
      body: body,
      payload: payload,
    );
  }

  Map<String, dynamic> _payloadOf(RemoteMessage message) {
    return {
      ...message.data.map((key, value) => MapEntry(key, value)),
      if (message.notification?.title != null)
        'title': message.notification!.title,
      if (message.notification?.body != null)
        'body': message.notification!.body,
    };
  }

  @visibleForTesting
  void debugSetAvailable(bool value) {
    _initialized = true;
    _isAvailable = value;
  }
}

/// Background/terminated message handler.
///
/// Runs in its own isolate, so it may not touch app state. The system displays
/// the notification itself; the tap is handled by `onMessageOpenedApp` /
/// `getInitialMessage` once the app is resumed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase is not configured in this build; nothing to do.
  }
}
