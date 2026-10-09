import '../../../../core/errors/failure.dart';
import '../data_sources/payment_methods_remote_data_source.dart';
import '../models/user_payment_method_model.dart';
import '../../../transactions/data/models/payment_method_model.dart';

abstract class PaymentMethodsRepository {
  Future<Either<Failure, List<UserPaymentMethodModel>>> getPaymentMethods();
  Future<Either<Failure, void>> deletePaymentMethod(int code);
  Future<Either<Failure, List<PaymentMethodModel>>> getAvailablePaymentMethods();
  Future<Either<Failure, UserPaymentMethodModel>> addPaymentMethod(Map<String, dynamic> data);
}

class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  final PaymentMethodsRemoteDataSource remoteDataSource;

  PaymentMethodsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserPaymentMethodModel>>> getPaymentMethods() async {
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
  Future<Either<Failure, List<PaymentMethodModel>>> getAvailablePaymentMethods() async {
    try {
      final methods = await remoteDataSource.getAvailablePaymentMethods();
      return Right(methods);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPaymentMethodModel>> addPaymentMethod(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.addPaymentMethod(data);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
