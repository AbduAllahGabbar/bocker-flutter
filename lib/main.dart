import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';

import 'core/config/language/language_manager.dart';
import 'core/config/local/bloc_observer.dart';
import 'core/config/local/cache_service.dart';
import 'core/config/routes/routes_manager.dart';
import 'core/config/theme/theme.dart';
import 'core/config/theme/util.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/di/di_container.dart';
import 'core/helpers/restart_widget.dart';
import 'core/network/dio/session_manager.dart';
import 'core/services/referral/referral_service.dart';
import 'core/services/notifications/notifications_bootstrap.dart';
import 'features/app/app_cubit.dart';
import 'features/app/app_state.dart';
import 'features/auth/cubit/auth_cubit.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();

  await Future.wait([
    EasyLocalization.ensureInitialized(),
    AppCache.getOnboardingStatus(),
    // The UI is laid out against a 375x812 portrait design; the app is
    // portrait-only on both platforms (iOS Info.plist matches this).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    // Load the persisted session before the first authenticated request.
    SessionManager.instance.restore(),
    // Load any affiliate referral captured on an earlier run, so it survives
    // closing and force-stopping the app.
    ReferralService.instance.restore(),
  ]);

  DI.initAuth();
  await di<AuthCubit>().getCurrentUser();
  await DI().initAppModule();

  // A 401 on any request tears the session down once and routes back to login.
  SessionManager.instance.onUnauthorized = () async {
    await NotificationsBootstrap.instance.onSignedOut();
    await di<AuthCubit>().forceSignOut();
    RouterManger.router.goNamed(RoutesNames.signIn);
  };

  // Registers the FCM device token and starts the live counters stream when a
  // session is present. Safe to call when Firebase is not configured.
  await NotificationsBootstrap.instance.onAppStart();

  FlutterNativeSplash.remove();

  runApp(
    EasyLocalization(
      supportedLocales: LanguageType.values.map((e) => e.locale).toList(),
      path: ASSET_PATH_LOCALISATION,
      startLocale: LanguageType.fromValue(
        di<AppCubit>().state.languageCode,
      ).locale,
      fallbackLocale: LanguageType.english.locale,
      child: RestartWidget(
        child: ResInit(designSize: const Size(375, 812), child: const MyApp()),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Nunito", "Nunito");
    MaterialTheme theme = MaterialTheme(textTheme);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di<AuthCubit>()),
        BlocProvider(create: (_) => di<AppCubit>()),
        // The default account is shared by every screen, so it is provided
        // above the router and never torn down with a route.
        BlocProvider(create: (_) => DI.initDefaultAccount()),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp.router(
            // DevicePreview is a debugging aid only - it must never wrap a
            // release build, where it would render the app inside a device
            // frame for real users.
            builder: kDebugMode ? DevicePreview.appBuilder : null,
            debugShowCheckedModeBanner: false,
            routerConfig: RouterManger.router,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: theme.light(),
            darkTheme: theme.dark(),
            localeResolutionCallback: (locale, supportedLocales) =>
                context.locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        },
      ),
    );
  }
}
