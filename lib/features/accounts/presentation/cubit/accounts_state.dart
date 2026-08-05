import '../../data/models/account_model.dart';

abstract class AccountsState {}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<AccountModel> accounts;

  AccountsLoaded(this.accounts);
}

class AccountsError extends AccountsState {
  final String message;

  AccountsError(this.message);
}
