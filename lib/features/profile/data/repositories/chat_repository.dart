import 'package:dio/dio.dart';
import 'package:boker/features/profile/data/models/message_model.dart';
import 'dart:convert';

class ChatRepository {
  final Dio dio;
  ChatRepository({required this.dio});
  Future<List<MessageModel>> fetchMessages() async {
    try {

      
      final response = await dio.post(
        '/messages/view-user',
        data: {},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true && data['doc'] != null) {
          final list = data['doc']['messageList'] as List<dynamic>? ?? [];
          return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      throw Exception('Failed to fetch messages');
    } catch (e) {
      rethrow;
    }
  }

  Future<MessageModel> addMessage(Map<String, dynamic> messageData) async {
    try {

      final response = await dio.post(
        '/messages/add-user',
        data: messageData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true && data['doc'] != null) {
          return MessageModel.fromJson(data['doc'] as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to send message');
    } catch (e) {
      rethrow;
    }
  }
}
