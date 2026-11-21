import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../models/transaction_model.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../models/payment_method_model.dart';
import '../models/myfatoorah_quote_model.dart';
import '../data_source/transactions_remote_data_source.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, List<TransactionModel>>> getTransactions({
    String? type,
  });
  Future<Either<Failure, AddTransactionResult>> addTransaction(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, MyFatoorahQuoteModel>> getMyFatoorahQuote({
    required String accountId,
    required num amount,
  });
  Future<Either<Failure, List<AccountModel>>> getAccounts();
  Future<Either<Failure, List<PaymentMethodModel>>> getPaymentMethods({
    required String type,
  });
}

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource remoteDataSource;

  TransactionsRepositoryImpl({required this.remoteDataSource});

  /// Turns whatever went wrong into something worth showing the user.
  ///
  /// The backend answers its own validation failures - an ineligible account,
  /// a deposit under the minimum, a missing conversion rate, a gateway that is
  /// not configured - with a message, and that message is what the user needs
  /// to see, not a stringified exception.
  ///
  /// [mayHaveReachedServer] is set for calls that create something: when the
  /// answer is lost rather than refused, the request may still have been
  /// carried out, so the user is told to check before trying again instead of
  /// being invited to create a second transaction.
  Failure _failure(Object error, {bool mayHaveReachedServer = false}) {
    // The data source throws the backend's own `error` / `message` string.
    if (error is String) return ServerFailure(message: error);

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = (data['error'] ?? data['message'])?.toString().trim();
        if (message != null && message.isNotEmpty) {
          return ServerFailure(message: message);
        }
      }

      final interrupted =
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;

      if (interrupted) {
        return ServerFailure(
          message: mayHaveReachedServer
              ? 'The connection dropped before we got an answer. '
                    'Check your transaction history before trying again, so '
                    'you are not charged twice.'
              : 'Connection failed. Please check your internet.',
        );
      }

      final status = error.response?.statusCode;
      return ServerFailure(
        message: status != null
            ? 'Server error (Code: $status)'
            : 'Something went wrong. Please try again.',
      );
    }

    return ServerFailure(message: error.toString());
  }

  @override
  Future<Either<Failure, List<TransactionModel>>> getTransactions({
    String? type,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactions(type: type);
      return Right(transactions);
    } catch (e) {
      return Left(_failure(e));
    }
  }

  @override
  Future<Either<Failure, AddTransactionResult>> addTransaction(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.addTransaction(data);
      return Right(result);
    } catch (e) {
      return Left(_failure(e, mayHaveReachedServer: true));
    }
  }

  @override
  Future<Either<Failure, MyFatoorahQuoteModel>> getMyFatoorahQuote({
    required String accountId,
    required num amount,
  }) async {
    try {
      final quote = await remoteDataSource.getMyFatoorahQuote(
        accountId: accountId,
        amount: amount,
      );
      return Right(quote);
    } catch (e) {
      return Left(_failure(e));
    }
  }

  @override
  Future<Either<Failure, List<AccountModel>>> getAccounts() async {
    try {
      final accounts = await remoteDataSource.getAccounts();
      return Right(accounts);
    } catch (e) {
      return Left(_failure(e));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodModel>>> getPaymentMethods({
    required String type,
  }) async {
    try {
      final methods = await remoteDataSource.getPaymentMethods(type: type);
      return Right(methods);
    } catch (e) {
      return Left(_failure(e));
    }
  }
}
