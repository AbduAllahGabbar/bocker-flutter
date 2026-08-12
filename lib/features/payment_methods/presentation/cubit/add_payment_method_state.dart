import '../../../transactions/data/models/payment_method_model.dart';
import '../../data/models/user_payment_method_model.dart';

abstract class AddPaymentMethodState {}

class AddPaymentMethodInitial extends AddPaymentMethodState {}

class AddPaymentMethodLoading extends AddPaymentMethodState {}

class AvailableMethodsLoaded extends AddPaymentMethodState {
  final List<PaymentMethodModel> methods;

  AvailableMethodsLoaded({required this.methods});
}

class AddPaymentSuccess extends AddPaymentMethodState {
  final UserPaymentMethodModel addedMethod;

  AddPaymentSuccess({required this.addedMethod});
}

class AddPaymentMethodError extends AddPaymentMethodState {
  final String message;

  AddPaymentMethodError({required this.message});
}
