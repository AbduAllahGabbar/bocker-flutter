import '../../../../core/errors/failure.dart';
import '../models/account_model.dart';
import '../models/create_account_models.dart';
import '../data_source/accounts_remote_data_source.dart';

abstract class AccountsRepository {
  Future<Either<Failure, List<AccountModel>>> getAccounts();
  Future<Either<Failure, List<AccountTypeModel>>> getAccountTypes();
  Future<Either<Failure, List<LeverageModel>>> getLeverages();
  Future<Either<Failure, List<OpeningBalanceModel>>> getOpeningBalances();
  Future<Either<Failure, AccountModel>> createAccount(Map<String, dynamic> data);
}

class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource _remoteDataSource;

  AccountsRepositoryImpl({required AccountsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<AccountModel>>> getAccounts() async {
    return await _remoteDataSource.getAccounts();
  }

  @override
  Future<Either<Failure, List<AccountTypeModel>>> getAccountTypes() async {
    return await _remoteDataSource.getAccountTypes();
  }

  @override
  Future<Either<Failure, List<LeverageModel>>> getLeverages() async {
    return await _remoteDataSource.getLeverages();
  }

  @override
  Future<Either<Failure, List<OpeningBalanceModel>>> getOpeningBalances() async {
    return await _remoteDataSource.getOpeningBalances();
  }

  @override
  Future<Either<Failure, AccountModel>> createAccount(Map<String, dynamic> data) async {
    return await _remoteDataSource.createAccount(data);
  }
}
