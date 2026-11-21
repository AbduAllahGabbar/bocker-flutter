import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:boker/features/notifications/data/data_source/notifications_remote_data_source.dart';
import 'package:boker/features/profile/data/models/message_model.dart';
import 'package:boker/features/profile/data/models/outgoing_message.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Streams a canned server-sent-events body.
class _SseAdapter implements HttpClientAdapter {
  _SseAdapter(this.body);

  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final chunks = Stream<Uint8List>.fromIterable([
      Uint8List.fromList(utf8.encode(body)),
    ]);
    return ResponseBody(
      chunks,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }
}

void main() {
  group('MessageModel (POST /api/messages/view-user)', () {
    test('parses a text message', () {
      final message = MessageModel.fromJson({
        'type': 'user',
        'messageType': 'text',
        'message': 'Hello support',
        'date': '2026-11-01T10:00:00.000Z',
        'isSeen': true,
      });

      expect(message.messageType, MessageType.text);
      expect(message.textContent, 'Hello support');
      expect(message.type, 'user');
      expect(message.isSeen, isTrue);
    });

    test('parses an image message', () {
      final message = MessageModel.fromJson({
        'type': 'support',
        'messageType': 'image',
        'message': {
          'name': 'proof.png',
          'path': '/uploads/proof.png',
          'url': '/uploads/proof.png',
          'size': 2048,
        },
      });

      expect(message.messageType, MessageType.image);
      expect(message.fileContent, isNotNull);
      expect(message.fileContent!.name, 'proof.png');
      expect(message.fileContent!.url, '/uploads/proof.png');
    });

    test('parses a file message', () {
      final message = MessageModel.fromJson({
        'type': 'user',
        'messageType': 'file',
        'message': {'name': 'statement.pdf', 'url': '/uploads/statement.pdf'},
      });

      expect(message.messageType, MessageType.file);
      expect(message.fileContent!.name, 'statement.pdf');
    });

    test('does not crash on an unknown message type', () {
      final message = MessageModel.fromJson({'messageType': 'sticker'});
      expect(message.messageType, MessageType.unknown);
    });
  });

  group('OutgoingMessage (failed send / retry)', () {
    test('describes a text message by its body', () {
      const message = OutgoingMessage(localId: 'l1', text: 'hi');
      expect(message.isText, isTrue);
      expect(message.displayLabel, 'hi');
    });

    test('describes an attachment by its file name', () {
      const message = OutgoingMessage(
        localId: 'l2',
        filePath: r'C:\docs\receipt.pdf',
        isImage: false,
      );

      expect(message.isText, isFalse);
      expect(message.displayLabel, 'receipt.pdf');
    });

    test('records the failure, then clears it on retry', () {
      const message = OutgoingMessage(localId: 'l3', text: 'hi');

      final failed = message.copyWith(
        errorMessage: 'network down',
        isSending: false,
      );
      expect(failed.errorMessage, 'network down');

      final retrying = failed.copyWith(isSending: true, clearError: true);
      expect(retrying.errorMessage, isNull);
      expect(retrying.isSending, isTrue);
      expect(retrying.localId, 'l3');
      expect(retrying.text, 'hi');
    });
  });

  group('activity stream (GET /api/activity/stream)', () {
    Future<List<ActivityEvent>> collect(String body) {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api'));
      dio.httpClientAdapter = _SseAdapter(body);
      final dataSource = NotificationsRemoteDataSourceImpl(dio: dio);
      return dataSource.activityStream().toList();
    }

    test('decodes counts, notification and message-new events', () async {
      final events = await collect(
        'event: counts\n'
        'data: {"unreadNotifications": 3, "unreadMessages": 1}\n'
        '\n'
        'event: notification\n'
        'data: {"id": "n1", "title": "Deposit approved"}\n'
        '\n'
        'event: message-new\n'
        'data: {"id": "m1"}\n'
        '\n',
      );

      expect(events, hasLength(3));
      expect(events[0].event, 'counts');
      expect(events[0].data['unreadNotifications'], 3);
      expect(events[1].event, 'notification');
      expect(events[1].data['title'], 'Deposit approved');
      expect(events[2].event, 'message-new');
    });

    test('ignores heartbeats and malformed payloads', () async {
      final events = await collect(
        ': keep-alive\n'
        '\n'
        'event: counts\n'
        'data: not-json\n'
        '\n'
        'event: counts\n'
        'data: {"unreadMessages": 2}\n'
        '\n',
      );

      expect(events, hasLength(1));
      expect(events.single.data['unreadMessages'], 2);
    });
  });
}
