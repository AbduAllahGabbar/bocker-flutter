import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/di_container.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileCubit extends Cubit<void> {
  final ProfileRepository _profileRepository;

  ProfileCubit({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(null);

  Future<void> fetchUserView(String userId) async {
    final result = await _profileRepository.fetchUserView(userId);
    result.fold(
      (l) {},
      (user) {
        di<AuthCubit>().updateUser(user);
      },
    );
  }
}
