import 'package:dio/dio.dart';
import 'package:boker/core/data/constants/apis_constants.dart';
import 'package:boker/core/network/dio/session_manager.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/upload_files_services/upload_files_services.dart';
import '../models/user_model.dart';
import '../models/register_response.dart';

/// Result of an email/password login attempt.
sealed class EmailLoginResult {
  const EmailLoginResult();

  const factory EmailLoginResult.authenticated(UserModel user) =
      AuthenticatedLoginResult;

  const factory EmailLoginResult.otpRequired({
    required String customerId,
    required String phone,
  }) = OtpRequiredLoginResult;

  const factory EmailLoginResult.formNotCompleted({
    required String email,
    required String password,
    String? accessToken,
  }) = FormNotCompletedLoginResult;
}

final class AuthenticatedLoginResult extends EmailLoginResult {
  final UserModel user;

  const AuthenticatedLoginResult(this.user);
}

final class OtpRequiredLoginResult extends EmailLoginResult {
  final String customerId;
  final String phone;

  const OtpRequiredLoginResult({required this.customerId, required this.phone});
}

final class FormNotCompletedLoginResult extends EmailLoginResult {
  final String email;
  final String password;
  final String? accessToken;

  const FormNotCompletedLoginResult({
    required this.email,
    required this.password,
    this.accessToken,
  });
}

abstract class AuthRemoteDataSource {
  Future<Either<Failure, EmailLoginResult>> signIn({
    required String emailOrPhone,
    required String password,
  });

  Future<Either<Failure, RegisterResponse>> signUp({
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, String>> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Map<String, dynamic>>> uploadImage(String imagePath);

  Future<Either<Failure, Map<String, dynamic>>> uploadFile(String filePath);

  Future<Either<Failure, bool>> updateUserForm({
    required String email,
    required String password,
    required Map<String, dynamic> identityForm,
    Map<String, dynamic>? addressForm,
  });

  Future<Either<Failure, String>> verifyOtp({
    required String phone,
    required String customerId,
    required String otp,
  });

  Future<Either<Failure, String>> resendOtp({required String customerId});

  Future<Either<Failure, String>> requestPhoneLoginOtp({required String phone});

  Future<Either<Failure, UserModel>> verifyPhoneLoginOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, void>> resetPassword({required String identifier});

  Future<Either<Failure, void>> sendForgotPasswordOtp({required String email});

  Future<Either<Failure, bool>> updatePasswordWithOtp({
    required String email,
    required String otp,
    required String password,
  });

  Future<void> signOut({String? accessToken});

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, UserModel>> getCurrentUser({String? token});

  Future<Either<Failure, bool>> updatePasswordProfile({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, bool>> updateIsIb();

  Future<Either<Failure, List<Map<String, dynamic>>>> getMt5Groups();

  // Future<UserModel> completeRegistration({
  //   required String userId,
  //   required UserRole role,
  // });
  // Future<void> resetPassword({required String email});
  // Future<UserModel> signInWithGoogle({bool isSignIn = true});
  // Stream<Session?> listenToAuthChanges();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  Future<String?> _saveAuthTokenFromResponse(dynamic responseData) async {
    if (responseData is! Map) {
      return null;
    }

    final token = _extractToken(responseData);
    if (token == null || token.isEmpty) {
      return null;
    }
    await SessionManager.instance.saveToken(token);
    return token;
  }

  String? _extractToken(Map data) {
    final rootToken =
        data['accessToken'] ?? data['access_token'] ?? data['token'];
    if (rootToken is String && rootToken.isNotEmpty) {
      return rootToken;
    }

    final session = data['session'];
    if (session is Map) {
      final accessToken = session['access_token'];
      if (accessToken is String && accessToken.isNotEmpty) {
        return accessToken;
      }
    }

    return null;
  }

  @override
  Future<Either<Failure, EmailLoginResult>> signIn({
    required String emailOrPhone,
    required String password,
  }) async {
    return _doSignIn(
      emailOrPhone: emailOrPhone,
      password: password,
      isRetry: false,
    );
  }

  Future<Either<Failure, EmailLoginResult>> _doSignIn({
    required String emailOrPhone,
    required String password,
    required bool isRetry,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {"email": emailOrPhone, "password": password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // If the server signals an active session conflict, logout and retry.
        final errorField = data['error'];
        if (!isRetry &&
            errorField != null &&
            errorField.toString().isNotEmpty) {
          final conflictToken = data['accessToken'] as String?;
          await signOut(accessToken: conflictToken);
          return await _doSignIn(
            emailOrPhone: emailOrPhone,
            password: password,
            isRetry: true,
          );
        }

        final accessToken = await _saveAuthTokenFromResponse(data);

        // Check if form is not completed
        if (data['isFormNotCompleted'] == true) {
          return Right(
            EmailLoginResult.formNotCompleted(
              email: emailOrPhone,
              password: password,
              accessToken: accessToken,
            ),
          );
        }

        final requiresPhoneVerification =
            data['requires_phone_verification'] as bool? ?? false;

        if (requiresPhoneVerification) {
          return Right(
            EmailLoginResult.otpRequired(
              customerId: data['customer_id'] as String? ?? '',
              phone: data['phone'] as String? ?? '',
            ),
          );
        }

        if (data['user'] != null) {
          // The session has to be live before the app enters the authenticated
          // area - the token arrives either in this body or in the response's
          // `Set-Cookie` header (captured by AuthInterceptor). If neither
          // carried one, say so instead of landing on a screen whose every
          // request answers 401.
          if (!SessionManager.instance.hasSession) {
            return Failure.server(
              'Signed in, but the server did not return a session. Please try again.',
            ).left();
          }

          final userJson = data['user'] as Map<String, dynamic>;
          final user = UserModel.fromJson(userJson);
          return Right(EmailLoginResult.authenticated(user));
        }

        return Failure.server(
          data['message'] ?? data['error'] ?? 'Failed to sign in',
        ).left();
      } else {
        return Failure.server(
          response.statusMessage ?? 'Failed to sign in',
        ).left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, RegisterResponse>> signUp({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration can already hand back a session. Persist it so the
        // screens that follow are authenticated without a restart.
        await _saveAuthTokenFromResponse(response.data);
        final registerResponse = RegisterResponse.fromJson(response.data);
        return Right(registerResponse);
      } else {
        return Failure.server(
          response.statusMessage ?? 'Failed to register',
        ).left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, String>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyEmailOtp,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {"email": email, "otp": otp},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Verifying the e-mail OTP is the step that activates the account, so
        // this is the other response that can carry a fresh session.
        await _saveAuthTokenFromResponse(response.data);
        return const Right("Success");
      } else {
        return Failure.server(
          response.statusMessage ?? 'Failed to verify OTP',
        ).left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadImage(
    String imagePath,
  ) async {
    return UploadFilesServices.uploadImage(imagePath);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String filePath,
  ) async {
    return UploadFilesServices.uploadFile(filePath);
  }

  @override
  Future<Either<Failure, bool>> updateUserForm({
    required String email,
    required String password,
    required Map<String, dynamic> identityForm,
    Map<String, dynamic>? addressForm,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateUserForm,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "email": email,
          "password": password,
          "identityForm": identityForm,
          "addressForm": ?addressForm,
        },
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['done'] == true) {
        await _saveAuthTokenFromResponse(response.data);
        return const Right(true);
      }
      return Left(
        ServerFailure(
          message: response.statusMessage ?? 'Failed to update user form',
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(message: _handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Phone/SMS authentication is NOT supported by this backend.
  ///
  /// Verified against the live API: `/store/auth/phone/request-otp`,
  /// `/auth/phone/request-otp`, `/user/sendOtp` and `/user/verify-phone-otp`
  /// all return HTTP 404. No endpoint is invented here - the caller gets an
  /// explicit failure and the phone login entry point is hidden in the UI.
  @override
  Future<Either<Failure, String>> requestPhoneLoginOtp({
    required String phone,
  }) async {
    return Failure.server(_phoneAuthUnsupportedMessage).left();
  }

  @override
  Future<Either<Failure, void>> sendForgotPasswordOtp({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.otpMailsAdd,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      }
      return Failure.server(
        response.data?['message'] ?? 'Failed to send OTP',
      ).left();
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, bool>> updatePasswordWithOtp({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updatePasswordWithOtp,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'email': email, 'otp': otp, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data['done'] == true) {
          return const Right(true);
        }
        return Failure.server(
          data?['message'] ?? 'Failed to update password',
        ).left();
      }
      return Failure.server(
        response.statusMessage ?? 'Failed to update password',
      ).left();
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, void>> signOut({String? accessToken}) async {
    try {
      final token = accessToken ?? await SessionManager.instance.readToken();

      final response = await _dio.delete(
        ApiConstants.signOut,
        options: Options(headers: {'access_token': ?token}),
      );

      // The local session is dropped either way: a failed logout call must
      // never leave an unusable token behind on the device.
      await SessionManager.instance.clear();

      if (response.statusCode != 200) {
        return Failure.server(
          response.statusMessage ?? 'Failed to sign out',
        ).left();
      }
      return const Right(null);
    } on DioException catch (e) {
      await SessionManager.instance.clear();
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      await SessionManager.instance.clear();
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final token = await SessionManager.instance.readToken();
      if (token == null) {
        return Failure.internal('Token not found').left();
      }

      final response = await _dio.delete(ApiConstants.account);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await SessionManager.instance.clear();
        return const Right(null);
      } else {
        return Failure.server('Failed to delete account').left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser({String? token}) async {
    try {
      if (token != null && token.isNotEmpty) {
        await SessionManager.instance.saveToken(token);
      }
      final currentToken = await SessionManager.instance.readToken();
      if (currentToken == null) {
        return Left(Failure.internal('Token not found'));
      }
      // The session cookie is attached by AuthInterceptor for every request.
      var response = await _dio.post(ApiConstants.userView);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['doc']);
        return Right(user);
      } else {
        return Failure.server('Failed to get current user').left();
      }
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, bool>> updatePasswordProfile({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updatePasswordProfile,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Failure.server(
          response.statusMessage ?? 'Failed to update password',
        ).left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, bool>> updateIsIb() async {
    try {
      final token = await SessionManager.instance.readToken();
      if (token == null) {
        return Left(Failure.internal('Token not found'));
      }

      final response = await _dio.post(
        ApiConstants.updateIsIb,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Failure.server(
          response.statusMessage ?? 'Failed to become IB',
        ).left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMt5Groups() async {
    try {
      final response = await _dio.post(ApiConstants.mt5GroupsPublic, data: {});
      if (response.statusCode == 200 && response.data['done'] == true) {
        final list = response.data['list'] as List;
        return Right(list.cast<Map<String, dynamic>>());
      } else {
        return Failure.server('Failed to load MT5 Groups').left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      // Check for specific error message representations based on API behavior
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      return 'Server error (Code: ${e.response?.statusCode})';
    }
    return 'Connection failed. Please check your internet.';
  }

  /// Phone OTP resend - see [requestPhoneLoginOtp]: unsupported backend-side.
  @override
  Future<Either<Failure, String>> resendOtp({
    required String customerId,
  }) async {
    return Failure.server(_phoneAuthUnsupportedMessage).left();
  }

  /// Password reset runs through the e-mail OTP flow
  /// ([sendForgotPasswordOtp] + [updatePasswordWithOtp]); there is no
  /// single-shot reset endpoint on this backend.
  @override
  Future<Either<Failure, void>> resetPassword({
    required String identifier,
  }) async {
    return sendForgotPasswordOtp(email: identifier);
  }

  /// Phone OTP verification - see [requestPhoneLoginOtp].
  @override
  Future<Either<Failure, String>> verifyOtp({
    required String phone,
    required String customerId,
    required String otp,
  }) async {
    return Failure.server(_phoneAuthUnsupportedMessage).left();
  }

  /// Phone OTP login - see [requestPhoneLoginOtp].
  @override
  Future<Either<Failure, UserModel>> verifyPhoneLoginOtp({
    required String phone,
    required String otp,
  }) async {
    return Failure.server(_phoneAuthUnsupportedMessage).left();
  }

  static const String _phoneAuthUnsupportedMessage =
      'Phone verification is not available in the app yet. '
      'Please sign in with your email and password.';
}
