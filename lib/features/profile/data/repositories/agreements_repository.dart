import 'package:dio/dio.dart';
import 'package:boker/core/network/dio/dio_factory.dart';
import 'dart:convert';

class AgreementsRepository {
  final Dio dio;
  AgreementsRepository(this.dio);
  Future<List<dynamic>> fetchAgreements() async {
    try {

      
      final response = await dio.post(
        '/agreements/all',
        data: {
          "where": {
            "active": true
          },
          "select": {
            "id": 1,
            "name": 1,
            "file": 1
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true && data['list'] != null) {
          return data['list'] as List<dynamic>;
        }
      }
      throw Exception('Failed to fetch agreements');
    } catch (e) {
      rethrow;
    }
  }
}
