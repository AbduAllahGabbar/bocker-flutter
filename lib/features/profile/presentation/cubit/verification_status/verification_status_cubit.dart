import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/verification_repository.dart';
import 'verification_status_state.dart';

class VerificationStatusCubit extends Cubit<VerificationStatusState> {
  final VerificationRepository _repository;

  VerificationStatusCubit(this._repository) : super(const VerificationStatusState.initial());

  Future<void> fetchVerificationStatus(dynamic userId) async {
    emit(const VerificationStatusState.loading());
    try {
      final verificationDoc = await _repository.fetchVerificationStatus(userId);
      emit(VerificationStatusState.success(
        identityForm: verificationDoc.identityForm,
        addressForm: verificationDoc.addressForm,
      ));
    } catch (e) {
      emit(VerificationStatusState.error(e.toString()));
    }
  }
}
