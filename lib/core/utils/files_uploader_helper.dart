import 'dart:io';
import 'package:dio/dio.dart';

class FilesUploaderHelper {
  final Dio _dio = Dio();

  /// Upload file to https://boker.egytag.com/x-api/upload/file
  /// Returns the "file" object map, e.g. { "name": ..., "path": ..., "url": ..., "size": ... }
  Future<Map<String, dynamic>?> uploadFile(String filePath) async {
    try {
      final fileName = filePath.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'files': [
          await MultipartFile.fromFile(filePath, filename: fileName),
        ],
      });

      final response = await _dio.post(
        'https://boker.egytag.com/x-api/upload/file',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['done'] == true && response.data['file'] != null) {
          return Map<String, dynamic>.from(response.data['file']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Upload image to https://boker.egytag.com/x-api/upload/image
  /// Returns the "image" object map, e.g. { "name": ..., "path": ..., "url": ..., "size": ... }
  Future<Map<String, dynamic>?> uploadImage(String imagePath) async {
    try {
      final fileName = imagePath.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'files': [
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ],
      });

      final response = await _dio.post(
        'https://boker.egytag.com/x-api/upload/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['done'] == true && response.data['image'] != null) {
          return Map<String, dynamic>.from(response.data['image']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Submit/Update User Form
  /// Endpoint: https://boker.egytag.com/api/manageUsers/updateUserForm
  Future<bool> updateUserForm({
    required String email,
    required Map<String, dynamic> identityForm,
    Map<String, dynamic>? addressForm,
  }) async {
    try {
      final response = await _dio.post(
        'https://boker.egytag.com/api/manageUsers/updateUserForm',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "email": email,
          "identityForm": identityForm,
          "addressForm": ?addressForm,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['done'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
