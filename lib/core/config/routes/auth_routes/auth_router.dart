import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/forget_password_page.dart';
import '../../../../features/auth/presentation/sign_in_page.dart';
import '../../../../features/auth/presentation/sign_up_page.dart';
import '../../../../features/auth/presentation/pages/identity_verification_page.dart';
import '../router_checker.dart';
import '../routes_manager.dart';

class AuthRouter {
  ///Auth Shell Route
  static final authShellRoute = ShellRoute(
    redirect: RouterChecker.ifAlreadyLogin,
    builder: (context, state, child) {
      return  child;
    },
    routes: [
      GoRoute(
        path: "/login",
        redirect: (context, state) {
          final query = state.uri.query;
          final ref = state.uri.queryParameters['ref'];
          final accGroupId = state.uri.queryParameters['accGroupId'];
          if (ref != null || accGroupId != null) {
            return '/${RoutesNames.signUp}?$query';
          }
          return '/${RoutesNames.signIn}?$query';
        },
      ),
      GoRoute(
        path: "/${RoutesNames.signIn}",
        name: RoutesNames.signIn,
        redirect: (context, state) {
          final ref = state.uri.queryParameters['ref'];
          final accGroupId = state.uri.queryParameters['accGroupId'];
          if (ref != null || accGroupId != null) {
            final query = state.uri.query;
            return '/${RoutesNames.signUp}?$query';
          }
          return null;
        },
        pageBuilder: (context, state) {
          final callback =state.uri.queryParameters['callback'];
          final back =bool.tryParse(state.uri.queryParameters['back'].toString());
          return TransitionPage.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: SignInPage(
              back: back,
              callback: callback,
            ),
          );
        },
      ),
      GoRoute(
        path: "/${RoutesNames.signUp}",
        name: RoutesNames.signUp,
        pageBuilder: (context, state) {
          final ref = state.uri.queryParameters['ref'];
          final accGroupId = state.uri.queryParameters['accGroupId'];
          return TransitionPage.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: SignUpPage(refParam: ref, accGroupIdParam: accGroupId),
          );
        },
      ),
      GoRoute(
        path: "/${RoutesNames.forgotPassword}",
        name: RoutesNames.forgotPassword,
        pageBuilder: (context, state) {
          return TransitionPage.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ForgetPasswordPage(),
          );
        },
      ),
      GoRoute(
        path: "/${RoutesNames.identityVerification}",
        name: RoutesNames.identityVerification,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String?;
          final password = extra?['password'] as String?;
          return TransitionPage.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: IdentityVerificationPage(email: email, password: password),
          );
        },
      ),
    ],
  );
}
