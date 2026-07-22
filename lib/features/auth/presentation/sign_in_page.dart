import 'dart:async';
import 'package:boker/features/app/app_cubit.dart';
import 'package:easy_localization/easy_localization.dart'
    show BuildContextEasyLocalizationExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/componants/logo_widget.dart';
import 'package:boker/core/componants/my_elevated_button.dart';
import 'package:boker/core/componants/toast.dart';
import 'package:boker/core/config/theme/theme.dart';
import 'package:boker/core/utils/constants/app_constants.dart';
import '../../../core/componants/phone_from_intel.dart';
import '../../../core/config/language/language_manager.dart';
import '../../../core/config/routes/routes_manager.dart';
import '../../../core/di/di_container.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_widgets.dart';
import 'pages/otp_fields.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, this.callback, this.back});

  final String? callback;
  final bool? back;

  @override
  State<SignInPage> createState() => _SignInPageState();

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(minWidth: 600),
      builder: (context) => this,
    );
  }
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  bool _isOtpVisible = false;
  String? _otpPhone;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email'.tran;
    }
    final isEmail = value.contains('@');
    if (!isEmail) {
      return 'Please enter a valid email address'.tran;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password'.tran;
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters'.tran;
    }
    return null;
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        emailOrPhone: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleGoogleSignIn() {
    // context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final res = MyRes.of(context);

    final primaryColor = colorScheme.primary;
    final isLoading = context.select<AuthCubit, bool>(
      (cubit) =>
          cubit.state.maybeWhen(loading: () => true, orElse: () => false),
    );

    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (user, token, refreshToken, isSignIn) {
                if (widget.back == true) {
                  context.pop(true);
                } else if (widget.callback != null) {
                  context.go(widget.callback!);
                } else {
                  Router.neglect(
                    context,
                    () => context.go(RoutesNames.initialRoute),
                  );
                }
              },
              error: (message) {
                print("=====$message");
                if (message == 'No account found with this phone number') {
                  setState(() {
                    final phone = _emailController.text.trim().split('-');
                    final formattedPhone = '${phone[1]}${phone[2]}';
                    _otpPhone = formattedPhone;
                    _isOtpVisible = true;
                  });
                  return ToastState.success.snackBar(
                    context,
                    'If you have account with this phone number, please check your inbox for the OTP'
                        .tran,
                  );
                }
                ToastState.error.snackBar(context, message.tran);
              },
              otpRequired: (customerId, phone, email)  {
                // Triggered by both phone-login and email-login flows
                setState(() {
                  _otpPhone = phone;
                  _isOtpVisible = true;
                });
                ToastState.success.snackBar(
                  context,
                  'If you have account with this phone number, please check your inbox for the OTP'
                      .tran,
                );
              },
              formNotCompleted: (email, password) {
                ToastState.warning.snackBar(
                  context,
                  'Please complete your verification form.'.tran,
                );
                context.pushNamed(
                  RoutesNames.identityVerification,
                  extra: {
                    'email': email,
                    'password': password,
                  },
                );
              },
              orElse: () {},
            );
          },
          child: Center(
            child: _isOtpVisible
                ? _buildOtpView()
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: res.w(16),
                      vertical: res.h(5),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: AppConstants.maxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.back == true) ...[
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => context.pop(),
                                      icon: Icon(Icons.arrow_back, size: 25.h),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  _buildLanguageDropdown(context),
                                ],
                              ),
                              LogoWidget(width: 100.s, height: 55.s),
                            ],
                          ),
                           SizedBox(height: 50.s),
                          Text(
                            'Log in'.tran,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: res.h(26),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Hello, welcome back'.tran,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.h,
                            ),
                          ),

                          const SizedBox(height: 32),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildEmailForm(key: const ValueKey('email')),

                                SizedBox(height: res.h(24)),

                                MyElevatedButton(
                                  label: 'Login'.tran,
                                  onPressed: isLoading ? null : _handleSignIn,
                                  isLoading: isLoading,
                                  res: res,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?".tran,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14.h,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Router.neglect(
                                    context,
                                    () => context.goNamed(RoutesNames.signUp),
                                  );
                                },
                                child: Text(
                                  'Sign Up'.tran,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                    fontSize: 16.h,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back Arrow Icon Button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: colorScheme.onSurface,
                  size: 20.h,
                ),
                onPressed: () {
                  setState(() {
                    _otpPhone = null;
                    _isOtpVisible = false;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Beautiful smartphone illustration
            _buildIllustration(),
            SizedBox(height: 32.h),

            if (_otpPhone != null) ...[
              Text(
                'We sent a verification code to\n{phone}'.tranArg(
                  namedArgs: {'phone': _otpPhone!},
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16.h,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
              ),
            ],
            SizedBox(height: 24.h),

            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                return OtpFields(
                  isLoading: isLoading,
                  onVerify: (otp) {
                    context.read<AuthCubit>().verifyPhoneLoginOtp(
                      phone: _otpPhone!,
                      otp: otp,
                    );
                  },
                  onResend: () async {
                    try {
                      await context.read<AuthCubit>().requestPhoneLoginOtp(
                        phone: _otpPhone!,
                      );
                      return true;
                    } catch (e) {
                      return false;
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: SizedBox(
        width: 120.h,
        height: 160.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Smartphone chassis
            Container(
              width: 80.h,
              height: 140.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera notch/Speaker
                  Positioned(
                    top: 10,
                    child: Container(
                      width: 28,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A8A), // deep blue/navy
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Bottom lines to simulate UI
                  Positioned(
                    bottom: 25,
                    child: Container(
                      width: 40,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    child: Container(
                      width: 30,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Yellow pill badge overlaying
            Positioned(
              right: 2.h,
              top: 55.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107), // Gold/Amber
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '***',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.h,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm({required Key key}) {
    final theme = Theme.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'Email Address'.tran,
          hintText: 'Enter your email'.tran,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          focusNode: _emailFocusNode,
          prefixIcon: Icons.email_outlined,
          onChanged: (_) {},
        ),
        SizedBox(height: 16.h),
        AuthTextField(
          label: 'Password'.tran,
          hintText: 'Enter your password'.tran,
          controller: _passwordController,
          isPassword: _obscurePassword,
          validator: _validatePassword,
          focusNode: _passwordFocusNode,
          prefixIcon: Icons.lock_outline,
          suffixOnPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,

          onChanged: (_) {},
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Container(
                width: 18.h,
                height: 18.h,
                decoration: BoxDecoration(
                  color: _rememberMe
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _rememberMe
                    ? Icon(Icons.check, size: 14.h, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 10.h),

            Text(
              'Remember me'.tran,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.h,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                context.push('/forgot-password');
              },
              child: Text(
                'Forgot Password?'.tran,

                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Color(0xffF3CD11),
                  fontSize: 14.h,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneForm({required Key key}) {
    final theme = Theme.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Phone Number'.tran,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16.h,
          ),
        ),
        SizedBox(height: 8.h),
        Directionality(
          textDirection: TextDirection.ltr,
          child: MyPhoneFromField(
            initPhone: "SA-+966-",
            controller: _emailController,
            withValidator: true,
          ),
        ),
        SizedBox(height: 143.h),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = context.locale;
    final isArabic = currentLocale.languageCode == 'ar';
    final dropdownValue = isArabic
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: dropdownValue,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface,
          ),
          isDense: true,
          dropdownColor: theme.colorScheme.surface,
          items: [
            DropdownMenuItem(
              value: const Locale('en', 'US'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/flags/us.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EN',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: const Locale('ar', 'SA'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.asset(
                      'assets/flags/sa.png',
                      width: 24,
                      height: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AR',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              context.setLocale(newLocale);
            }
          },
        ),
      ),
    );
  }
}
