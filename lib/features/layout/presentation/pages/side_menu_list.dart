import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:boker/core/config/routes/routes_manager.dart';
import 'package:boker/core/di/di_container.dart';
import 'package:boker/features/auth/cubit/auth_cubit.dart';
import 'package:boker/features/auth/cubit/auth_state.dart';
import '../../../../core/config/local/cache_service.dart';

class SideMenuList extends StatelessWidget {
  const SideMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthCubit, AuthState>(
        bloc: di<AuthCubit>(),
        builder: (context, state) {
          final user = state.mapOrNull(authenticated: (value) => value.user,);
          final displayName = user == null
              ? null
              : (user.fullName?.trim().isNotEmpty ?? false)
              ? user.fullName!.trim()
              : (user.fullName ?? '')
                    .trim()
                    .isNotEmpty
              ? (user.fullName ?? '').trim()
              : null;

          return Column(
            children: [
              // User Profile Header
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
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                accountName: Text(
                  displayName ?? 'Guest User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? 'No email',
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

              // Navigation Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.home,
                      title: 'Home',
                      onTap: () {
                        Navigator.pop(context);
                       // context.goNamed(RoutesNames.products);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        // Add navigation to profile page when created
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile page coming soon'),
                          ),
                        );
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.bookmark,
                      title: 'My Bookings',
                      onTap: () {
                        Navigator.pop(context);
                        // Add navigation to bookings page when created
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bookings page coming soon'),
                          ),
                        );
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.favorite,
                      title: 'Favorites',
                      onTap: () {
                        Navigator.pop(context);
                        // Add navigation to favorites page when created
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Favorites page coming soon'),
                          ),
                        );
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Wallet',
                      onTap: () {
                        Navigator.pop(context);
                        // Add navigation to wallet page when created
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wallet page coming soon'),
                          ),
                        );
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        context.goNamed(RoutesNames.settings);
                      },
                    ),
                    const Divider(),
                    _DrawerMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        // Add navigation to help page when created
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help page coming soon'),
                          ),
                        );
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // Logout Button at the bottom
              const Divider(height: 1),
              SafeArea(
                child: _DrawerMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AppCache.clearData();
              di<AuthCubit>().signOut();
              Router.neglect(
                context,
                () => context.goNamed(RoutesNames.signIn),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'shopy',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.home, size: 48),
      children: [const Text('Property management and booking application')],
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
