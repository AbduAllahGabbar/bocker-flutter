import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_methods_repository.dart';
import 'add_payment_method_state.dart';

class AddPaymentMethodCubit extends Cubit<AddPaymentMethodState> {
  final PaymentMethodsRepository repository;

  AddPaymentMethodCubit({required this.repository}) : super(AddPaymentMethodInitial());

  Future<void> fetchAvailableMethods() async {
    emit(AddPaymentMethodLoading());
    final result = await repository.getAvailablePaymentMethods();
    
    result.fold(
      (failure) => emit(AddPaymentMethodError(message: failure.message)),
      (methods) => emit(AvailableMethodsLoaded(methods: methods)),
    );
  }

  Future<void> submitPaymentMethod(Map<String, dynamic> data) async {
    emit(AddPaymentMethodLoading());
    final result = await repository.addPaymentMethod(data);
    
    result.fold(
      (failure) => emit(AddPaymentMethodError(message: failure.message)),
      (addedMethod) => emit(AddPaymentSuccess(addedMethod: addedMethod)),
    );
  }
}
