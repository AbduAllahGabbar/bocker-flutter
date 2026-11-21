import '../../../../core/errors/failure.dart';
import '../data_sources/payment_methods_remote_data_source.dart';
import '../models/user_payment_method_model.dart';
import '../../../transactions/data/models/payment_method_model.dart';

abstract class PaymentMethodsRepository {
  Future<Either<Failure, List<UserPaymentMethodModel>>> getPaymentMethods();
  Future<Either<Failure, void>> deletePaymentMethod(int code);
  Future<Either<Failure, List<PaymentMethodModel>>>
  getAvailablePaymentMethods();
  Future<Either<Failure, UserPaymentMethodModel>> addPaymentMethod(
    Map<String, dynamic> data,
  );

  /// Replaces an existing saved payment method.
  ///
  /// The backend exposes no update endpoint (`/user/updatePaymentMethod` and
  /// `/user/editPaymentMethod` both return HTTP 404), so an edit is carried
  /// out as add-then-delete. The new entry is created **first**: if that call
  /// fails, the original method is left untouched.
  Future<Either<Failure, UserPaymentMethodModel>> replacePaymentMethod({
    required Map<String, dynamic> data,
    required int oldCode,
  });
}

class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  final PaymentMethodsRemoteDataSource remoteDataSource;

  PaymentMethodsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserPaymentMethodModel>>>
  getPaymentMethods() async {
    try {
      final methods = await remoteDataSource.getPaymentMethods();
      return Right(methods);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentMethod(int code) async {
    try {
      await remoteDataSource.deletePaymentMethod(code);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodModel>>>
  getAvailablePaymentMethods() async {
    try {
      final methods = await remoteDataSource.getAvailablePaymentMethods();
      return Right(methods);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPaymentMethodModel>> addPaymentMethod(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await remoteDataSource.addPaymentMethod(data);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPaymentMethodModel>> replacePaymentMethod({
    required Map<String, dynamic> data,
    required int oldCode,
  }) async {
    final UserPaymentMethodModel created;
    try {
      created = await remoteDataSource.addPaymentMethod(data);
    } catch (e) {
      // Nothing was changed server-side; the original method still stands.
      return Left(ServerFailure(message: e.toString()));
    }

    try {
      await remoteDataSource.deletePaymentMethod(oldCode);
    } catch (e) {
      // The replacement exists but the old entry could not be removed. Report
      // it so the user can delete it manually instead of silently leaving two.
      return Left(
        ServerFailure(
          message:
              'The new payment method was saved, but the old one could not be '
              'removed. Please delete it manually. ($e)',
        ),
      );
    }

    return Right(created);
  }
}
