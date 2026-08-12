import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_methods_repository.dart';
import 'payment_methods_state.dart';

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  final PaymentMethodsRepository repository;

  PaymentMethodsCubit({required this.repository}) : super(PaymentMethodsInitial());

  Future<void> fetchPaymentMethods() async {
    emit(PaymentMethodsLoading());
    final result = await repository.getPaymentMethods();
    
    result.fold(
      (failure) => emit(PaymentMethodsError(message: failure.message)),
      (methods) => emit(PaymentMethodsLoaded(paymentMethods: methods)),
    );
  }

  Future<void> deletePaymentMethod(int code) async {
    emit(PaymentMethodsLoading());
    final result = await repository.deletePaymentMethod(code);
    
    result.fold(
      (failure) {
        emit(PaymentMethodsError(message: failure.message));
      },
      (_) {
        fetchPaymentMethods();
      },
    );
  }
}
