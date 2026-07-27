import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:res_reline/my_responsive.dart';
import 'package:boker/features/auth/cubit/auth_cubit.dart';
import 'package:boker/features/auth/cubit/auth_state.dart';
import 'package:boker/features/auth/data/repository/user_access.dart';
import '../../../../core/componants/toast.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/di/di_container.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountCubit(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.s),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.all(24.s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.s),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: colorScheme.error,
                    size: 32.s,
                  ),
                ),
                SizedBox(height: 20.s),
                Text(
                  'Logout'.tran,
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.s,
                        color: colorScheme.onSurface,
                      ),
                ),
                SizedBox(height: 12.s),
                Text(
                  'Are you sure you want to logout from your account?'.tran,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14.s,
                      ),
                ),
                SizedBox(height: 24.s),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.s),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(90.s),
                          ),
                          side: BorderSide(color: colorScheme.outlineVariant),
                          foregroundColor: colorScheme.onSurface,
                        ),
                        child: Text(
                          'Cancel'.tran,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.s,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.s),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          di<AuthCubit>().signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.s),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(90.s),
                          ),
                        ),
                        child: Text(
                          'Logout'.tran,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.s,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current.mapOrNull(authenticated: (value) => true) == true,
          listener: (context, state) {
            context.read<AccountCubit>().syncUser();
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) => ToastState.error.snackBar(context, message),
              unauthenticated: () => Router.neglect(
                context,
                () => context.goNamed(RoutesNames.login),
              ),
              orElse: () {},
            );
          },
        ),
      ],
      child: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: RefreshIndicator(
                onRefresh: () => context.read<AuthCubit>().getCurrentUser(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 8.s),
                  children: [
                      _buildProfileHeader(state, context),
                      SizedBox(height: 24.s),

                      _buildSectionTitle('ACCOUNT MANAGEMENT', context),
                      SizedBox(height: 12.s),
                      _ProfileMenuTile(
                        title: 'Verification Status'.tran,
                        subtitle: 'Identity & Address Verified'.tran,
                        icon: Icons.verified_user_outlined,
                        onTap: () => context.pushNamed(RoutesNames.verificationStatus),
                      ),
                      _ProfileMenuTile(
                        title: 'My Agreements'.tran,
                        subtitle: '4 Active contracts signed'.tran,
                        icon: Icons.description_outlined,
                        onTap: () => context.pushNamed(RoutesNames.agreements),
                      ),
                      _ProfileMenuTile(
                        title: 'Support Messages'.tran,
                        subtitle: 'No unread messages'.tran,
                        icon: Icons.chat_bubble_outline,
                        onTap: () => context.pushNamed(RoutesNames.supportChat),
                      ),
                      _ProfileMenuTile(
                        title: 'Help Center'.tran,
                        subtitle: 'View and manage support tickets'.tran,
                        icon: Icons.help_outline,
                        onTap: () => context.pushNamed(RoutesNames.helpCenter),
                      ),
                      SizedBox(height: 24.s),

                      _buildSectionTitle('SECURITY & PREFERENCES', context),
                      SizedBox(height: 12.s),
                      _ProfileMenuTile(
                        title: 'Account Security'.tran,
                        subtitle: '2FA Enabled, Last changed 12d ago'.tran,
                        icon: Icons.security,
                        onTap: () {},
                      ),
                      _ProfileMenuTile(
                        title: 'App Settings'.tran,
                        subtitle: 'English, Push Notifications'.tran,
                        icon: Icons.settings_outlined,
                        onTap: () => context.pushNamed(RoutesNames.settings),
                      ),

                      SizedBox(height: 24.s),

                      _buildLogoutButton(context, state),
                      SizedBox(height: 24.s),

                      Center(
                        child: Text(
                          'Version 2.4.1 (Stable Build)',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.s,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.paddingOf(context).bottom + 16.s),
                    ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AccountState state, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final user = UserAccess.user;
    final displayName = user?.displayFullName ?? 'Guest User'.tran;
    final avatarUrl = user?.avatarUrl ?? user?.image;
    final userId = user?.userId ?? 'N/A';
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: EdgeInsets.all(4.s),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor, width: 2.s),
              ),
              child: CircleAvatar(
                radius: 40.s,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Icon(Icons.person, size: 40.s, color: colorScheme.onSurfaceVariant)
                    : null,
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.s),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2.s),
              ),
              child: Icon(Icons.verified, color: colorScheme.onPrimary, size: 14.s),
            ),
          ],
        ),
        SizedBox(height: 16.s),
        Text(
          displayName,
          style: TextStyle(
            fontSize: 24.s,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Account ID: $userId'.tran,
              style: TextStyle(
                fontSize: 13.s,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 4.s),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: userId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account ID copied'.tran)),
                );
              },
              child: Icon(Icons.copy, size: 14.s, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        SizedBox(height: 12.s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.s, vertical: 6.s),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20.s),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.workspace_premium_outlined, size: 14.s, color: theme.primaryColor),
              SizedBox(width: 4.s),
              Text(
                'PREMIUM ACCOUNT'.tran,
                style: TextStyle(
                  fontSize: 11.s,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildSectionTitle(String title, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 4.s),
      child: Text(
        title.tran,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12.s,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AccountState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: state.isGuest
          ? () => context.goNamed(RoutesNames.signIn)
          : () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(16.s),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.s),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16.s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isGuest ? Icons.login_rounded : Icons.logout_rounded,
              color: colorScheme.error,
              size: 20.s,
            ),
            SizedBox(width: 8.s),
            Text(
              state.isGuest ? 'Login'.tran : 'Logout'.tran,
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 16.s,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 12.s),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.s),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 16.s),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.s),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 22.s,
                ),
              ),
              SizedBox(width: 16.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize: 16.s,
                      ),
                    ),
                    SizedBox(height: 2.s),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13.s,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: 24.s,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
