import 'package:get_it/get_it.dart';
import 'package:boker/core/config/local/cache_service.dart';
import '../../features/app/app_cubit.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/profile/data/data_source/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/accounts/data/data_source/accounts_remote_data_source.dart';
import '../../features/accounts/data/repositories/accounts_repository.dart';
import '../../features/accounts/presentation/cubit/accounts_cubit.dart';
import '../../features/accounts/presentation/cubit/create_account_cubit.dart';
import '../config/local/token_cache_service.dart';
import '../network/dio/dio_factory.dart';
import 'package:dio/dio.dart';
import '../../features/transactions/data/data_source/transactions_remote_data_source.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import '../../features/transactions/presentation/cubit/transactions_cubit.dart';
import '../../features/transactions/presentation/cubit/add_transaction_cubit.dart';
import '../../features/payment_methods/data/data_sources/payment_methods_remote_data_source.dart';
import '../../features/payment_methods/data/repositories/payment_methods_repository.dart';
import '../../features/payment_methods/presentation/cubit/payment_methods_cubit.dart';
import '../../features/payment_methods/presentation/cubit/add_payment_method_cubit.dart';

final di = GetIt.instance;

class DI {
  Future<void> initAppModule() async {
    if (!di.isRegistered<Dio>()) {
      final dio = await DioFactory().getDioWithToken();
      di.registerLazySingleton<Dio>(() => dio);
    }
    if (!di.isRegistered<AppCubit>()) {
      final currentLang = await AppCache.getLanguage();
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

  static ProfileRepository initProfileRepository() {
    if (!di.isRegistered<ProfileRemoteDataSource>()) {
      di.registerFactory<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(dio: DioFactory().getDio()),
      );
    }
    if (!di.isRegistered<ProfileRepository>()) {
      di.registerFactory<ProfileRepository>(
        () => ProfileRepositoryImpl(remoteDataSource: di<ProfileRemoteDataSource>()),
      );
    }
    return di<ProfileRepository>();
  }

  static ProfileCubit initProfile() {
    if (!di.isRegistered<ProfileCubit>()) {
      di.registerSingleton<ProfileCubit>(
        ProfileCubit(profileRepository: initProfileRepository()),
      );
    }
    return di<ProfileCubit>();
  }

  static AccountsRepository initAccountsRepository() {
    if (!di.isRegistered<AccountsRemoteDataSource>()) {
      di.registerFactory<AccountsRemoteDataSource>(
        () => AccountsRemoteDataSourceImpl(dio: di<Dio>()),
      );
    }
    if (!di.isRegistered<AccountsRepository>()) {
      di.registerFactory<AccountsRepository>(
        () => AccountsRepositoryImpl(remoteDataSource: di<AccountsRemoteDataSource>()),
      );
    }
    return di<AccountsRepository>();
  }

  static AccountsCubit initAccounts() {
    if (!di.isRegistered<AccountsCubit>()) {
      di.registerFactory<AccountsCubit>(
       () =>  AccountsCubit(accountsRepository: initAccountsRepository()),
      );
    }
    return di<AccountsCubit>();
  }
  static CreateAccountCubit initCreateAccount() {
    if (!di.isRegistered<CreateAccountCubit>()) {
      di.registerFactory<CreateAccountCubit>(
            () => CreateAccountCubit(repository: initAccountsRepository()),
      );
    }
    return di<CreateAccountCubit>();
  }

  static TransactionsRepository initTransactionsRepository() {
    if (!di.isRegistered<TransactionsRemoteDataSource>()) {
      di.registerFactory<TransactionsRemoteDataSource>(
        () => TransactionsRemoteDataSourceImpl(dio: di<Dio>()),
      );
    }
    if (!di.isRegistered<TransactionsRepository>()) {
      di.registerFactory<TransactionsRepository>(
        () => TransactionsRepositoryImpl(remoteDataSource: di<TransactionsRemoteDataSource>()),
      );
    }
    return di<TransactionsRepository>();
  }

  static TransactionsCubit initTransactions() {
    if (!di.isRegistered<TransactionsCubit>()) {
      di.registerFactory<TransactionsCubit>(
       () =>  TransactionsCubit(repository: initTransactionsRepository()),
      );
    }
    return di<TransactionsCubit>();
  }

  static AddTransactionCubit initAddTransaction() {
    if (!di.isRegistered<AddTransactionCubit>()) {
      di.registerFactory<AddTransactionCubit>(
       () =>  AddTransactionCubit(repository: initTransactionsRepository()),
      );
    }
    return di<AddTransactionCubit>();
  }

  static PaymentMethodsRepository initPaymentMethodsRepository() {
    if (!di.isRegistered<PaymentMethodsRemoteDataSource>()) {
      di.registerFactory<PaymentMethodsRemoteDataSource>(
        () => PaymentMethodsRemoteDataSourceImpl(dio: di<Dio>()),
      );
    }
    if (!di.isRegistered<PaymentMethodsRepository>()) {
      di.registerFactory<PaymentMethodsRepository>(
        () => PaymentMethodsRepositoryImpl(remoteDataSource: di<PaymentMethodsRemoteDataSource>()),
      );
    }
    return di<PaymentMethodsRepository>();
  }

  static PaymentMethodsCubit initPaymentMethods() {
    if (!di.isRegistered<PaymentMethodsCubit>()) {
      di.registerFactory<PaymentMethodsCubit>(
       () => PaymentMethodsCubit(repository: initPaymentMethodsRepository()),
      );
    }
    return di<PaymentMethodsCubit>();
  }

  static AddPaymentMethodCubit initAddPaymentMethod() {
    if (!di.isRegistered<AddPaymentMethodCubit>()) {
      di.registerFactory<AddPaymentMethodCubit>(
       () => AddPaymentMethodCubit(repository: initPaymentMethodsRepository()),
      );
    }
    return di<AddPaymentMethodCubit>();
  }
}
