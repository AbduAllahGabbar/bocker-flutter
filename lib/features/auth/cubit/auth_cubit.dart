import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failure.dart';
import '../data/auth_repository.dart';
import '../data/data_source/auth_remote_data_source.dart';
import '../data/models/user_model.dart';
import '../data/repository/user_access.dart';
import '../../../core/network/dio/session_manager.dart';
import '../../../core/services/notifications/notifications_bootstrap.dart';
import '../../../core/services/referral/referral_service.dart';
import 'auth_state.dart' as auth_state;

class AuthCubit extends Cubit<auth_state.AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const auth_state.AuthState.initial());

  Future<void> signIn({
    required String emailOrPhone,
    required String password,
  }) async {
    emit(const auth_state.AuthState.loading());
    final result = await _authRepository.signIn(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    result.fold((l) => emit(auth_state.AuthState.error(l.message)), (
      loginResult,
    ) {
      switch (loginResult) {
        case AuthenticatedLoginResult(:final user):
          emit(
            auth_state.AuthState.authenticated(
              user: user,
              token: UserAccess.accessToken,
            ),
          );
          // Register this device for push and start the live counters.
          unawaited(NotificationsBootstrap.instance.onSignedIn());
        case OtpRequiredLoginResult(:final customerId, :final phone):
          emit(
            auth_state.AuthState.otpRequired(
              customerId: customerId,
              phone: phone,
            ),
          );
        case FormNotCompletedLoginResult(:final email, :final password):
          emit(
            auth_state.AuthState.formNotCompleted(
              email: email,
              password: password,
            ),
          );
      }
    });
  }

  Future<void> signUp({required Map<String, dynamic> data}) async {
    emit(const auth_state.AuthState.loading());
    final result = await _authRepository.signUp(data: data);
    result.fold((l) => emit(auth_state.AuthState.error(l.message)), (response) {
      if (response.done) {
        // The account exists now, so the affiliate referral has been consumed.
        // This is the only place it is cleared - a failed registration keeps
        // it for the next attempt.
        unawaited(ReferralService.instance.clear());
        emit(auth_state.AuthState.otpRequired(email: response.email));
      } else {
        emit(const auth_state.AuthState.unauthenticated());
      }
    });
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    emit(const auth_state.AuthState.loading());
    final result = await _authRepository.verifyEmailOtp(email: email, otp: otp);
    result.fold((l) => emit(auth_state.AuthState.error(l.message)), (_) {
      emit(const auth_state.AuthState.emailOtpVerified());
    });
  }

  Future<void> submitIdentityVerification({
    required String email,
    required String password,
    required String docType,
    required String docExpiry,
    required String docNumber,
    required Map<String, dynamic> countryIssue,
    required String frontSidePath,
    String? backSidePath,
    String? otherDocPath,
    Map<String, dynamic>? addressCountry,
    String? city,
    String? address,
    String? postalCode,
    String? addressDocPath,
  }) async {
    emit(const auth_state.AuthState.loading());

    // 1. Upload front image
    final frontRes = await _authRepository.uploadImage(frontSidePath);
    Map<String, dynamic> frontMap = {};
    frontRes.fold((l) {}, (r) => frontMap = r);

    if (frontMap.isEmpty) {
      emit(
        const auth_state.AuthState.error('Failed to upload front side image'),
      );
      return;
    }

    // 2. Upload back image if provided
    Map<String, dynamic> backMap = {};
    if (backSidePath != null && backSidePath.isNotEmpty) {
      final backRes = await _authRepository.uploadImage(backSidePath);
      backRes.fold((_) {}, (r) => backMap = r);
    }

    // 3. Upload other document if provided
    Map<String, dynamic> fileMap = {};
    if (otherDocPath != null && otherDocPath.isNotEmpty) {
      final fileRes = await _authRepository.uploadFile(otherDocPath);
      fileRes.fold((_) {}, (r) => fileMap = r);
    }

    // 4. Upload address document if provided
    Map<String, dynamic> addressDocMap = {};
    if (addressDocPath != null && addressDocPath.isNotEmpty) {
      final addressDocRes = await _authRepository.uploadFile(addressDocPath);
      addressDocRes.fold((_) {}, (r) => addressDocMap = r);
    }

    // 5. Assemble identityForm map
    final identityForm = {
      "docType": docType,
      "docExpiry": docExpiry,
      "docNumber": docNumber,
      "countryIssue": countryIssue,
      "imageFrontSide": frontMap,
      "imageBackSide": backMap,
      "file": fileMap,
    };

    // 6. Assemble addressForm map
    final addressForm = {
      "country": addressCountry ?? countryIssue,
      "city": (city != null && city.trim().isNotEmpty) ? city.trim() : "City",
      "address": (address != null && address.trim().isNotEmpty)
          ? address.trim()
          : "Address",
      "postalCode": (postalCode != null && postalCode.trim().isNotEmpty)
          ? postalCode.trim()
          : "12345",
      "document": addressDocMap,
    };

    // 7. Update user form
    final result = await _authRepository.updateUserForm(
      email: email,
      password: password,
      identityForm: identityForm,
      addressForm: addressForm,
    );

    result.fold((l) => emit(auth_state.AuthState.error(l.message)), (success) {
      if (success) {
        emit(const auth_state.AuthState.identitySubmitted());
      } else {
        emit(
          const auth_state.AuthState.error('Failed to update identity form'),
        );
      }
    });
  }

  Future<void> verifyOtp({
    required String phone,
    required String customerId,
    required String otp,
  }) async {
    emit(const auth_state.AuthState.loading());
    String normalizedPhone = phone.trim();
    if (normalizedPhone.contains('-')) {
      final parts = normalizedPhone.split('-');
      if (parts.length >= 3) {
        normalizedPhone = '${parts[1]}${parts[2]}';
      }
    }
    final result = await _authRepository.verifyOtp(
      phone: normalizedPhone,
      customerId: customerId,
      otp: otp,
    );
    result.fold(
      (l) => emit(auth_state.AuthState.error(l.message)),
      (_) => emit(const auth_state.AuthState.unauthenticated()),
    );
  }

  Future<Either<Failure, String>> resendOtp({
    required String customerId,
  }) async {
    return await _authRepository.resendOtp(customerId: customerId);
  }

  Future<void> requestPhoneLoginOtp({required String phone}) async {
    emit(const auth_state.AuthState.loading());
    String normalizedPhone = phone.trim();
    if (normalizedPhone.contains('-')) {
      final parts = normalizedPhone.split('-');
      if (parts.length >= 3) {
        normalizedPhone = '${parts[1]}${parts[2]}';
      }
    }

    final result = await _authRepository.requestPhoneLoginOtp(
      phone: normalizedPhone,
    );

    result.fold((l) => emit(auth_state.AuthState.error(l.message)), (message) {
      emit(
        auth_state.AuthState.otpRequired(
          customerId: 'phone_login',
          phone: normalizedPhone,
        ),
      );
    });
  }

  Future<void> verifyPhoneLoginOtp({
    required String phone,
    required String otp,
  }) async {
    emit(const auth_state.AuthState.loading());
    String normalizedPhone = phone.trim();
    if (normalizedPhone.contains('-')) {
      final parts = normalizedPhone.split('-');
      if (parts.length >= 3) {
        normalizedPhone = '${parts[1]}${parts[2]}';
      }
    }

    final result = await _authRepository.verifyPhoneLoginOtp(
      phone: normalizedPhone,
      otp: otp,
    );
    result.fold(
      (l) => emit(auth_state.AuthState.error(l.message)),
      (user) => emit(auth_state.AuthState.authenticated(user: user)),
    );
  }

  Future<void> resetPassword({required String identifier}) async {
    emit(const auth_state.AuthState.loading());
    final result = await _authRepository.resetPassword(identifier: identifier);
    result.fold(
      (l) => emit(auth_state.AuthState.error(l.message)),
      (_) => emit(
        auth_state.AuthState.resetPasswordSent(
          'Check your email or phone for reset instructions.',
        ),
      ),
    );
  }

  /// Re-sends the registration e-mail OTP through the backend's
  /// `POST /api/otpMails/add` endpoint (the same endpoint the Web portal uses
  /// to issue an e-mail OTP).
  ///
  /// Returns an error message on failure, or `null` on success. The auth state
  /// is deliberately left untouched so the OTP screen stays visible.
  Future<String?> resendEmailOtp({required String email}) async {
    final result = await _authRepository.sendForgotPasswordOtp(email: email);
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<void> sendForgotPasswordOtp({required String email}) async {
    emit(const auth_state.AuthState.loading());
    final result = await _authRepository.sendForgotPasswordOtp(email: email);
    result.fold(
      (l) => emit(auth_state.AuthState.error(l.message)),
      (_) => emit(auth_state.AuthState.forgotPasswordOtpSent(email)),
    );
  }

  Future<void> updatePasswordWithOtp({
    required String email,
    required String otp,
    required String password,
  }) async {
    emit(const auth_state.AuthState.loading());
    final result = await _authRepository.updatePasswordWithOtp(
      email: email,
      otp: otp,
      password: password,
    );
    result.fold(
      (l) => emit(auth_state.AuthState.error(l.message)),
      (_) => emit(const auth_state.AuthState.passwordUpdated()),
    );
  }

  Future<void> signOut() async {
    try {
      emit(const auth_state.AuthState.loading());
      // Unregister the device while the session is still valid.
      await NotificationsBootstrap.instance.onSignedOut();
      await _authRepository.signOut();
      emit(const auth_state.AuthState.unauthenticated());
    } catch (e) {
      emit(auth_state.AuthState.error(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    try {
      emit(const auth_state.AuthState.loading());
      await NotificationsBootstrap.instance.onSignedOut();
      final result = await _authRepository.deleteAccount();
      result.fold(
        (l) => emit(auth_state.AuthState.error(l.message)),
        (_) => emit(const auth_state.AuthState.unauthenticated()),
      );
    } catch (e) {
      emit(auth_state.AuthState.error(e.toString()));
    }
  }

  Future<void> getCurrentUser() async {
    // Without a stored session there is nothing to restore - go straight to
    // the unauthenticated state instead of surfacing a bogus error on start-up.
    if (!await SessionManager.instance.readToken().then((t) => t != null)) {
      emit(const auth_state.AuthState.unauthenticated());
      return;
    }

    emit(const auth_state.AuthState.loading());
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (l) => emit(auth_state.AuthState.error(l.message)),
      (user) => emit(
        auth_state.AuthState.authenticated(
          user: user,
          token: UserAccess.accessToken,
        ),
      ),
    );
  }

  /// Drops the local session without calling the backend.
  ///
  /// Used when the backend has already rejected the session with HTTP 401 -
  /// calling `/user/logout` with an invalid token would only fail again.
  Future<void> forceSignOut() async {
    await SessionManager.instance.clear();
    if (isClosed) return;
    emit(const auth_state.AuthState.unauthenticated());
  }

  void updateAddresses(List<Map<String, dynamic>> newAddresses) {
    state.mapOrNull(
      authenticated: (s) {
        final updatedUser = s.user.copyWith(addresses: newAddresses);
        emit(s.copyWith(user: updatedUser));
      },
    );
  }

  void updateUser(UserModel user) {
    emit(
      auth_state.AuthState.authenticated(
        user: user,
        token: UserAccess.accessToken,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getMt5Groups() async {
    final result = await _authRepository.getMt5Groups();
    return result.fold((l) => [], (r) => r);
  }
}
