import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../data_source/notifications_remote_data_source.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsPage>> list({
    int limit,
    int skip,
    String search,
    bool unreadOnly,
  });

  Future<Either<Failure, NotificationSummary>> summary();

  Future<Either<Failure, void>> markSeen(List<String> ids);

  Future<Either<Failure, void>> markAllSeen();

  Future<Either<Failure, void>> delete(List<String> ids);

  Future<Either<Failure, void>> deleteAll();

  Future<Either<Failure, void>> registerDevice({
    required String token,
    required String platform,
  });

  Future<Either<Failure, void>> unregisterDevice({required String token});

  Stream<ActivityEvent> activityStream({CancelToken? cancelToken});
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NotificationsPage>> list({
    int limit = 15,
    int skip = 0,
    String search = '',
    bool unreadOnly = false,
  }) {
    return _guard(
      () => remoteDataSource.list(
        limit: limit,
        skip: skip,
        search: search,
        unreadOnly: unreadOnly,
      ),
    );
  }

  @override
  Future<Either<Failure, NotificationSummary>> summary() =>
      _guard(remoteDataSource.summary);

  @override
  Future<Either<Failure, void>> markSeen(List<String> ids) =>
      _guard(() => remoteDataSource.markSeen(ids: ids));

  @override
  Future<Either<Failure, void>> markAllSeen() =>
      _guard(() => remoteDataSource.markSeen(ids: 'all', seen: true));

  @override
  Future<Either<Failure, void>> delete(List<String> ids) =>
      _guard(() => remoteDataSource.delete(ids: ids));

  @override
  Future<Either<Failure, void>> deleteAll() =>
      _guard(() => remoteDataSource.delete(ids: 'all'));

  @override
  Future<Either<Failure, void>> registerDevice({
    required String token,
    required String platform,
  }) {
    return _guard(
      () => remoteDataSource.registerDevice(token: token, platform: platform),
    );
  }

  @override
  Future<Either<Failure, void>> unregisterDevice({required String token}) =>
      _guard(() => remoteDataSource.unregisterDevice(token: token));

  @override
  Stream<ActivityEvent> activityStream({CancelToken? cancelToken}) =>
      remoteDataSource.activityStream(cancelToken: cancelToken);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? (data['error'] ?? data['message'])?.toString()
          : null;
      return Left(
        ServerFailure(
          message:
              message ??
              (e.response != null
                  ? 'Server error (Code: ${e.response?.statusCode})'
                  : 'Connection failed. Please check your internet.'),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
