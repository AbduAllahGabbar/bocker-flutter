import 'package:dio/dio.dart';
import 'dart:convert';

import '../../../../core/data/constants/apis_constants.dart';

class TicketsRepository {
  final Dio dio;

  TicketsRepository({required this.dio});

  /// The message the backend sends with `done: false` on an HTTP 200.
  static String? _serverMessage(dynamic data) {
    if (data is! Map) return null;
    final message = (data['error'] ?? data['message'])?.toString().trim();
    return (message == null || message.isEmpty) ? null : message;
  }

  Future<List<dynamic>> fetchTickets(String status) async {
    try {
      final response = await dio.post(
        '/tickets/all',
        data: {
          "where": {"status": status},
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;
        if (data['done'] == true && data['list'] != null) {
          return data['list'] as List<dynamic>;
        }
      }
      throw Exception('Failed to fetch $status tickets');
    } catch (e) {
      rethrow;
    }
  }

  /// The categories a new ticket can be filed under.
  ///
  /// Only the three fields the `/tickets/add` payload carries are kept -
  /// `_id`, `id` and `name` - so nothing else the backend returns leaks into
  /// the request.
  Future<List<Map<String, dynamic>>> fetchTicketCategories() async {
    final response = await dio.post(
      ApiConstants.ticketCategoriesAll,
      data: const {},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data is String
          ? json.decode(response.data)
          : response.data;
      if (data['done'] == true && data['list'] != null) {
        return (data['list'] as List<dynamic>)
            .whereType<Map>()
            .map(
              (category) => <String, dynamic>{
                '_id': category['_id'],
                'id': category['id'],
                'name': category['name'],
              },
            )
            .toList();
      }
    }
    throw Exception('Failed to fetch ticket categories');
  }

  Future<Map<String, dynamic>> viewTicket(int id) async {
    try {
      final response = await dio.post('/tickets/view', data: {"id": id});

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;
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
      final response = await dio.post('/tickets/add', data: dataPayload);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;
        if (data['done'] == true) {
          return;
        }
        // HTTP 200 with `done: false` - the body carries the real reason,
        // e.g. "The ticket is closed and cannot be replied".
        throw Exception(_serverMessage(data) ?? 'Failed to create ticket');
      }
      throw Exception('Failed to create ticket');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> closeTicket(int id) async {
    try {
      final response = await dio.post('/tickets/close-user', data: {"id": id});

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;
        if (data['done'] == true) {
          return true;
        }
        throw Exception(_serverMessage(data) ?? 'Failed to close ticket');
      }
      throw Exception('Failed to close ticket');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyTicket(Map<String, dynamic> dataPayload) async {
    try {
      final response = await dio.post('/tickets/reply-user', data: dataPayload);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;
        if (data['done'] == true) {
          return;
        }
        // HTTP 200 with `done: false` - the body carries the real reason,
        // e.g. "The ticket is closed and cannot be replied".
        throw Exception(_serverMessage(data) ?? 'Failed to send reply');
      }
      throw Exception('Failed to send reply');
    } catch (e) {
      rethrow;
    }
  }
}
