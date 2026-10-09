import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../models/account_model.dart';
import '../models/create_account_models.dart';

abstract class AccountsRemoteDataSource {
  Future<Either<Failure, List<AccountModel>>> getAccounts();
  Future<Either<Failure, List<AccountTypeModel>>> getAccountTypes();
  Future<Either<Failure, List<LeverageModel>>> getLeverages();
  Future<Either<Failure, List<OpeningBalanceModel>>> getOpeningBalances();
  Future<Either<Failure, AccountModel>> createAccount(Map<String, dynamic> data);
}

class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {
  final Dio _dio;

  AccountsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, List<AccountModel>>> getAccounts() async {
    try {
      final response = await _dio.post(
        '/accounts/all',
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['done'] == true) {
          final list = data['list'] as List?;
          if (list != null) {
            final accounts = list
                .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
                .toList();
            return Right(accounts);
          }
        }
        return const Right([]);
      } else {
        return Failure.server('Failed to get accounts').left();
      }
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, List<AccountTypeModel>>> getAccountTypes() async {
    try {
      final response = await _dio.post('/accountTypeList', data: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['done'] == true) {
          final list = data['list'] as List?;
          if (list != null) {
            return Right(list.map((e) => AccountTypeModel.fromJson(e)).toList());
          }
        }
        return const Right([]);
      }
      return Failure.server('Failed to get account types').left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, List<LeverageModel>>> getLeverages() async {
    try {
      final response = await _dio.post('/leverageList', data: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['done'] == true) {
          final list = data['list'] as List?;
          if (list != null) {
            return Right(list.map((e) => LeverageModel.fromJson(e)).toList());
          }
        }
        return const Right([]);
      }
      return Failure.server('Failed to get leverages').left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, List<OpeningBalanceModel>>> getOpeningBalances() async {
    try {
      final response = await _dio.post('/openingBalanceList', data: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['done'] == true) {
          final list = data['list'] as List?;
          if (list != null) {
            return Right(list.map((e) => OpeningBalanceModel.fromJson(e)).toList());
          }
        }
        return const Right([]);
      }
      return Failure.server('Failed to get opening balances').left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, AccountModel>> createAccount(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/accounts/add', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map<String, dynamic> && resData['done'] == true) {
          final doc = resData['doc'];
          if (doc != null) {
            return Right(AccountModel.fromJson(doc));
          }
        }
      }
      return Failure.server('Failed to create account').left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }
}
