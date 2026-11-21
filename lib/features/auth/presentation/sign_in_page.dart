import 'package:easy_localization/easy_localization.dart'
    show BuildContextEasyLocalizationExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:boker/core/componants/logo_widget.dart';
import 'package:boker/core/componants/my_elevated_button.dart';
import 'package:boker/core/componants/toast.dart';
import 'package:boker/core/utils/constants/app_constants.dart';
import '../../../core/config/language/language_manager.dart';
import '../../../core/config/routes/routes_manager.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_widgets.dart';

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
                ToastState.error.snackBar(context, message.tran);
              },
              // Phone/SMS verification is not implemented by this backend
              // (no phone OTP endpoints exist - see AuthRemoteDataSource).
              // If the server ever asks for it, say so plainly instead of
              // opening a verification screen that cannot complete.
              otpRequired: (customerId, phone, email) {
                ToastState.warning.snackBar(
                  context,
                  'This account needs phone verification, which is not available in the app yet. Please complete it on the web portal.'
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
                  extra: {'email': email, 'password': password},
                );
              },
              orElse: () {},
            );
          },
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: res.w(16),
                vertical: res.h(5),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppConstants.maxWidth),
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
                              () => context.pushNamed(RoutesNames.signUp),
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
