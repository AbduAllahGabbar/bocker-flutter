import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/config/language/language_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/di_container.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../features/auth/cubit/auth_state.dart' as auth_state;
import '../../../../core/config/routes/routes_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _locationServices = true;
  bool _pushNotifications = false;
  bool _emailUpdates = true;
  bool _smsAlerts = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black87,
            size: 24.r,
          ),
        ),
        title: Text(
          'App Settings'.tran,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF1B2651),
            fontWeight: FontWeight.w700,
            fontSize: 20.h,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.h),
            border: Border.all(color: Colors.grey.shade200, width: 1.h),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSwitchRow(
                title: 'Notifications'.tran,
                value: _notifications,
                onChanged: (val) => setState(() => _notifications = val),
              ),
              const Divider(color: Color(0xFFEEEFF3), height: 1, thickness: 1),
              _buildSwitchRow(
                title: 'Location Services'.tran,
                value: _locationServices,
                onChanged: (val) => setState(() => _locationServices = val),
              ),
              const Divider(color: Color(0xFFEEEFF3), height: 1, thickness: 1),
              _buildSwitchRow(
                title: 'Push Notifications'.tran,
                value: _pushNotifications,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),
              const Divider(color: Color(0xFFEEEFF3), height: 1, thickness: 1),
              _buildSwitchRow(
                title: 'Email Updates'.tran,
                value: _emailUpdates,
                onChanged: (val) => setState(() => _emailUpdates = val),
              ),
              const Divider(color: Color(0xFFEEEFF3), height: 1, thickness: 1),
              _buildSwitchRow(
                title: 'SMS Alerts'.tran,
                value: _smsAlerts,
                onChanged: (val) => setState(() => _smsAlerts = val),
              ),
              const Divider(color: Color(0xFFEEEFF3), height: 1, thickness: 1),
              _buildActionRow(
                title: 'Change Language'.tran,
                onTap: () => context.pushNamed(RoutesNames.language),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.h),
        child: BlocConsumer<AuthCubit, auth_state.AuthState>(
          bloc: di<AuthCubit>(),
          listener: (context, state) {
            state.maybeWhen(
              unauthenticated: () {
                context.goNamed(RoutesNames.login);
              },
              error: (msg) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            return ElevatedButton(
              onPressed: isLoading ? null : () => _showDeleteAccountDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: Colors.red.shade200, width: 1),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 24.r,
                      width: 24.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : Text(
                      'Delete Account'.tran,
                      style: TextStyle(
                        fontSize: 16.h,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Account'.tran),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.'.tran,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.tran),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              di<AuthCubit>().deleteAccount();
            },
            child: Text(
              'Delete'.tran,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.h,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF28439A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            onChanged: onChanged,
          ),
        ],
    ));
  }

  Widget _buildActionRow({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.h,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.r,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
