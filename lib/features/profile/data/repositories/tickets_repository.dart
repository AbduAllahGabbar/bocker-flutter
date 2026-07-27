import 'package:dio/dio.dart';
import 'package:boker/core/network/dio/dio_factory.dart';
import 'dart:convert';

class TicketsRepository {
  Future<List<dynamic>> fetchTickets(String status) async {
    try {
      final dio = await DioFactory.getDio();
      
      final headers = {
        'Cookie': 'access_token=7c709da05ed56c6982b206d934225668; access_token=7c709da05ed56c6982b206d934225668',
      };
      
      final response = await dio.post(
        '/tickets/all',
        options: Options(headers: headers),
        data: {
          "where": {
            "status": status
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true && data['list'] != null) {
          return data['list'] as List<dynamic>;
        }
      }
      throw Exception('Failed to fetch $status tickets');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTicket(Map<String, dynamic> dataPayload) async {
    try {
      final dio = await DioFactory.getDio();
      
      final headers = {
        'Cookie': 'access_token=7c709da05ed56c6982b206d934225668; access_token=7c709da05ed56c6982b206d934225668',
      };
      
      final response = await dio.post(
        '/tickets/add',
        options: Options(headers: headers),
        data: dataPayload,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true) {
          return;
        }
      }
      throw Exception('Failed to create ticket');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyTicket(Map<String, dynamic> dataPayload) async {
    try {
      final dio = await DioFactory.getDio();
      
      final headers = {
        'Cookie': 'access_token=7c709da05ed56c6982b206d934225668; access_token=7c709da05ed56c6982b206d934225668',
      };
      
      final response = await dio.post(
        '/tickets/reply-user',
        options: Options(headers: headers),
        data: dataPayload,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true) {
          return;
        }
      }
      throw Exception('Failed to send reply');
    } catch (e) {
      rethrow;
    }
  }
}
