import '../../data/models/create_account_models.dart';

abstract class CreateAccountState {}

class CreateAccountInitial extends CreateAccountState {}

class CreateAccountLoading extends CreateAccountState {}

class CreateAccountSuccess extends CreateAccountState {}

class CreateAccountError extends CreateAccountState {
  final String message;
  CreateAccountError(this.message);
}

class CreateAccountFormUpdated extends CreateAccountState {
  final bool isReal;
  final AccountTypeModel? selectedAccountType;
  final LeverageModel? selectedLeverage;
  final OpeningBalanceModel? selectedOpeningBalance;

  CreateAccountFormUpdated({
    required this.isReal,
    this.selectedAccountType,
    this.selectedLeverage,
    this.selectedOpeningBalance,
  });
}
