import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required UserModel user,
    String? token,
    String? refreshToken,
    @Default(true) bool isSignIn,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.registrationPending(UserModel user) =
      _RegistrationPending;
  const factory AuthState.resetPasswordSent(String message) =
      _ResetPasswordSent;
  const factory AuthState.forgotPasswordOtpSent(String email) =
      _ForgotPasswordOtpSent;
  const factory AuthState.passwordUpdated() = _PasswordUpdated;
  const factory AuthState.otpRequired({
    String? customerId,
    String? phone,
    String? email,
  }) = _OtpRequired;
  const factory AuthState.emailOtpVerified() = _EmailOtpVerified;
  const factory AuthState.identitySubmitted() = _IdentitySubmitted;
  const factory AuthState.formNotCompleted({
    required String email,
    required String password,
  }) = _FormNotCompleted;
  const factory AuthState.error(String message) = _Error;
}
