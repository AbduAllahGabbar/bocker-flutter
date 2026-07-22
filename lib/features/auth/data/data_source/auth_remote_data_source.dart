import 'package:dio/dio.dart';
import 'package:boker/core/data/constants/apis_constants.dart';
import 'package:boker/core/config/local/token_cache_service.dart';
import '../../../../core/errors/failure.dart';
import '../enums/user_role.dart';
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

  Future<Either<Failure, String>> resendOtp({
    required String customerId,
  });

  Future<Either<Failure, String>> requestPhoneLoginOtp({
    required String phone,
  });

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

  Future<void> signOut();

  Future<Either<Failure, void>> deleteAccount();


  Future<Either<Failure, UserModel>> getCurrentUser({String? token});

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
  final TokenCacheService _tokenCacheHelper;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    required TokenCacheService tokenCacheHelper,
  }) : _dio = dio,
        _tokenCacheHelper = tokenCacheHelper;

  Future<String?> _saveAuthTokenFromResponse(dynamic responseData) async {
    if (responseData is! Map) {
      return null;
    }

    final token = _extractToken(responseData);
    if (token == null || token.isEmpty) {
      return null;
    }
    await _tokenCacheHelper.setToken(token);
    return token;
  }

  UserModel _parseUserModel(Map<String, dynamic> json) {
    final copy = Map<String, dynamic>.from(json);
    copy['id'] = (json['_id'] ?? json['id'] ?? '').toString();
    if (copy['fullName'] == null && (json['firstName'] != null || json['lastName'] != null)) {
      copy['fullName'] = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    }
    if (copy['phone'] == null && json['mobile'] != null) {
      copy['phone'] = '${json['phonePrefix'] ?? ''}${json['mobile']}';
    }
    if (copy['emailVerified'] == null && json['isVerifyEmail'] != null) {
      copy['emailVerified'] = json['isVerifyEmail'];
    }
    return UserModel.fromJson(copy);
  }

  String? _extractToken(Map data) {
    final rawToken = data['token'];
    if (rawToken is String && rawToken.isNotEmpty) {
      return rawToken;
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
    try {
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/user/login',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "email": emailOrPhone,
          "password": password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        final accessToken = data['accessToken'] as String? ?? data['token'] as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          await _tokenCacheHelper.setToken(accessToken);
        }

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
          final user = _parseUserModel(userJson);
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
        '${ApiConstants.apiBaseUrl}/user/register',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
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
        '${ApiConstants.apiBaseUrl}/user/verifyEmailOtp',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "email": email,
          "otp": otp
        },
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
  Future<Either<Failure, Map<String, dynamic>>> uploadImage(String imagePath) async {
    try {
      final fileName = imagePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'fileToUpload': [
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ],
      });
      final response = await _dio.post(
        'https://boker.egytag.com/x-api/upload/image',
        data: formData,
      );
      if (response.statusCode == 200 && response.data != null && response.data['done'] == true) {
        return Right(Map<String, dynamic>.from(response.data['image']));
      }
      return const Left(ServerFailure(message: 'Failed to upload image'));
    } catch (e,st) {
      return ErrorHandler.handle(e,st).left();
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadFile(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'fileToUpload': [
          await MultipartFile.fromFile(filePath, filename: fileName),
        ],
      });
      final response = await _dio.post(
        'https://boker.egytag.com/x-api/upload/file',
        data: formData,
      );
      if (response.statusCode == 200 && response.data != null && response.data['done'] == true) {
        return Right(Map<String, dynamic>.from(response.data['file']));
      }
      return const Left(ServerFailure(message: 'Failed to upload file'));
    } catch (e,st) {
      return ErrorHandler.handle(e,st).left();
    }
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
        '${ApiConstants.apiBaseUrl}/manageUsers/updateUserForm',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "email": email,
          "password": password,
          "identityForm": identityForm,
          if (addressForm != null) "addressForm": addressForm,
        },
      );

      if (response.statusCode == 200 && response.data != null && response.data['done'] == true) {
        return const Right(true);
      }
      return Left(ServerFailure(message: response.statusMessage ?? 'Failed to update user form'));
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
        '${ApiConstants.apiBaseUrl}/store/auth/phone/request-otp',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: {
          "phone": phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message'] as String? ?? 'OTP sent successfully';
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
        '${ApiConstants.apiBaseUrl}/otpMails/add',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
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
        '${ApiConstants.apiBaseUrl}/user/updatePasswordWithOtp',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'email': email,
          'otp': otp,
          'password': password,
        },
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
  Future<Either<Failure, void>> signOut() async {
    try {
      final token = await _tokenCacheHelper.getToken();

      final response = await _dio.delete(
        ApiConstants.signOut,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        await _tokenCacheHelper.clearToken();
      } else {
        await _tokenCacheHelper.clearToken();
        return Failure.server(
          response.statusMessage ?? 'Failed to sign out',
        ).left();
      }
      return const Right(null);
    } on DioException catch (e) {
      await _tokenCacheHelper.clearToken();
      return Failure.server(_handleDioError(e)).left();
    } catch (e) {
      await _tokenCacheHelper.clearToken();
      return Failure.internal(e.toString()).left();
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final token = await _tokenCacheHelper.getToken();
      if (token == null) {
        return Failure.internal('Token not found').left();
      }

      final response = await _dio.delete(
        ApiConstants.account,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _tokenCacheHelper.clearToken();
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
      final currentToken = token ?? await _tokenCacheHelper.getToken();
      if (currentToken == null) {
        return Left(Failure.internal('Token not found'));
      }

      if (_tokenCacheHelper.isTokenExpired(currentToken)) {
        await _tokenCacheHelper.clearToken();
        return Left(Failure.server('Token expired'));
      }
      print("===token ===$currentToken");

      final response = await _dio.get(
        ApiConstants.account,
        queryParameters: {'locale': ApiConstants.defaultLocale},
      );

      if (response.statusCode == 200) {
        final user = _mapUserFromDatabase(
          response.data['customer'] ?? response.data,
        );
        return Right(user);
      } else {
        return Failure.server('Failed to get current user').left();
      }
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

  UserModel _mapUserFromDatabase(Map<String, dynamic> data) {

    final firstName = data['first_name'] as String?;
    final lastName = data['last_name'] as String?;
    final resolvedFullName =
    (data['full_name'] ??
        ((firstName != null || lastName != null)
            ? '${firstName ?? ''} ${lastName ?? ''}'.trim()
            : null))
    as String?;

    return UserModel(
      id: data['id']?.toString() ?? data['actor_id']?.toString() ?? '',
      email: data['email'] as String? ?? '',
      companyName: data['company_name'] as String?,
      phone: data['phone'] as String?,
      fullName: resolvedFullName,
      avatarUrl: data['avatar_url'] as String?,
      metadata: data['metadata'] is Map<String, dynamic>
          ? data['metadata'] as Map<String, dynamic>
          : null,
      hasAccount: data['has_account'] as bool?,
      addresses: data['addresses'] is List
          ? (data['addresses'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
          : null,
      emailVerified: data['email_verified'] as bool? ?? false,
      status: data['status'] != null
          ? UserStatus.fromJson(data['status'] as String)
          : UserStatus.active,
      deletedAt: data['deleted_at'] != null
          ? DateTime.tryParse(data['deleted_at'] as String)
          : null,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'] as String)
          : null,
    );
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
  Future<Either<Failure, String>> verifyOtp({required String phone, required String customerId, required String otp}) {
    // TODO: implement verifyOtp
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> verifyPhoneLoginOtp({required String phone, required String otp}) {
    // TODO: implement verifyPhoneLoginOtp
    throw UnimplementedError();
  }


}
