import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/payment_methods_repository.dart';
import 'add_payment_method_state.dart';

class AddPaymentMethodCubit extends Cubit<AddPaymentMethodState> {
  final PaymentMethodsRepository repository;

  AddPaymentMethodCubit({required this.repository})
    : super(AddPaymentMethodInitial());

  Future<void> fetchAvailableMethods() async {
    emit(AddPaymentMethodLoading());
    final result = await repository.getAvailablePaymentMethods();

    result.fold(
      (failure) => emit(AddPaymentMethodError(message: failure.message)),
      (methods) => emit(AvailableMethodsLoaded(methods: methods)),
    );
  }

  /// Saves a payment method.
  ///
  /// When [replacingCode] is supplied the save is an edit: the backend has no
  /// update endpoint, so the repository creates the new entry and then removes
  /// the old one.
  Future<void> submitPaymentMethod(
    Map<String, dynamic> data, {
    int? replacingCode,
  }) async {
    emit(AddPaymentMethodLoading());

    final result = replacingCode == null
        ? await repository.addPaymentMethod(data)
        : await repository.replacePaymentMethod(
            data: data,
            oldCode: replacingCode,
          );

    result.fold(
      (failure) => emit(AddPaymentMethodError(message: failure.message)),
      (addedMethod) => emit(
        AddPaymentSuccess(
          addedMethod: addedMethod,
          wasReplacement: replacingCode != null,
        ),
      ),
    );
  }
}
