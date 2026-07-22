import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:res_reline/my_responsive.dart';

import 'core/config/language/language_manager.dart';
import 'core/config/local/bloc_observer.dart';
import 'core/config/local/cache_service.dart';
import 'core/config/routes/routes_manager.dart';
import 'core/config/theme/theme.dart';
import 'core/config/theme/util.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/di/di_container.dart';
import 'core/helpers/restart_widget.dart';
import 'features/app/app_cubit.dart';
import 'features/app/app_state.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Future<void> main(args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the WebView platform implementation before use.
  // webview_flutter v4+ requires explicit platform registration.
  if (Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  } else if (Platform.isIOS || Platform.isMacOS) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  }

  Bloc.observer = MyBlocObserver();
  await AppCache.setIsViewedOnboarding(false);

  await Future.wait([
    DI().initAppModule(),
    EasyLocalization.ensureInitialized(),
    AppCache.getOnboardingStatus(),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ])
    // MySettings.getSettings(),
  ]);
  DI.initAuth();
  await di<AuthCubit>().getCurrentUser();

  FlutterNativeSplash.remove();

  runApp(
    EasyLocalization(
      supportedLocales: LanguageType.values.map((e) => e.locale).toList(),
      path: ASSET_PATH_LOCALISATION,
      startLocale: LanguageType.fromValue(di<AppCubit>().state.languageCode).locale,
      fallbackLocale: LanguageType.english.locale,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di<AuthCubit>()),
          BlocProvider(create: (_) => di<AppCubit>()),
        ],
        child: Platform.isAndroid
            ? RestartWidget(
                child: ResInit(
                  designSize: Size(375, 812),
                  child: const MyApp(),
                ),
              )
            : DevicePreview(
                builder: (context) => RestartWidget(
                  child: ResInit(
                    designSize: Size(375, 812),
                    child: const MyApp(),
                  ),
                ),
              ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Nunito", "Nunito");
    MaterialTheme theme = MaterialTheme(textTheme);
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp.router(
          builder: (context, child) => DevicePreview.appBuilder(context, child),
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
    );
  }
}

//best sellers with products
// price list with products
//filter and search
//added
