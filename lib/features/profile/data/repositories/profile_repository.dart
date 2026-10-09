import '../../../../core/errors/failure.dart';
import '../../../auth/data/models/user_model.dart';
import '../data_source/profile_remote_data_source.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> fetchUserView(String userId);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserModel>> fetchUserView(String userId) async {
    return await _remoteDataSource.fetchUserView(userId);
  }
}
