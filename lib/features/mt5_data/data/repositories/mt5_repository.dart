
import '../../../../core/errors/failure.dart';
import '../models/mt5_summary_model.dart';
import '../models/mt5_item_model.dart';
import '../data_source/mt5_remote_data_source.dart';

abstract class Mt5Repository {
  Future<Either<Failure, Mt5SummaryModel>> getSummary(String accountId);
  Future<Either<Failure, List<Mt5ItemModel>>> getList(Map<String, dynamic> requestBody);
  Future<Either<Failure, void>> syncAccount(String accountId);
}

class Mt5RepositoryImpl implements Mt5Repository {
  final Mt5RemoteDataSource remoteDataSource;

  Mt5RepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Mt5SummaryModel>> getSummary(String accountId) async {
    try {
      final result = await remoteDataSource.getSummary(accountId);
      return Right(result);
    } catch (e, st) {
      return ErrorHandler.handle(e, st).left();
    }
  }

  @override
  Future<Either<Failure, List<Mt5ItemModel>>> getList(Map<String, dynamic> requestBody) async {
    try {
      final result = await remoteDataSource.getList(requestBody);
      return Right(result);
    } catch (e, st) {
      return ErrorHandler.handle(e, st).left();
    }
  }

  @override
  Future<Either<Failure, void>> syncAccount(String accountId) async {
    try {
      await remoteDataSource.syncAccount(accountId);
      return const Right(null);
    } catch (e, st) {
      return ErrorHandler.handle(e, st).left();
    }
  }
}
