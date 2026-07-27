import 'package:dio/dio.dart';
import 'package:boker/core/di/di_container.dart';
import 'package:boker/core/config/local/token_cache_service.dart';
import 'package:boker/features/profile/data/models/message_model.dart';
import 'dart:convert';

class ChatRepository {
  Future<List<MessageModel>> fetchMessages() async {
    try {
      final dio = di<Dio>();
      final token = await di<TokenCacheService>().getToken();
      
      final headers = {
        if (token != null) 'Cookie': 'access_token=$token; access_token=$token',
      };
      
      final response = await dio.post(
        '/messages/view-user',
        options: Options(headers: headers),
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
      final dio = di<Dio>();
      final token = await di<TokenCacheService>().getToken();
      
      final headers = {
        if (token != null) 'Cookie': 'access_token=$token; access_token=$token',
      };
      
      final response = await dio.post(
        '/messages/add-user',
        options: Options(headers: headers),
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
