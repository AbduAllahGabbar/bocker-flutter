import '../../../features/app/app_cubit.dart';
import '../../config/env/app_config.dart';
import '../../di/di_container.dart';

/// API endpoints.
///
/// Hosts are never hardcoded here — they always come from [AppConfig], which
/// resolves the active environment (development / staging / production).
class ApiConstants {
  ApiConstants._();

  static const int defaultPageSize = 10;
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Scheme + host of the active environment.
  static String get baseUrl => AppConfig.baseUrl;

  /// JSON API root of the active environment.
  static String get apiBaseUrl => AppConfig.apiBaseUrl;

  /// Upload root of the active environment.
  static String get uploadBaseUrl => AppConfig.uploadBaseUrl;

  static const String defaultLocale = 'en-US';

  static String get locale => di<AppCubit>().languageLocaleCode;

  // --- Auth -----------------------------------------------------------------
  static const String signOut = '/user/logout';
  static const String account = '/user/account';
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String verifyEmailOtp = '/user/verifyEmailOtp';
  static const String userView = '/user/view';
  static const String updateUserForm = '/manageUsers/updateUserForm';
  static const String otpMailsAdd = '/otpMails/add';
  static const String updatePasswordWithOtp = '/user/updatePasswordWithOtp';
  static const String updatePasswordProfile = '/user/update-password-profile';
  static const String updateIsIb = '/user/update-isIb';
  static const String mt5GroupsPublic = '/site-setting/mt5Groups-public';

  // --- Accounts -------------------------------------------------------------
  static const String accountsAll = '/accounts/all';
  static const String accountsAdd = '/accounts/add';
  static const String accountTypeList = '/accountTypeList';
  static const String leverageList = '/leverageList';
  static const String openingBalanceList = '/openingBalanceList';

  // --- Transactions ---------------------------------------------------------
  static const String transactionsAll = '/accountsTransactions/all';
  static const String transactionsAdd = '/accountsTransactions/add';
  static const String myfatoorahQuote =
      '/accountsTransactions/myfatoorah-quote';

  // --- Payment methods ------------------------------------------------------
  static const String paymentMethodList = '/paymentMethodList';
  static const String paymentMethodListAdmin = '/paymentMethodList/admin';
  static const String paymentMethodListUser = '/paymentMethodList/user';
  static const String userPaymentMethods = '/user/getPaymentMethods';
  static const String addPaymentMethod = '/user/addPaymentMethod';
  static const String deletePaymentMethod = '/user/deletePaymentMethod';
  static const String currenciesAll = '/currencies/all';

  // --- Notifications --------------------------------------------------------
  static const String notificationsList = '/notifications/list';
  static const String notificationsSummary = '/notifications/summary';
  static const String notificationsMarkSeen = '/notifications/mark-seen';
  static const String notificationsDelete = '/notifications/delete';
  static const String notificationsDeviceRegister =
      '/notifications/device/register';
  static const String notificationsDeviceUnregister =
      '/notifications/device/unregister';

  /// Server-sent events stream (notification / counts / message-new).
  static const String activityStream = '/activity/stream';

  // --- Messages (private user <-> support messaging) ------------------------
  static const String messagesViewUser = '/messages/view-user';
  static const String messagesAddUser = '/messages/add-user';

  // --- Help desk tickets ----------------------------------------------------
  static const String ticketsAll = '/tickets/all';
  static const String ticketsView = '/tickets/view';
  static const String ticketsAdd = '/tickets/add';
  static const String ticketsCloseUser = '/tickets/close-user';
  static const String ticketsReplyUser = '/tickets/reply-user';
  static const String ticketCategoriesAll = '/ticketCategories/all';

  // --- Uploads (absolute, they live outside /api) ---------------------------
  static String get uploadImage => '${AppConfig.uploadBaseUrl}/image';
  static String get uploadFile => '${AppConfig.uploadBaseUrl}/file';
}
