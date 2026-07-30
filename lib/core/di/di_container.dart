import 'package:get_it/get_it.dart';
import 'package:boker/core/config/local/cache_service.dart';
import '../../features/app/app_cubit.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../config/local/token_cache_service.dart';
import '../network/dio/dio_factory.dart';
import 'package:dio/dio.dart';

final di = GetIt.instance;

class DI {
  Future<void> initAppModule() async {
    if (!di.isRegistered<Dio>()) {
      final dio = await DioFactory().getDioWithToken();
      di.registerLazySingleton<Dio>(() => dio);
    }

    if (!di.isRegistered<AppCubit>()) {
      final currentLang = await AppCache.getLanguage();
      print("======currentLang============${currentLang}==========");
      di.registerLazySingleton<AppCubit>(
        () => AppCubit(languageCode: currentLang, isDarkMode: false),
      );
    }
  }

  static AuthRepository initAuthRepository() {
    if (!di.isRegistered<AuthRemoteDataSource>()) {
      di.registerFactory<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dio: DioFactory().getDio()),
      );
    }
    if (!di.isRegistered<AuthRepository>()) {
      di.registerFactory<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: di<AuthRemoteDataSource>()),
      );
    }
    return di<AuthRepository>();
  }

  static void initAuth() {
    if (!di.isRegistered<AuthCubit>()) {
      di.registerSingleton<AuthCubit>(
        AuthCubit(authRepository: initAuthRepository()),
      );
    }
  }
}
