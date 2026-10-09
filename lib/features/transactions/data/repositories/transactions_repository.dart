import '../../../../core/errors/failure.dart';
import '../models/transaction_model.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../models/payment_method_model.dart';
import '../data_source/transactions_remote_data_source.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, List<TransactionModel>>> getTransactions({String? type});
  Future<Either<Failure, TransactionModel>> addTransaction(Map<String, dynamic> data);
  Future<Either<Failure, List<AccountModel>>> getAccounts();
  Future<Either<Failure, List<PaymentMethodModel>>> getPaymentMethods({required String type});
}

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource remoteDataSource;

  TransactionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TransactionModel>>> getTransactions({String? type}) async {
    try {
      final transactions = await remoteDataSource.getTransactions(type: type);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionModel>> addTransaction(Map<String, dynamic> data) async {
    try {
      final transaction = await remoteDataSource.addTransaction(data);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccountModel>>> getAccounts() async {
    try {
      final accounts = await remoteDataSource.getAccounts();
      return Right(accounts);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodModel>>> getPaymentMethods({required String type}) async {
    try {
      final methods = await remoteDataSource.getPaymentMethods(type: type);
      return Right(methods);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
