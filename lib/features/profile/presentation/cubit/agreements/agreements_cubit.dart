import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/agreements_repository.dart';
import 'agreements_state.dart';

class AgreementsCubit extends Cubit<AgreementsState> {
  final AgreementsRepository _repository;

  AgreementsCubit(this._repository) : super(const AgreementsState.initial());

  Future<void> fetchAgreements() async {
    emit(const AgreementsState.loading());
    try {
      final agreements = await _repository.fetchAgreements();
      emit(AgreementsState.success(agreements));
    } catch (e) {
      emit(AgreementsState.error(e.toString()));
    }
  }
}
