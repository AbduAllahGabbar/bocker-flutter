import '../../../core/errors/failure.dart';
import 'data_source/auth_remote_data_source.dart';
import 'models/user_model.dart';
import 'models/register_response.dart';

abstract class AuthRepository {
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

  Future<void> signOut();

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, UserModel>> getCurrentUser();


  Future<Either<Failure, bool>> updatePasswordProfile({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, bool>> updateIsIb();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, EmailLoginResult>> signIn({
    required String emailOrPhone,
    required String password,
  }) async {
    return await _remoteDataSource.signIn(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }

  @override
  Future<Either<Failure, RegisterResponse>> signUp({
    required Map<String, dynamic> data,
  }) async {
    return await _remoteDataSource.signUp(data: data);
  }

  @override
  Future<Either<Failure, String>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    return await _remoteDataSource.verifyEmailOtp(email: email, otp: otp);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadImage(
    String imagePath,
  ) async {
    return await _remoteDataSource.uploadImage(imagePath);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String filePath,
  ) async {
    return await _remoteDataSource.uploadFile(filePath);
  }

  @override
  Future<Either<Failure, bool>> updateUserForm({
    required String email,
    required String password,
    required Map<String, dynamic> identityForm,
    Map<String, dynamic>? addressForm,
  }) async {
    return await _remoteDataSource.updateUserForm(
      email: email,
      password: password,
      identityForm: identityForm,
      addressForm: addressForm,
    );
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String phone,
    required String customerId,
    required String otp,
  }) async {
    return await _remoteDataSource.verifyOtp(
      phone: phone,
      customerId: customerId,
      otp: otp,
    );
  }

  @override
  Future<Either<Failure, String>> resendOtp({
    required String customerId,
  }) async {
    return await _remoteDataSource.resendOtp(customerId: customerId);
  }

  @override
  Future<Either<Failure, String>> requestPhoneLoginOtp({
    required String phone,
  }) async {
    return await _remoteDataSource.requestPhoneLoginOtp(phone: phone);
  }

  @override
  Future<Either<Failure, UserModel>> verifyPhoneLoginOtp({
    required String phone,
    required String otp,
  }) async {
    return await _remoteDataSource.verifyPhoneLoginOtp(phone: phone, otp: otp);
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String identifier,
  }) async {
    return await _remoteDataSource.resetPassword(identifier: identifier);
  }

  @override
  Future<Either<Failure, void>> sendForgotPasswordOtp({
    required String email,
  }) async {
    return await _remoteDataSource.sendForgotPasswordOtp(email: email);
  }

  @override
  Future<Either<Failure, bool>> updatePasswordWithOtp({
    required String email,
    required String otp,
    required String password,
  }) async {
    return await _remoteDataSource.updatePasswordWithOtp(
      email: email,
      otp: otp,
      password: password,
    );
  }

  @override
  Future<void> signOut() async => await _remoteDataSource.signOut();

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    return await _remoteDataSource.deleteAccount();
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }


  @override
  Future<Either<Failure, bool>> updatePasswordProfile({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _remoteDataSource.updatePasswordProfile(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<Either<Failure, bool>> updateIsIb() async {
    return await _remoteDataSource.updateIsIb();
  }
}
