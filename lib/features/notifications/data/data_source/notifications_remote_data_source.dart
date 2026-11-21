import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/data/constants/apis_constants.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsPage> list({
    int limit = 15,
    int skip = 0,
    String search = '',
    bool unreadOnly = false,
  });

  Future<NotificationSummary> summary();

  /// [ids] is either a list of notification ids or the literal string `all`.
  Future<void> markSeen({required Object ids, bool seen = true});

  /// [ids] is either a list of notification ids or the literal string `all`.
  Future<void> delete({required Object ids});

  Future<void> registerDevice({
    required String token,
    required String platform,
  });

  Future<void> unregisterDevice({required String token});

  /// Server-sent events stream of `notification` / `counts` / `message-new`.
  Stream<ActivityEvent> activityStream({CancelToken? cancelToken});
}

/// One decoded server-sent event from `GET /api/activity/stream`.
class ActivityEvent {
  final String event;
  final Map<String, dynamic> data;

  const ActivityEvent({required this.event, required this.data});
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<NotificationsPage> list({
    int limit = 15,
    int skip = 0,
    String search = '',
    bool unreadOnly = false,
  }) async {
    final response = await dio.post(
      ApiConstants.notificationsList,
      data: {
        'limit': limit,
        'skip': skip,
        'search': search,
        'unreadOnly': unreadOnly,
      },
    );

    final data = _asMap(response.data);
    if (response.statusCode == 200 && data['done'] == true) {
      return NotificationsPage.fromJson(data);
    }
    throw _error(data, 'Failed to load notifications');
  }

  @override
  Future<NotificationSummary> summary() async {
    final response = await dio.post(ApiConstants.notificationsSummary);

    final data = _asMap(response.data);
    if (response.statusCode == 200 && data['done'] == true) {
      return NotificationSummary.fromJson(data);
    }
    throw _error(data, 'Failed to load notification summary');
  }

  @override
  Future<void> markSeen({required Object ids, bool seen = true}) async {
    final response = await dio.post(
      ApiConstants.notificationsMarkSeen,
      // Marking a single batch takes `{ids: [...]}`; marking everything takes
      // `{ids: "all", seen: true}`.
      data: ids is String && ids == 'all'
          ? {'ids': 'all', 'seen': seen}
          : {'ids': ids},
    );

    final data = _asMap(response.data);
    if (response.statusCode == 200 && data['done'] == true) return;
    throw _error(data, 'Failed to update notifications');
  }

  @override
  Future<void> delete({required Object ids}) async {
    final response = await dio.post(
      ApiConstants.notificationsDelete,
      data: {'ids': ids},
    );

    final data = _asMap(response.data);
    if (response.statusCode == 200 && data['done'] == true) return;
    throw _error(data, 'Failed to delete notifications');
  }

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    final response = await dio.post(
      ApiConstants.notificationsDeviceRegister,
      data: {'token': token, 'platform': platform},
    );

    final data = _asMap(response.data);
    if (response.statusCode == 200 && data['done'] == true) return;
    throw _error(data, 'Failed to register device for notifications');
  }

  @override
  Future<void> unregisterDevice({required String token}) async {
    final response = await dio.post(
      ApiConstants.notificationsDeviceUnregister,
      data: {'token': token},
    );

    final data = _asMap(response.data);
    if (response.statusCode == 200 && data['done'] == true) return;
    throw _error(data, 'Failed to unregister device');
  }

  @override
  Stream<ActivityEvent> activityStream({CancelToken? cancelToken}) async* {
    final response = await dio.get<ResponseBody>(
      ApiConstants.activityStream,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
        // The stream stays open indefinitely, so no receive timeout.
        receiveTimeout: Duration.zero,
      ),
    );

    final body = response.data;
    if (body == null) return;

    final lines = body.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    String? eventName;
    final dataBuffer = StringBuffer();

    await for (final line in lines) {
      if (line.isEmpty) {
        // Blank line terminates an event.
        final payload = dataBuffer.toString();
        dataBuffer.clear();
        final name = eventName ?? 'message';
        eventName = null;
        if (payload.isEmpty) continue;
        try {
          final decoded = jsonDecode(payload);
          yield ActivityEvent(
            event: name,
            data: decoded is Map
                ? Map<String, dynamic>.from(decoded)
                : {'value': decoded},
          );
        } catch (_) {
          // A non-JSON keep-alive payload; ignore it.
        }
        continue;
      }
      if (line.startsWith(':')) continue; // comment / heartbeat
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
        dataBuffer.write(line.substring(5).trim());
      }
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        /* fall through */
      }
    }
    return const {};
  }

  Object _error(Map<String, dynamic> data, String fallback) =>
      data['error'] ?? data['message'] ?? fallback;
}
