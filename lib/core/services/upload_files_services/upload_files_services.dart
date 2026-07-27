import 'package:dio/dio.dart';

import '../../di/di_container.dart';
import '../../errors/failure.dart';

class UploadFilesServices {
  static Future<Either<Failure, Map<String, dynamic>>> uploadImage(
    String imagePath,
  )
  async {
    final dio = di<Dio>();
    try {
      final fileName = imagePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'fileToUpload': [
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ],
      });
      final response = await dio.post(
        'https://boker.egytag.com/x-api/upload/image',
        data: formData,
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['done'] == true) {
        return Right(Map<String, dynamic>.from(response.data['image']));
      }
      return const Left(ServerFailure(message: 'Failed to upload image'));
    } catch (e, st) {
      return ErrorHandler.handle(e, st).left();
    }
  }

static  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String filePath,
  ) async {
    try {
      final dio = di<Dio>();
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'fileToUpload': [
          await MultipartFile.fromFile(filePath, filename: fileName),
        ],
      });
      final response = await dio.post(
        'https://boker.egytag.com/x-api/upload/file',
        data: formData,
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['done'] == true) {
        return Right(Map<String, dynamic>.from(response.data['file']));
      }
      return const Left(ServerFailure(message: 'Failed to upload file'));
    } catch (e, st) {
      return ErrorHandler.handle(e, st).left();
    }
  }
}
