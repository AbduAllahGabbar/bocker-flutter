import '../../data/models/account_model.dart';
import '../../data/models/create_account_models.dart';

abstract class CreateAccountState {}

class CreateAccountInitial extends CreateAccountState {}

class CreateAccountLoading extends CreateAccountState {}

/// Carries the account the backend actually created, so the UI can show the
/// real result (account code, approval status, MT5 details) instead of a
/// generic confirmation.
class CreateAccountSuccess extends CreateAccountState {
  final AccountModel account;

  CreateAccountSuccess(this.account);
}

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
