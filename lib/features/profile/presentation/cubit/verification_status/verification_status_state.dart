import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../profile/data/models/document_model.dart';

part 'verification_status_state.freezed.dart';

@freezed
sealed class VerificationStatusState with _$VerificationStatusState {
  const factory VerificationStatusState.initial() = _Initial;
  const factory VerificationStatusState.loading() = _Loading;
  const factory VerificationStatusState.success({
    required IdentityDocumentModel identityForm,
    required AddressDocumentModel addressForm,
  }) = _Success;
  const factory VerificationStatusState.error(String message) = _Error;
}
