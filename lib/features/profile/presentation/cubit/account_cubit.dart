import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../auth/data/repository/user_access.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountState.initial(UserAccess.user));

  void syncUser() {
    final user = UserAccess.user;
    emit(
      state.copyWith(
        user: user,
      ),
    );
  }


}
