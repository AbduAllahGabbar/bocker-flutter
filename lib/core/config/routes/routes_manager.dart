import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:boker/core/config/routes/router_checker.dart';
import '../../../features/auth/data/repository/user_access.dart';
import '../../../features/layout/presentation/pages/layout_view.dart';
import '../../../features/onboarding/presentation/onboarding_screen.dart';
import '../../di/di_container.dart';
import 'auth_routes/auth_router.dart';
import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/transactions/presentation/cubit/transactions_cubit.dart';
import '../../../features/transactions/presentation/cubit/add_transaction_cubit.dart';
import '../../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/profile/presentation/pages/settings_page.dart';
import '../../../features/profile/presentation/pages/language_page.dart';
import '../../../features/profile/presentation/pages/about_app_page.dart';
import '../../../features/profile/presentation/pages/verification_status_page.dart';
import '../../../features/profile/presentation/pages/agreements_page.dart';
import '../../../features/profile/presentation/pages/chat_page.dart';
import '../../../features/profile/presentation/pages/help_center_page.dart';
import '../../../features/profile/presentation/pages/create_ticket_page.dart';
import '../../../features/profile/presentation/pages/ticket_details_page.dart';
import '../../../features/profile/presentation/cubit/edit_form/edit_form_cubit.dart';
import '../../../features/profile/data/repositories/verification_repository.dart';
import '../../../features/payment_methods/presentation/pages/payment_methods_page.dart';
import '../../../features/payment_methods/presentation/pages/select_payment_method_page.dart';
import '../../../features/payment_methods/presentation/pages/add_crypto_payment_page.dart';
import '../../../features/payment_methods/presentation/pages/add_card_payment_page.dart';
import '../../../features/payment_methods/presentation/pages/add_bank_payment_page.dart';
import '../../../features/payment_methods/presentation/pages/add_payment_success_page.dart';
import '../../../features/transactions/data/models/payment_method_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/profile/presentation/pages/edit_identity_page.dart';
import '../../../features/profile/presentation/pages/edit_address_page.dart';
import '../../../features/profile/presentation/pages/change_password_page.dart';
import '../../../features/profile/presentation/cubit/account_cubit.dart';
import '../../../features/accounts/presentation/pages/accounts_page.dart';
import '../../../features/accounts/presentation/pages/create_account_page.dart';

class RoutesNames {
  const RoutesNames._();

  static const String signIn = "sign-in";
  static const String login = "sign-in"; // Alias for compatibility
  static const String signUp = "sign-up";
  static const String forgotPassword = "forgot-password";
  static const String loginCallback = "login-callback";
  static const String identityVerification = "identity-verification";
  static const String verificationStatus = "verification-status";
  static const String editIdentity = "edit-identity";
  static const String editAddress = "edit-address";
  static const String agreements = "agreements";
  static const String supportChat = "support-chat";
  static const String helpCenter = "help-center";
  static const String createTicket = "create-ticket";
  static const String ticketDetails = "ticket-details";
  static const String changePassword = "change-password";
  static const String paymentDetails = "payment-details";
  static const String selectPaymentMethod = "select-payment-method";
  static const String addCryptoPayment = "add-crypto-payment";
  static const String addCardPayment = "add-card-payment";
  static const String addBankPayment = "add-bank-payment";
  static const String addPaymentSuccess = "add-payment-success";

  static const String home = "home";
  static const String checkout = "checkout";
  static const String payment = "payment";
  static const String onBoarding = "on-boarding";
  static const String profile = "profile";
  static const String accounts = "accounts";
  static const String createAccount = "create-account";
  static const String addTransaction = "add-transaction";
  static const String settings = 'settings';
  static const String accountAbout = 'account-about';
  static const String language = 'language';

  // static String get initialRoute => UserAccess.isAuthenticated
  //     ? '/$home'
  //     : AppCache.isViewedOnboarding
  //     ? '/$signIn'
  //     : '/$onBoarding';
  static String get initialRoute =>
      UserAccess.isAuthenticated ? '/$home' : '/$signIn';

  static String get checkTransaction => 'check-transaction';
}

/// TransitionPage alias for compatibility
class TransitionPage {
  TransitionPage._();

  static CustomTransitionPage buildPageWithDefaultTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return RouterManger.buildPageWithDefaultTransition<T>(
      context: context,
      state: state,
      child: child,
    );
  }
}

/// CustomTransitionPage for go_router
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )
  transitionsBuilder;

  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

class RouterManger {
  RouterManger._();

  static String currentRouteLocation(BuildContext context) {
    String path = GoRouterState.of(context).uri.toString();
    return path;
  }

  static CustomTransitionPage buildPageWithDefaultTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: RoutesNames.initialRoute,
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      return state.uri.toString() == "/"
          ? RouterChecker.initialChecker(context, state)
          : null;
    },
    routes: [
      AuthRouter.authShellRoute,
      GoRoute(
        path: "/${RoutesNames.onBoarding}",
        name: RoutesNames.onBoarding,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const OnboardingScreen(),
          );
        },
      ),
      _layoutRoute,
      GoRoute(
        path: "/${RoutesNames.addTransaction}",
        name: RoutesNames.addTransaction,
        pageBuilder: (context, state) {
          final type = state.extra as String? ?? 'deposit';
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => DI.initAddTransaction(),
              child: AddTransactionPage(initialType: type),
            ),
          );
        },
      ),
      //  _walletRouter,
    ],
  );
  static final _layoutRoute = StatefulShellRoute.indexedStack(
    builder:
        (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return LayoutView(navigationShell: navigationShell);
        },
    branches: [
      StatefulShellBranch(routes: [_homeRoute]),
      StatefulShellBranch(routes: [_accountsRoute]),
      StatefulShellBranch(routes: [_profileRoute]),
    ],
  );

  static final _homeRoute = GoRoute(
    path: "/${RoutesNames.home}",
    name: RoutesNames.home,
    pageBuilder: (context, state) {
      return RouterManger.buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => DI.initTransactions()..fetchTransactions(),
          child: const HomePage(),
        ),
      );
    },
  );

  static final _accountsRoute = GoRoute(
    path: "/${RoutesNames.accounts}",
    name: RoutesNames.accounts,
    pageBuilder: (context, state) {
      return RouterManger.buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => DI.initAccounts(),
          child: const AccountsPage(),
        ),
      );
    },
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.createAccount,
        name: RoutesNames.createAccount,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const CreateAccountPage(),
          );
        },
      ),
    ],
  );

  static final _profileRoute = GoRoute(
    path: "/${RoutesNames.profile}",
    name: RoutesNames.profile,
    pageBuilder: (context, state) {
      return RouterManger.buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const ProfilePage(),
      );
    },
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.paymentDetails,
        name: RoutesNames.paymentDetails,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const PaymentMethodsPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.selectPaymentMethod,
        name: RoutesNames.selectPaymentMethod,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const SelectPaymentMethodPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.addCryptoPayment,
        name: RoutesNames.addCryptoPayment,
        pageBuilder: (context, state) {
          final method = state.extra as PaymentMethodModel;
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: AddCryptoPaymentPage(method: method),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.addCardPayment,
        name: RoutesNames.addCardPayment,
        pageBuilder: (context, state) {
          final method = state.extra as PaymentMethodModel;
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: AddCardPaymentPage(method: method),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.addBankPayment,
        name: RoutesNames.addBankPayment,
        pageBuilder: (context, state) {
          final method = state.extra as PaymentMethodModel;
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: AddBankPaymentPage(method: method),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.addPaymentSuccess,
        name: RoutesNames.addPaymentSuccess,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const AddPaymentSuccessPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.settings,
        name: RoutesNames.settings,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const SettingsPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.language,
        name: RoutesNames.language,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const LanguagePage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.changePassword,
        name: RoutesNames.changePassword,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => AccountCubit(),
              child: const ChangePasswordPage(),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.accountAbout,
        name: RoutesNames.accountAbout,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const AboutAppPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.verificationStatus,
        name: RoutesNames.verificationStatus,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const VerificationStatusPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.editIdentity,
        name: RoutesNames.editIdentity,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) =>
                  EditFormCubit(VerificationRepository(di<Dio>())),
              child: EditIdentityPage(initialForm: extra),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.editAddress,
        name: RoutesNames.editAddress,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) =>
                  EditFormCubit(VerificationRepository(di<Dio>())),
              child: EditAddressPage(initialForm: extra),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.agreements,
        name: RoutesNames.agreements,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const AgreementsPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.supportChat,
        name: RoutesNames.supportChat,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ChatPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.helpCenter,
        name: RoutesNames.helpCenter,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const HelpCenterPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.createTicket,
        name: RoutesNames.createTicket,
        pageBuilder: (context, state) {
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const CreateTicketPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutesNames.ticketDetails,
        name: RoutesNames.ticketDetails,
        pageBuilder: (context, state) {
          final ticket = state.extra as Map<String, dynamic>;
          return RouterManger.buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: TicketDetailsPage(ticket: ticket),
          );
        },
      ),
    ],
  );

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
}
