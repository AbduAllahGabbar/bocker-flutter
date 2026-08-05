import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../auth/data/repository/user_access.dart';
import 'package:boker/core/errors/failure.dart';
import 'package:boker/core/di/di_container.dart';
import 'package:boker/features/auth/data/auth_repository.dart';
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

  Future<Either<Failure, bool>> updatePasswordProfile({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await di<AuthRepository>().updatePasswordProfile(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
