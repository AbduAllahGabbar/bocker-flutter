import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Device-local notifications, with no Firebase involved.
///
/// `FlutterLocalNotificationsPlugin()` is a singleton, so this class owns the
/// single `initialize()` call for the whole app: both the activity stream
/// (see `NotificationsBootstrap`) and FCM (`PushNotificationsService`, when
/// Firebase happens to be configured) display their notifications through it.
class LocalNotificationsService {
  LocalNotificationsService._();

  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'boker_default_channel',
    'Boker notifications',
    description: 'Account, transaction and support notifications',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<Map<String, dynamic>> _tapController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _initialized = false;
  bool _permissionGranted = false;
  int _idCounter = 0;

  /// Emits the payload of a notification the user tapped.
  Stream<Map<String, dynamic>> get onNotificationTapped =>
      _tapController.stream;

  bool get hasPermission => _permissionGranted;

  /// Sets the plugin up. The OS permission is asked for separately, from
  /// `NotificationsBootstrap.onSignedIn`, so a first-run user is not prompted
  /// on the splash screen. Never throws.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested explicitly below, not at init time.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) return;
          _tapController.add(decodePayload(payload));
        },
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    } catch (e, st) {
      dev.log(
        'Failed to initialise local notifications',
        name: 'NOTIFICATIONS',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Android 13+ and iOS ask the user once; later calls just report the state.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await android?.requestNotificationsPermission();
        _permissionGranted = granted ?? true;
      } else if (Platform.isIOS || Platform.isMacOS) {
        final darwin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await darwin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _permissionGranted = granted ?? false;
      }
    } catch (_) {
      // An unsupported platform (desktop/web): leave the flag as it is.
    }
    return _permissionGranted;
  }

  /// Shows a notification in the device's notification area.
  ///
  /// [payload] is handed back on [onNotificationTapped] when the user taps it.
  Future<void> show({
    String? title,
    String? body,
    Map<String, dynamic> payload = const {},
    int? id,
  }) async {
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    if (!_initialized) await initialize();

    try {
      await _plugin.show(
        id: id ?? _nextId(),
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(body ?? ''),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload.isEmpty ? null : encodePayload(payload),
      );
    } catch (e) {
      dev.log('Failed to show notification: $e', name: 'NOTIFICATIONS');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {
      /* nothing actionable */
    }
  }

  /// Ids must fit in a 32-bit int on Android; wrap around well before that.
  int _nextId() => _idCounter = (_idCounter + 1) % 100000;

  /// A stable id for [payload], so the same event delivered twice (activity
  /// stream and push, say) replaces its own notification instead of stacking
  /// a second copy. `null` when the payload carries no identity.
  static int? idFor(Map<String, dynamic> payload) {
    for (final key in const ['id', '_id', 'code', 'messageId']) {
      final value = payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value.hashCode & 0x7fffffff;
      }
    }
    return null;
  }

  // The plugin payload is a plain string, so the map travels as `key=value`
  // pairs separated by \u0001 (safe for URLs and free text).
  static String encodePayload(Map<String, dynamic> payload) {
    return payload.entries
        .map((e) => '${e.key}\u0002${e.value}')
        .join('\u0001');
  }

  static Map<String, dynamic> decodePayload(String payload) {
    final result = <String, dynamic>{};
    for (final part in payload.split('\u0001')) {
      final index = part.indexOf('\u0002');
      if (index <= 0) continue;
      result[part.substring(0, index)] = part.substring(index + 1);
    }
    return result;
  }
}
