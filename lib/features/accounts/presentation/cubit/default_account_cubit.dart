import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/account_model.dart';

/// Holds the account the user picked as their default.
///
/// Registered as a singleton and provided above the router, so every feature
/// reads the same selection and rebuilds as soon as it changes.
class DefaultAccountCubit extends Cubit<AccountModel?> {
  DefaultAccountCubit() : super(null);

  /// The user picked [account] as their default.
  void select(AccountModel account) {
    if (state?.id == account.id) return;
    emit(account);
  }

  /// Keeps the selection in step with the latest account list.
  ///
  /// The chosen account is kept when it still exists - refreshed, so its new
  /// balance propagates - otherwise the first real account is chosen, falling
  /// back to the first account of any kind.
  void syncWith(List<AccountModel> accounts) {
    if (accounts.isEmpty) {
      if (state != null) emit(null);
      return;
    }

    final current = state;
    AccountModel? match;
    if (current != null) {
      for (final account in accounts) {
        if (account.id == current.id) {
          match = account;
          break;
        }
      }
    }

    emit(
      match ??
          accounts.firstWhere(
            (a) => a.type == 'real',
            orElse: () => accounts.first,
          ),
    );
  }
}
