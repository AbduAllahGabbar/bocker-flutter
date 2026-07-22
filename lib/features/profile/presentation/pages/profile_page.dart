import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:res_reline/my_responsive.dart';
import 'package:boker/features/app/app_cubit.dart';
import 'package:boker/features/app/app_state.dart';
import 'package:boker/features/auth/cubit/auth_cubit.dart';
import 'package:boker/features/auth/cubit/auth_state.dart';
import '../../../../core/componants/toast.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/helpers/restart_widget.dart';
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
        final res = MyRes.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.h),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.h),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4E6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFE11D48),
                    size: 32.h,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Logout'.tran,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.h,
                        color: const Color(0xFF1E293B),
                      ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Are you sure you want to logout from your account?'.tran,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14.h,
                      ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(90.h),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          foregroundColor: const Color(0xFF1E293B),
                        ),
                        child: Text(
                          'Cancel'.tran,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          di<AuthCubit>().signOut();
                          di<AuthCubit>().signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(90.h),
                          ),
                        ),
                        child: Text(
                          'Logout'.tran,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.h,
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
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final res = MyRes.of(context);
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
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: RefreshIndicator(
              onRefresh: () => context.read<AuthCubit>().getCurrentUser(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ── Collapsible SliverAppBar with profile header ─────────
                  SliverAppBar(
                    pinned: false,
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    centerTitle: true,
                    toolbarHeight: 60.h,
                    leading: canPop
                        ? IconButton(
                            onPressed: context.pop,
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.black87,
                              size: 24.r,
                            ),
                          )
                        : null,
                    title: Text(
                      'My Account'.tran,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1D3A99),
                        fontWeight: FontWeight.w700,
                        fontSize: 20.h,
                      ),
                    ),
                    bottom:PreferredSize(
                      preferredSize: Size.fromHeight(120.h),
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _AccountHeaderCard(state: state),
                      ),
                    ),
                  ),

                  // ── Menu cards ───────────────────────────────────────────
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _ProfileMenuCard(
                          title: 'Saved Addresses'.tran,
                          icon: Icons.location_on_outlined,
                          trailingText: state.isGuest
                              ? null
                              : '${state.user?.addresses?.length ?? 0} addresses',
                          onTap: () {
                            if (state.isGuest) {
                              context.goNamed(RoutesNames.signIn);
                            } else {
                            //  context.pushNamed(RoutesNames.accountAddresses);
                            }
                          },
                        ),
                        // _ProfileMenuCard(
                        //   title: 'Orders'.tran,
                        //   icon: Icons.checklist,
                        //   onTap: () {
                        //     if (state.isGuest) {
                        //       context.goNamed(RoutesNames.signIn);
                        //     } else {
                        //       context.pushNamed(RoutesNames.accountOrders);
                        //     }
                        //   },
                        // ),
                        // _ProfileMenuCard(
                        //   title: 'Payment Methods'.tran,
                        //   icon: Icons.credit_card_outlined,
                        //   trailingText: state.isGuest ? null : '3 cards',
                        //   onTap: () {
                        //     if (state.isGuest) {
                        //       context.goNamed(RoutesNames.signIn);
                        //     } else {
                        //       context.pushNamed(
                        //         RoutesNames.accountPaymentMethods,
                        //       );
                        //     }
                        //   },
                        // ),
                        BlocBuilder<AppCubit, AppState>(
                          builder: (context, appState) {
                            return _ProfileMenuCard(
                              title: 'Language'.tran,
                              icon: Icons.language,
                              trailingText: LanguageType.fromValue(
                                appState.languageCode,
                              ).title,
                              onTap: () async {
                                final result = await context.pushNamed(
                                  RoutesNames.language,
                                );
                                if (result==true) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    RestartWidget.restartApp(context);
                                  });
                                }
                              },
                            );
                          },
                        ),
                        _ProfileMenuCard(
                          title: 'App Settings'.tran,
                          icon: Icons.settings_outlined,
                          onTap: () => context.pushNamed(RoutesNames.settings),
                        ),
                        _ProfileMenuCard(
                          title: 'Contact Us'.tran,
                          icon: Icons.support_agent_outlined,
                          onTap: (){},                        ),
                        _ProfileMenuCard(
                          title: 'FAQ'.tran,
                          icon: Icons.help_outline,
                          onTap: (){},                        ),
                        _ProfileMenuCard(
                          title: 'Terms & Conditions'.tran,
                          icon: Icons.description_outlined,
                          onTap: (){},                        ),
                        _ProfileMenuCard(
                          title: 'Privacy Policy'.tran,
                          icon: Icons.privacy_tip_outlined,
                          onTap: (){},                        ),
                        _ProfileMenuCard(
                          title: 'Returns & Exchange'.tran,
                          icon: Icons.change_circle_outlined,
                          onTap: (){},
                        ),
                        _ProfileMenuCard(
                          title: 'About Us'.tran,
                          icon: Icons.storefront_outlined,
                          onTap: (){},                        ),
                        _ProfileMenuCard(
                          title: 'About App'.tran,
                          icon: Icons.info_outline,
                          trailingText: 'v2.4.0',
                          onTap: () =>
                              context.pushNamed(RoutesNames.accountAbout),
                        ),
                        _ProfileMenuCard(
                          title: state.isGuest ? 'Login'.tran : 'Logout'.tran,
                          icon: state.isGuest
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          isLogout: !state.isGuest,
                          onTap: state.isGuest
                              ? () => context.goNamed(RoutesNames.signIn)
                              : () => _showLogoutDialog(context),
                        ),
                      ]),
                    ),
                  ),

                  // ── Bottom spacing ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.paddingOf(context).bottom + 16.h,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccountHeaderCard extends StatelessWidget {
  final AccountState state;

  const _AccountHeaderCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = state.user;
    final hasAvatar = user?.avatarUrl?.trim().isNotEmpty ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(height: 16.h),
        Text(
          state.displayName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D3A99),
            fontSize: 20.h,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          state.isGuest
              ? 'Sign in to access your account'.tran
              : (state.user?.phone ?? state.user?.email ?? ''),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
            fontSize: 14.h,
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: state.isGuest
              ? () => context.goNamed(RoutesNames.signIn)
              : () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Profile editing is not available yet.'),
                      ),
                    );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D3A99),
            foregroundColor: Colors.white,
            minimumSize: Size(150, 41),
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            elevation: 0,
          ),
          child: Text(
            state.isGuest ? 'Login'.tran : 'Edit Profile'.tran,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.h,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailingText;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileMenuCard({
    required this.title,
    required this.icon,
    this.trailingText,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: isLogout
                      ? const Color(0xFFFEE2E2)
                      : Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : Colors.black87,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLogout ? Colors.red : const Color(0xFF1F2937),
                    fontSize: 16.h,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.h,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
