import 'package:boker/core/config/language/language_manager.dart';
import 'package:boker/core/config/routes/routes_manager.dart';
import 'package:boker/core/di/di_container.dart';
import 'package:boker/features/auth/cubit/auth_cubit.dart';
import 'package:boker/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/config/env/app_config.dart';
import '../../../../core/config/local/cache_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/presentation/cubit/notification_counters_cubit.dart';

/// Navigation drawer for the Boker client portal.
///
/// Every entry leads to a screen that exists in this app — the template items
/// (Bookings, Favorites, Wallet, Help & Support) that only showed "coming
/// soon" snackbars have been removed.
class SideMenuList extends StatelessWidget {
  const SideMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthCubit, AuthState>(
        bloc: di<AuthCubit>(),
        builder: (context, state) {
          final user = state.mapOrNull(authenticated: (value) => value.user);
          final displayName = user?.displayFullName;
          final avatarUrl = user?.avatarUrl ?? user?.image;
          final isIb = user?.isIb == true;

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(AppConfig.resolveUrl(avatarUrl)!)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                accountName: Text(
                  (displayName == null || displayName.isEmpty)
                      ? 'Guest User'.tran
                      : displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (user?.phone != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          user!.phone!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.home_rounded,
                      title: 'Home'.tran,
                      onTap: () => _go(context, RoutesNames.home),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Accounts'.tran,
                      onTap: () => _go(context, RoutesNames.accounts),
                    ),
                    _NotificationsMenuItem(
                      onTap: () => _push(context, RoutesNames.notifications),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.analytics_outlined,
                      title: 'MT5 Data'.tran,
                      onTap: () => _push(context, RoutesNames.mt5Data),
                    ),
                    if (isIb)
                      _DrawerMenuItem(
                        icon: Icons.groups_outlined,
                        title: 'IB Dashboard'.tran,
                        onTap: () => _go(context, RoutesNames.ibDashboard),
                      ),

                    const Divider(),

                    _DrawerMenuItem(
                      icon: Icons.person_rounded,
                      title: 'My Account'.tran,
                      onTap: () => _go(context, RoutesNames.profile),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.payment_outlined,
                      title: 'Payment Details'.tran,
                      onTap: () => _push(context, RoutesNames.paymentDetails),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Verification Status'.tran,
                      onTap: () =>
                          _push(context, RoutesNames.verificationStatus),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.description_outlined,
                      title: 'My Agreements'.tran,
                      onTap: () => _push(context, RoutesNames.agreements),
                    ),

                    const Divider(),

                    _MessagesMenuItem(
                      onTap: () => _push(context, RoutesNames.supportChat),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help Center'.tran,
                      onTap: () => _push(context, RoutesNames.helpCenter),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.settings,
                      title: 'App Settings'.tran,
                      onTap: () => _push(context, RoutesNames.settings),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.info_outline,
                      title: 'About'.tran,
                      onTap: () => _push(context, RoutesNames.accountAbout),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),
              SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.logout,
                      title: 'Logout'.tran,
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                    ),
                    const _AppVersionFooter(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Switches to one of the bottom-navigation branches.
  void _go(BuildContext context, String routeName) {
    Navigator.pop(context);
    context.goNamed(routeName);
  }

  /// Opens a screen on top of the current branch.
  void _push(BuildContext context, String routeName) {
    Navigator.pop(context);
    context.pushNamed(routeName);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Logout'.tran),
        content: Text('Are you sure you want to logout?'.tran),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'.tran),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AppCache.clearData();
              await di<AuthCubit>().signOut();
              if (!context.mounted) return;
              Router.neglect(
                context,
                () => context.goNamed(RoutesNames.signIn),
              );
            },
            child: Text(
              'Logout'.tran,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notifications entry with the live unread badge.
class _NotificationsMenuItem extends StatelessWidget {
  const _NotificationsMenuItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCountersCubit, NotificationSummary>(
      bloc: DI.initNotificationCounters(),
      builder: (context, summary) => _DrawerMenuItem(
        icon: Icons.notifications_none,
        title: 'Notifications'.tran,
        badgeCount: summary.unreadNotifications,
        onTap: onTap,
      ),
    );
  }
}

/// Support messages entry with the live unread badge.
class _MessagesMenuItem extends StatelessWidget {
  const _MessagesMenuItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCountersCubit, NotificationSummary>(
      bloc: DI.initNotificationCounters(),
      builder: (context, summary) => _DrawerMenuItem(
        icon: Icons.chat_bubble_outline,
        title: 'Support Messages'.tran,
        badgeCount: summary.unreadMessages,
        onTap: onTap,
      ),
    );
  }
}

class _AppVersionFooter extends StatelessWidget {
  const _AppVersionFooter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${'Version'.tran} ${info.version} (${info.buildNumber})',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        );
      },
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final int badgeCount;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: TextStyle(
                  color: colorScheme.onError,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
