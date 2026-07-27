import 'dart:async';
import 'package:easy_localization/easy_localization.dart' show BuildContextEasyLocalizationExtension;
import 'package:flutter/gestures.dart';
import 'package:boker/core/componants/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/componants/toast.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../core/componants/my_elevated_button.dart';
import '../../../core/componants/phone_from_intel.dart';
import '../../../core/componants/date_picker_field.dart';
import '../../../core/config/language/language_manager.dart';
import '../../../core/config/theme/theme.dart';
import '../../../core/utils/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_widgets.dart';
import 'pages/otp_fields.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _agreeToIB = false;

  // Live password validation state
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _passwordFieldTouched = false;

  String? _otpCustomerId;
  String? _otpPhone;
  String? _otpEmail;
  String? _otpPassword;

  @override
  void dispose() {
    _firstNameController.dispose();
    _companyNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _promoCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email'.tran;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address'.tran;
    }
    return null;
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordFieldTouched = true;
      _hasMinLength = value.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password'.tran;
    }
    if (!_hasMinLength) return 'Password must be at least 8 characters'.tran;
    if (!_hasUppercase) return 'Password must contain an uppercase letter'.tran;
    if (!_hasNumber) return 'Password must contain a number'.tran;

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password'.tran;
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match'.tran;
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name'.tran;
    }
    if (value.length < 4) {
      return 'Please enter valid full name'.tran;
    }
    return null;
  }

  void _handleSignUp() {
    if (!_agreeToTerms) {
      ToastState.error.snackBar(
        context,
        'Please agree to the Terms and Conditions'.tran,
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      String prefix = "+966";
      String mobile = _phoneController.text.trim();
      if (mobile.contains('-')) {
        final parts = mobile.split('-');
        if (parts.length >= 3) {
          prefix = parts[1];
          mobile = parts[2];
        } else if (parts.length == 2) {
          prefix = parts[0];
          mobile = parts[1];
        }
      }

      final data = <String, dynamic>{
        "clientType": _isCompany ? "company" : "customer",
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "confirmPassword": _confirmPasswordController.text,
        "mobile": mobile,
        "phonePrefix": prefix,
        "termsAgreed": _agreeToTerms,
        "promoCode": _promoCodeController.text.trim(),
        "isIb": _agreeToIB,
      };

      if (_isCompany) {
        data["companyName"] = _companyNameController.text.trim();
      } else {
        data["birthDate"] = _dobController.text.trim();
        data["firstName"] = _firstNameController.text.trim();
        data["lastName"] = _lastNameController.text.trim();
        data["idNumber"] = _idNumberController.text.trim();
      }

      setState(() {
        _otpPassword = _passwordController.text;
      });

      context.read<AuthCubit>().signUp(data: data);
    }
  }

  bool _isCompany = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final res = MyRes.of(context);
    final isWeb = res.width > 600;
    final activeColor = ColorsManager.blueLight;
    final inactiveColor = colorScheme.surface;
    final primaryColor = colorScheme.primary;
    final inactiveTextColor = colorScheme.onSurfaceVariant;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              registrationPending: (user) {
                // Navigate to role selection page
                context.push(
                  '/${RoutesNames.initialRoute}',
                  extra: {
                    'userId': user.id,
                    'email': user.email,
                    'fullName': user.fullName,
                  },
                );
              },
              authenticated: (user, token, refreshToken, isSignIn) {
                Router.neglect(
                  context,
                  () => context.go(RoutesNames.initialRoute),
                );
              },
              otpRequired: (customerId, phone, email) {
                setState(() {
                  _otpCustomerId = customerId;
                  _otpPhone = phone;
                  _otpEmail = email;
                });
              },
              emailOtpVerified: () {
                ToastState.success.snackBar(
                  context,
                  'Email verified successfully. Proceeding to identity verification.'.tran,
                );
                context.pushNamed(
                  RoutesNames.identityVerification,
                  extra: {
                    'email': _otpEmail,
                    'password': _otpPassword ?? _passwordController.text.trim(),
                  },
                );
              },
              unauthenticated: () {
                if (_otpEmail != null) {
                  ToastState.success.snackBar(
                    context,
                    'Email verified successfully. Your account is now active.'
                        .tran,
                  );
                  setState(() {
                    _otpCustomerId = null;
                    _otpPhone = null;
                    _otpEmail = null;
                  });
                } else {
                  ToastState.success.snackBar(
                    context,
                    'Registration successful!'.tran,
                  );
                }
                context.pop();
              },
              error: (message) {
                ToastState.error.snackBar(context, message);
              },
              orElse: () {},
            );
          },
          child: Center(
            child: _otpEmail != null
                ? _buildOtpView()
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: res.w(16),
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxWidth,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLanguageDropdown(context),
                                LogoWidget(width: 100.s, height: 55.s),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Create Account'.tran,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontSize: 26.h,
                              ),
                            ),
                            Text(
                              'Sign up to get started'.tran,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16.h,
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Container(
                              height: res.h(53),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius90,
                                ),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                  width: 1.2,
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isCompany = true;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius90,
                                      ),
                                      child: Container(
                                        height: res.h(52),
                                        decoration: BoxDecoration(
                                          color: _isCompany
                                              ? activeColor
                                              : inactiveColor,
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.borderRadius90,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.business,
                                              color: _isCompany
                                                  ? primaryColor
                                                  : inactiveTextColor,
                                              size: res.h(24),
                                            ),
                                            SizedBox(width: res.w(8)),
                                            Text(
                                              'Company'.tran,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: _isCompany
                                                        ? primaryColor
                                                        : inactiveTextColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.h,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isCompany = false;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius90,
                                      ),

                                      child: Container(
                                        height: res.h(52),
                                        decoration: BoxDecoration(
                                          color: !_isCompany
                                              ? activeColor
                                              : inactiveColor,
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.borderRadius90,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: !_isCompany
                                                  ? primaryColor
                                                  : inactiveTextColor,
                                              size: res.h(24),
                                            ),
                                            SizedBox(width: res.w(8)),
                                            Text(
                                              'Customer'.tran,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: !_isCompany
                                                        ? primaryColor
                                                        : inactiveTextColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.h,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            if (_isCompany) ...[
                              // Company Name field
                              AuthTextField(
                                label: 'Company Name'.tran,
                                hintText: 'Enter Company Name'.tran,
                                controller: _companyNameController,
                                keyboardType: TextInputType.text,
                                validator: (val) => val == null || val.isEmpty ? 'Required'.tran : null,
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: 9.h),
                            ] else ...[
                              // First Name & Last Name fields
                              AuthTextField(
                                label: 'First Name'.tran,
                                hintText: 'Enter First Name'.tran,
                                controller: _firstNameController,
                                keyboardType: TextInputType.text,
                                validator: (val) => val == null || val.isEmpty ? 'Required'.tran : null,
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: 9.h),
                              AuthTextField(
                                label: 'Last Name'.tran,
                                hintText: 'Enter Last Name'.tran,
                                controller: _lastNameController,
                                keyboardType: TextInputType.text,
                                validator: (val) => val == null || val.isEmpty ? 'Required'.tran : null,
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: 9.h),
                            ],

                            // Email field
                            AuthTextField(
                              label: 'Email'.tran,
                              hintText: 'example@email.com'.tran,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 9.h),

                            if (!_isCompany) ...[
                              // ID Number field
                              AuthTextField(
                                label: 'ID Number'.tran,
                                hintText: 'Enter ID Number'.tran,
                                controller: _idNumberController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: 9.h),

                              // Date of Birth field
                              DatePickerField(
                                label: 'Date of Birth'.tran,
                                hintText: 'yyyy-mm-dd'.tran,
                                controller: _dobController,
                              ),
                              SizedBox(height: 9.h),
                            ],

                            // Phone field
                            Text(
                              'Phone Number'.tran,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.h,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: MyPhoneFromField(
                                initPhone: "SA-+966-",
                                controller: _phoneController,
                                res: res,
                                onChanged: (phone, formattedPhoneNumber) {},
                              ),
                            ),
                            SizedBox(height: 9.h),

                            // Promo Code field
                            AuthTextField(
                              label: 'Promo Code (Optional)'.tran,
                              hintText: 'Enter Promo Code'.tran,
                              controller: _promoCodeController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 16.h),

                            // I agree to become an IB checkbox
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'I agree to become an IB'.tran,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14.h,
                                  ),
                                ),
                                SizedBox(width: 8.h),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToIB = !_agreeToIB;
                                    });
                                  },
                                  child: Container(
                                    width: 18.h,
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                      color: _agreeToIB
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _agreeToIB
                                        ? Icon(
                                            Icons.check,
                                            size: 14.h,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            // Password field
                            AuthTextField(
                              label: 'Password'.tran,
                              hintText: 'Min. 8 characters'.tran,
                              controller: _passwordController,
                              isPassword: _obscurePassword,
                              validator: _validatePassword,
                              onChanged: (v) {
                                _onPasswordChanged(v);
                                if (_formKey.currentState != null) {
                                  _formKey.currentState!.validate();
                                }
                              },
                              suffixOnPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              suffixIcon: _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              textInputAction: TextInputAction.next,
                            ),
                            // Live password requirements panel
                            if (_passwordFieldTouched) ...[
                              SizedBox(height: 12.h),
                              _PasswordRequirementsWidget(
                                res: res,
                                hasMinLength: _hasMinLength,
                                hasUppercase: _hasUppercase,

                                hasNumber: _hasNumber,
                              ),
                            ],
                            SizedBox(height: 9.h),

                            // Confirm Password field
                            AuthTextField(
                              label: 'Confirm Password'.tran,
                              hintText: 'Re-enter password'.tran,
                              controller: _confirmPasswordController,
                              isPassword: _obscureConfirmPassword,
                              validator: _validateConfirmPassword,
                              suffixOnPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              suffixIcon: _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,

                              textInputAction: TextInputAction.done,
                              onChanged: (_) {
                                if (_passwordFieldTouched) {
                                  setState(() {
                                    _passwordFieldTouched = false;
                                  });
                                }
                                if (_formKey.currentState != null) {
                                  _formKey.currentState!.validate();
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            // Terms and Conditions checkbox
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToTerms = !_agreeToTerms;
                                    });
                                  },
                                  child: Container(
                                    width: 18.h,
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                      color: _agreeToTerms
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _agreeToTerms
                                        ? Icon(
                                            Icons.check,
                                            size: 14.h,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 8.h),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 14.h,
                                          ),
                                      children: [
                                        TextSpan(text: 'I agree to the '.tran),
                                        TextSpan(
                                          text: 'Terms & Conditions'.tran,
                                          style: TextStyle(
                                            color: Color(0xffF3CD11),
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         const TermsAndConditionsWebView(
                                              //           url:
                                              //               'https://www.example.com/terms',
                                              //           title:
                                              //               'Terms & Conditions',
                                              //         ),
                                              //   ),
                                              // );
                                            },
                                        ),
                                        TextSpan(
                                          text: ' & '.tran,
                                          style: TextStyle(
                                            color: Color(0xffF3CD11),
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy'.tran,
                                          style: TextStyle(
                                            color: Color(0xffF3CD11),
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         const TermsAndConditionsWebView(
                                              //           url:
                                              //               'https://www.example.com/privacy',
                                              //           title: 'Privacy Policy',
                                              //         ),
                                              //   ),
                                              // );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            // Sign Up button
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                final isLoading = state.maybeWhen(
                                  loading: () => true,
                                  orElse: () => false,
                                );
                                return MyElevatedButton(
                                  maximumSize: Size.fromHeight(53.h),
                                  minimumSize: Size.fromHeight(53.h),
                                  label: 'Create Account'.tran,
                                  onPressed: isLoading ? null : _handleSignUp,
                                  isLoading: isLoading,
                                  res: res,
                                );
                              },
                            ),
                            const SizedBox(height: 32),

                            // // OR divider
                            // AuthDivider(
                            //   res: res,
                            //   text: 'or continue with'.tran,
                            // ),
                            // const SizedBox(height: 32),
                            //
                            // // Google Sign In button
                            // GoogleButtonWidget(res: res),
                            // const SizedBox(height: 32),

                            // Sign In link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?'.tran,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14.h,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: () {
                                    Router.neglect(
                                      context,
                                      () => context.goNamed(RoutesNames.signIn),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: Text(
                                    'Sign In'.tran,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _buildOtpView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final res = MyRes.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
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
                    _otpCustomerId = null;
                    _otpPhone = null;
                    _otpEmail = null;
                  });
                },
              ),
            ),
            SizedBox(height: 24.h),

            // Beautiful smartphone illustration
            _buildIllustration(res),
            SizedBox(height: 32.h),

            Text(
              'We sent a verification code to\n{email}'.tranArg(
                namedArgs: {'email': _otpEmail!},
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 18.h,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 24),

            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                return OtpFields(
                  isLoading: isLoading,
                  onVerify: (otp) {
                    context.read<AuthCubit>().verifyEmailOtp(
                      email: _otpEmail!,
                      otp: otp,
                    );
                  },
                  onResend: () async {
                    // TODO: Replace with the actual reset OTP API once provided
                    ToastState.error.snackBar(context, 'Resend OTP API not provided yet'.tran);
                    return false;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(ResHelper res) {
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
                border: Border.all(color: Colors.grey.shade300, width: 3.h),
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
                    top: 10.h,
                    child: Container(
                      width: 28.h,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2.5.h),
                      ),
                    ),
                  ),
                  // Avatar
                  Container(
                    width: 44.h,
                    height: 44.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A8A), // deep blue/navy
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 28.h),
                  ),
                  // Bottom lines to simulate UI
                  Positioned(
                    bottom: 25.h,
                    child: Container(
                      width: 40.h,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(3.h),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12.h,
                    child: Container(
                      width: 30.h,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(3.h),
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
  Widget _buildLanguageDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: context.locale,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurface,
            size: 20,
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

// ─────────────────────────────────────────────────────────────────────────────
// Password Requirements Widget
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordRequirementsWidget extends StatelessWidget {
  const _PasswordRequirementsWidget({
    required this.res,
    required this.hasMinLength,
    required this.hasUppercase,

    required this.hasNumber,
  });

  final ResHelper res;
  final bool hasMinLength;
  final bool hasUppercase;

  final bool hasNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: res.w(14), vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: const Color(0xFFF3CD11).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The password must contain:'.tran,
            style: TextStyle(
              color: const Color(0xFFB8860B),
              fontWeight: FontWeight.w700,
              fontSize: 12.h,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RequirementRow(
                      res: res,
                      met: hasMinLength,
                      label: 'At least 8 characters'.tran,
                    ),
                    SizedBox(height: res.h(6)),
                    _RequirementRow(
                      res: res,
                      met: hasNumber,
                      label: 'At least one number'.tran,
                    ),
                  ],
                ),
              ),
              SizedBox(width: res.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RequirementRow(
                      res: res,
                      met: hasUppercase,
                      label: 'At least one uppercase'.tran,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.res,
    required this.met,
    required this.label,
  });

  final ResHelper res;
  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF22409A) : Colors.grey.shade400;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 16.h,
          height: 16.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? const Color(0xFF22409A) : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
          ),
          child: met
              ? Icon(Icons.check_rounded, size: 10.h, color: Colors.white)
              : null,
        ),
        SizedBox(width: res.w(6)),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: met ? const Color(0xFF22409A) : Colors.grey.shade500,
              fontSize: res.h(11),
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
