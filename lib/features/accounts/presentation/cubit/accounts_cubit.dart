import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/accounts_repository.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final AccountsRepository _accountsRepository;

  AccountsCubit({required AccountsRepository accountsRepository})
      : _accountsRepository = accountsRepository,
        super(AccountsInitial());

  Future<void> fetchAccounts() async {
    emit(AccountsLoading());
    final result = await _accountsRepository.getAccounts();
    result.fold(
      (failure) => emit(AccountsError(failure.message)),
      (accounts) => emit(AccountsLoaded(accounts)),
    );
  }
}
