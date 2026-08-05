import 'package:dio/dio.dart';
import 'package:boker/core/network/dio/dio_factory.dart';
import 'dart:convert';

import '../../../../core/di/di_container.dart';

class TicketsRepository {
  final Dio dio;

  TicketsRepository({required this.dio});

  Future<List<dynamic>> fetchTickets(String status) async {
    try {
      
      final response = await dio.post(
        '/tickets/all',
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

  Future<Map<String, dynamic>> viewTicket(int id) async {
    try {
      final response = await dio.post(
        '/tickets/view',
        data: {"id": id},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true && data['doc'] != null) {
          return data['doc'] as Map<String, dynamic>;
        }
      }
      throw Exception('Failed to view ticket details');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTicket(Map<String, dynamic> dataPayload) async {
    try {
      final response = await dio.post(
        '/tickets/add',
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

  Future<bool> closeTicket(int id) async {
    try {
      final response = await dio.post(
        '/tickets/close-user',
        data: {"id": id},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true) {
          return true;
        }
      }
      throw Exception('Failed to close ticket');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyTicket(Map<String, dynamic> dataPayload) async {
    try {

      
      final response = await dio.post(
        '/tickets/reply-user',
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
