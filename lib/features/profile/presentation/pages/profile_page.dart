import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:res_reline/my_responsive.dart';
import 'package:boker/features/auth/cubit/auth_cubit.dart';
import 'package:boker/features/auth/cubit/auth_state.dart';
import 'package:boker/features/auth/data/repository/user_access.dart';
import 'package:boker/features/auth/data/auth_repository.dart';
import '../../../../core/componants/toast.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/di/di_container.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_state.dart';
import '../cubit/profile_cubit.dart';

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

class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  bool _isLoadingIb = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = UserAccess.user;
      if (user != null) {
        context.read<ProfileCubit>().fetchUserView(user.userId);
      }
    });
  }

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
                        title: 'Payment Details'.tran,
                        subtitle: 'Manage saved payment methods'.tran,
                        icon: Icons.payment_outlined,
                        onTap: () => context.pushNamed(RoutesNames.paymentDetails),
                      ),
                      _ProfileMenuTile(
                        title: 'Verification Status'.tran,
                        subtitle: (state.user?.isFormCompleted == true && state.user?.isVerifyEmail == true)
                            ? 'Identity & Address Verified'.tran
                            : 'Pending Verification'.tran,
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
                      _ProfileMenuTile(
                        title: 'Change Password'.tran,
                        subtitle: 'Update your account password'.tran,
                        icon: Icons.lock_outline,
                        onTap: () => context.pushNamed(RoutesNames.changePassword),
                      ),

                      SizedBox(height: 24.s),
                    _buildSectionTitle('PERSONAL DETAILS', context),
                    SizedBox(height: 12.s),
                    _ProfileInfoTile(title: 'Email', value: state.user?.email ?? 'N/A'),
                    _ProfileInfoTile(title: 'Phone', value: state.user?.displayPhone ?? 'N/A'),
                    if (state.user?.idNumber != null)
                      _ProfileInfoTile(title: 'ID Number', value: state.user!.idNumber!),
                    if (state.user?.clientType != null)
                      _ProfileInfoTile(title: 'Client Type', value: state.user!.clientType!),
                    if (state.user?.birthDate != null)
                      _ProfileInfoTile(title: 'Birth Date', value: state.user!.birthDate!),
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
        SizedBox(height: 8.s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 16.s, color: theme.primaryColor),
            SizedBox(width: 4.s),
            Text(
              'Balance: \$${state.user?.balance ?? '0.00'}',
              style: TextStyle(
                fontSize: 16.s,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        // SizedBox(height: 12.s),
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 12.s, vertical: 6.s),
        //   decoration: BoxDecoration(
        //     color: colorScheme.primaryContainer,
        //     borderRadius: BorderRadius.circular(20.s),
        //   ),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.workspace_premium_outlined, size: 14.s, color: theme.primaryColor),
        //       SizedBox(width: 4.s),
        //       Text(
        //         'PREMIUM ACCOUNT'.tran,
        //         style: TextStyle(
        //           fontSize: 11.s,
        //           fontWeight: FontWeight.bold,
        //           color: theme.primaryColor,
        //           letterSpacing: 0.5,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        SizedBox(height: 16.s),
        _buildBecomeIbButton(context, state.user?.isIb ?? false),
      ],
    );
  }

  Widget _buildBecomeIbButton(BuildContext context, bool isIb) {
    return ElevatedButton(
      onPressed: isIb || _isLoadingIb
          ? null
          : () async {
              setState(() => _isLoadingIb = true);
              final result = await di<AuthRepository>().updateIsIb();
              setState(() => _isLoadingIb = false);
              result.fold(
                (failure) {
                  ToastState.error.snackBar(context, failure.message);
                },
                (success) {
                  ToastState.success.snackBar(context, 'Successfully became an IB'.tran);
                  final user = UserAccess.user;
                  if (user != null) {
                     context.read<ProfileCubit>().fetchUserView(user.userId);
                  }
                },
              );
            },
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.grey.shade300,
        padding: EdgeInsets.symmetric(horizontal: 24.s, vertical: 12.s),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.s),
        ),
      ),
      child: _isLoadingIb
          ? SizedBox(
              height: 20.s,
              width: 20.s,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              isIb ? 'Already an IB'.tran : 'Become IB'.tran,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.s,
                color: isIb ? Colors.grey.shade600 : null,
              ),
            ),
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

class _ProfileInfoTile extends StatelessWidget {
  final String title;
  final String value;
  
  const _ProfileInfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 8.s),
      padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.tran, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14.s)),
          Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 14.s, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
