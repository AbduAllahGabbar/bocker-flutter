import 'package:boker/features/profile/data/models/document_model.dart';
import 'package:boker/core/di/di_container.dart';
import 'package:boker/core/config/local/token_cache_service.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/upload_files_services/upload_files_services.dart';

class VerificationRepository {
  Future<VerificationDocumentModel> fetchVerificationStatus(dynamic userId) async {
    try {
      final dio = di<Dio>();
      final token = await di<TokenCacheService>().getToken();
      
      final headers = {
        if (token != null) 'Cookie': 'access_token=$token; access_token=$token; access_token=$token',
      };
      
      final response = await dio.post(
        '/manageUsers/view',
        options: Options(headers: headers),
        data: {
          "id": userId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['done'] == true && data['doc'] != null) {
          return VerificationDocumentModel.fromJson(data);
        }
      }
      throw Exception('Failed to fetch verification status');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOneUserForm(Map<String, dynamic> data) async {
    try {
      final dio = di<Dio>();
      final token = await di<TokenCacheService>().getToken();

      final headers = {
        if (token != null) 'Cookie': 'access_token=$token; access_token=$token; access_token=$token',
      };
      
      final response = await dio.post(
        '/user/updateOneUserForm',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is String) {
           return json.decode(response.data);
        }
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to update form');
    } catch (e) {
      rethrow;
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> uploadImage(String imagePath) async {
    return UploadFilesServices.uploadImage(imagePath);
  }

  Future<Either<Failure, Map<String, dynamic>>> uploadFile(String filePath) async {
    return UploadFilesServices.uploadFile(filePath);
  }
}
