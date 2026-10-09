import '../../../../core/errors/failure.dart';
import '../data_source/ib_remote_data_source.dart';
import '../models/ib_dashboard_model.dart';
import '../models/ib_transaction_model.dart';

abstract class IbRepository {
  Future<Either<Failure, IbDashboardResponse>> getDashboardData({
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  });

  Future<Either<Failure, IbTransactionResponse>> getTransactions({
    required String typeCode,
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  });
}

class IbRepositoryImpl implements IbRepository {
  final IbRemoteDataSource remoteDataSource;

  IbRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, IbDashboardResponse>> getDashboardData({
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  }) async {
    try {
      final result = await remoteDataSource.getDashboardData(
        search: search,
        limit: limit,
        pageNumber: pageNumber,
        skip: skip,
      );
      return Right(result);
    } catch (e, st) {
      return ErrorHandler.handle(e, st).left();
    }
  }

  @override
  Future<Either<Failure, IbTransactionResponse>> getTransactions({
    required String typeCode,
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  }) async {
    try {
      final result = await remoteDataSource.getTransactions(
        typeCode: typeCode,
        search: search,
        limit: limit,
        pageNumber: pageNumber,
        skip: skip,
      );
      return Right(result);
    } catch (e, st) {
      return ErrorHandler.handle(e, st).left();
    }
  }
}
