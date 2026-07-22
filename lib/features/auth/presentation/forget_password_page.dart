import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/componants/my_elevated_button.dart';
import 'package:boker/core/componants/toast.dart';
import 'package:boker/core/config/routes/routes_manager.dart';
import '../../../core/componants/my_from_field.dart';
import '../../../core/utils/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../core/config/language/language_manager.dart';
import 'pages/otp_fields.dart';

/// Step index constants
enum _ForgotStep { email, otp, newPassword }

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  // ── Shared ──────────────────────────────────────────────────────────
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  // ── New-password step ────────────────────────────────────────────────
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _newPasswordObscure = true;
  bool _confirmPasswordObscure = true;

  // ── Flow state ───────────────────────────────────────────────────────
  _ForgotStep _step = _ForgotStep.email;

  /// OTP captured from the OtpFields widget
  String _capturedOtp = '';

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────────────

  void _submitEmail() {
    if (_emailFormKey.currentState!.validate()) {
      _emailFocusNode.unfocus();
      context.read<AuthCubit>().sendForgotPasswordOtp(
        email: _emailController.text.trim(),
      );
    }
  }

  void _verifyOtp(String otp) {
    // OTP is correct when the user taps Verify; store it and move to new-password step.
    setState(() {
      _capturedOtp = otp;
      _step = _ForgotStep.newPassword;
    });
  }

  Future<bool> _resendOtp() async {
    context.read<AuthCubit>().sendForgotPasswordOtp(
      email: _emailController.text.trim(),
    );
    return true; // timer will restart inside OtpFields
  }

  void _submitNewPassword() {
    if (_passwordFormKey.currentState!.validate()) {
      _newPasswordFocusNode.unfocus();
      _confirmPasswordFocusNode.unfocus();
      context.read<AuthCubit>().updatePasswordWithOtp(
        email: _emailController.text.trim(),
        otp: _capturedOtp,
        password: _newPasswordController.text,
      );
    }
  }

  void _goBack() {
    if (_step == _ForgotStep.otp) {
      setState(() => _step = _ForgotStep.email);
    } else if (_step == _ForgotStep.newPassword) {
      setState(() => _step = _ForgotStep.otp);
    } else {
      context.pop();
    }
  }

  // ── Validators ───────────────────────────────────────────────────────

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address'.tran;
    }
    final isEmail = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(value.trim());
    if (!isEmail) {
      return 'Please enter a valid email address'.tran;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password'.tran;
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters'.tran;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password'.tran;
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match'.tran;
    }
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isLoading = context.select<AuthCubit, bool>(
      (cubit) =>
          cubit.state.maybeWhen(loading: () => true, orElse: () => false),
    );
    final res = MyRes.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) {
                ToastState.error.snackBar(context, message);
              },
              forgotPasswordOtpSent: (email) {
                // OTP sent → move to OTP step
                if (_step == _ForgotStep.email) {
                  setState(() => _step = _ForgotStep.otp);
                }
              },
              passwordUpdated: () {
                ToastState.success.snackBar(
                  context,
                  'Password updated successfully'.tran,
                );
                context.goNamed(RoutesNames.signIn);
              },
              orElse: () {},
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Back button ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF0F2C59),
                      size: 28,
                    ),
                    onPressed: _goBack,
                  ),
                ),
              ),

              // ── Step indicator ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _StepIndicator(currentStep: _step),
              ),
              const SizedBox(height: 8),

              // ── Content ──────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.h,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: AppConstants.maxWidth,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                        child: switch (_step) {
                          _ForgotStep.email => _buildEmailStep(
                            theme,
                            colorScheme,
                            isLoading,
                            res,
                          ),
                          _ForgotStep.otp => _buildOtpStep(
                            theme,
                            colorScheme,
                            isLoading,
                            res,
                          ),
                          _ForgotStep.newPassword => _buildNewPasswordStep(
                            theme,
                            colorScheme,
                            isLoading,
                            res,
                          ),
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Email ─────────────────────────────────────────────────────

  Widget _buildEmailStep(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isLoading,
    ResHelper res,
  ) {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey('email_step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 130.h,
              height: 130.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 54.h,
                  color: const Color(0xFF1B3D81),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),

          Text(
            'Forgot Password?'.tran,
            style: TextStyle(
              color: const Color(0xFF0F2C59),
              fontSize: 26.h,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter your email and we will send you a verification code'.tran,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.h,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 36.h),

          Text(
            'Email Address'.tran,
            style: TextStyle(
              color: const Color(0xFF0F2C59),
              fontSize: 14.h,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          MyTextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            hintText: 'example@gmail.com'.tran,
            prefixIcon: Icons.email_outlined,
          ),
          SizedBox(height: 40.h),

          MyElevatedButton(
            label: 'Send OTP'.tran,
            onPressed: _submitEmail,
            isLoading: isLoading,
            expand: true,
            borderRadius: 30,
            backgroundColor: colorScheme.primary,
          ),
          SizedBox(height: 24.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remembered password? '.tran,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14.h,
                ),
              ),
              GestureDetector(
                onTap: () => context.goNamed(RoutesNames.signIn),
                child: Text(
                  'Go to Login'.tran,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: OTP ───────────────────────────────────────────────────────

  Widget _buildOtpStep(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isLoading,
    ResHelper res,
  ) {
    return Column(
      key: const ValueKey('otp_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 130.h,
            height: 130.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 54.h,
                color: const Color(0xFF1B3D81),
              ),
            ),
          ),
        ),
        SizedBox(height: 32.h),

        Text(
          'Check Your Email'.tran,
          style: TextStyle(
            color: const Color(0xFF0F2C59),
            fontSize: 26.h,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          '${'We sent a 4-digit code to'.tran}\n${_emailController.text.trim()}',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14.h,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 36.h),

        OtpFields(
          res: res,
          digits: 4,
          isLoading: isLoading,
          onVerify: _verifyOtp,
          onResend: _resendOtp,
        ),
      ],
    );
  }

  // ── Step 3: New Password ──────────────────────────────────────────────

  Widget _buildNewPasswordStep(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isLoading,
    ResHelper res,
  ) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        key: const ValueKey('new_password_step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 130.h,
              height: 130.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.lock_open_rounded,
                  size: 54.h,
                  color: const Color(0xFF1B3D81),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),

          Text(
            'Set New Password'.tran,
            style: TextStyle(
              color: const Color(0xFF0F2C59),
              fontSize: 26.h,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Your new password must be at least 6 characters'.tran,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.h,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 36.h),

          // New Password
          Text(
            'New Password'.tran,
            style: TextStyle(
              color: const Color(0xFF0F2C59),
              fontSize: 14.h,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          MyTextFormField(
            controller: _newPasswordController,
            focusNode: _newPasswordFocusNode,
            keyboardType: TextInputType.visiblePassword,
            validator: _validatePassword,
            hintText: '******',
            prefixIcon: Icons.lock_outline,
            isPassword: _newPasswordObscure,
            suffixIcon: _newPasswordObscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            suffixOnPressed: () =>
                setState(() => _newPasswordObscure = !_newPasswordObscure),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 20.h),

          // Confirm Password
          Text(
            'Confirm Password'.tran,
            style: TextStyle(
              color: const Color(0xFF0F2C59),
              fontSize: 14.h,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          MyTextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            keyboardType: TextInputType.visiblePassword,
            validator: _validateConfirmPassword,
            hintText: '******',
            prefixIcon: Icons.lock_outline,
            isPassword: _confirmPasswordObscure,
            suffixIcon: _confirmPasswordObscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            suffixOnPressed: () => setState(
              () => _confirmPasswordObscure = !_confirmPasswordObscure,
            ),
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 40.h),

          MyElevatedButton(
            label: 'Reset Password'.tran,
            onPressed: _submitNewPassword,
            isLoading: isLoading,
            expand: true,
            borderRadius: 30,
            backgroundColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final _ForgotStep currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const steps = _ForgotStep.values;

    return Row(
      children: steps.map((step) {
        final isActive = step.index <= currentStep.index;
        final isLast = step == steps.last;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (!isLast) const SizedBox(width: 4),
            ],
          ),
        );
      }).toList(),
    );
  }
}
