import 'package:dio/dio.dart';
import 'package:boker/core/config/local/token_cache_service.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRemoteDataSource {
  Future<Either<Failure, UserModel>> fetchUserView(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, UserModel>> fetchUserView(String userId) async {
    try {


      final response = await _dio.post(
        '/user/view',
        data: {'id': userId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('user')) {
          final user = UserModel.fromJson(data['user']);
          return Right(user);
        } else if (data is Map<String, dynamic> && data.containsKey('doc')) {
          final user = UserModel.fromJson(data['doc']);
          return Right(user);
        } else {
          // Maybe the user data is at the root or another key. Try to parse directly if no 'user' key.
          if (data is Map<String, dynamic> &&
              (data.containsKey('id') || data.containsKey('_id'))) {
            final user = UserModel.fromJson(data);
            return Right(user);
          }
          return Failure.server('Invalid user data format').left();
        }
      } else {
        return Failure.server('Failed to get user view').left();
      }
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }
}
