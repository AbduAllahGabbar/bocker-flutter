
import '../../data/models/user_payment_method_model.dart';

abstract class PaymentMethodsState {}

class PaymentMethodsInitial extends PaymentMethodsState {}

class PaymentMethodsLoading extends PaymentMethodsState {}

class PaymentMethodsLoaded extends PaymentMethodsState {
  final List<UserPaymentMethodModel> paymentMethods;

  PaymentMethodsLoaded({required this.paymentMethods});
}

class PaymentMethodsError extends PaymentMethodsState {
  final String message;

  PaymentMethodsError({required this.message});
}
