import 'package:dio/dio.dart';
import 'package:boker/core/data/constants/apis_constants.dart';
import 'package:boker/core/config/local/token_cache_service.dart';
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
    CacheSecureStorage.saveTokens(accessToken: token);
    return token;
  }

  String? _extractToken(Map data) {
    final rootToken = data['accessToken'] ?? data['token'];
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
        '/user/login',
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
          return _doSignIn(
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
        '/user/register',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
        '/user/verifyEmailOtp',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {"email": email, "otp": otp},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
        '/manageUsers/updateUserForm',
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

  @override
  Future<Either<Failure, String>> requestPhoneLoginOtp({
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        '/store/auth/phone/request-otp',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: {"phone": phone},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message =
            response.data['message'] as String? ?? 'OTP sent successfully';
        return Right(message);
      } else {
        return Failure.server(
          response.data['error'] ?? 'Failed to send OTP',
        ).left();
      }
    } on DioException catch (e) {
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, void>> sendForgotPasswordOtp({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/otpMails/add',
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
        '/user/updatePasswordWithOtp',
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
      final token = accessToken ?? await CacheSecureStorage.getAccessToken();

      final response = await _dio.delete(
        ApiConstants.signOut,
        options: Options(headers: {'access_token': ?token}),
      );

      if (response.statusCode == 200) {
        await CacheSecureStorage.clearTokens();
      } else {
        await CacheSecureStorage.clearTokens();

        return Failure.server(
          response.statusMessage ?? 'Failed to sign out',
        ).left();
      }
      return const Right(null);
    } on DioException catch (e) {
      await CacheSecureStorage.clearTokens();
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      await CacheSecureStorage.clearTokens();
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final token = await CacheSecureStorage.getAccessToken();
      if (token == null) {
        return Failure.internal('Token not found').left();
      }

      final response = await _dio.delete(ApiConstants.account);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await CacheSecureStorage.clearTokens();
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
      final currentToken = token ?? await CacheSecureStorage.getAccessToken();
      if (currentToken == null) {
        return Left(Failure.internal('Token not found'));
      }
      var response = await _dio.post(
        '/user/view',
        options: Options(
          headers: {
            'Cookie': 'access_token=$currentToken;access_token=$currentToken',
          },
        ),
      );

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
        '/user/update-password-profile',
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
      final token = await CacheSecureStorage.getAccessToken();
      if (token == null) {
        return Left(Failure.internal('Token not found'));
      }

      final response = await _dio.post(
        '/user/update-isIb',
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
      final response = await _dio.post('/site-setting/mt5Groups-public', data: {});
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

  @override
  Future<Either<Failure, String>> resendOtp({required String customerId}) {
    // TODO: implement resendOtp
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String identifier}) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String phone,
    required String customerId,
    required String otp,
  }) {
    // TODO: implement verifyOtp
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> verifyPhoneLoginOtp({
    required String phone,
    required String otp,
  }) {
    // TODO: implement verifyPhoneLoginOtp
    throw UnimplementedError();
  }
}
