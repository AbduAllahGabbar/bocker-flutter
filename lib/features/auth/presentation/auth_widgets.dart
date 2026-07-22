import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/utils/constants/app_constants.dart';
import '../../../core/componants/my_from_field.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? suffixOnPressed;
  final bool readOnly;
  final VoidCallback? onTap;

  const AuthTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.suffixOnPressed,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14.h,
          ),
        ),
         SizedBox(height: 2.h),
        MyTextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          suffixOnPressed: suffixOnPressed,
          fillColor: colorScheme.surface,
          isPassword: isPassword,
          readOnly: readOnly,
          onTap: onTap,
        ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final FontWeight? fontWeight;
final ResHelper res;
  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fontWeight, required this.res,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: textColor ?? colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius90),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!,  SizedBox(width: 8.h)],
                  Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor ?? colorScheme.onPrimary,
                      fontWeight: fontWeight ?? FontWeight.bold,
                      fontSize: 16.h,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  final String text;
  final ResHelper res;
  const AuthDivider({super.key, required this.text, required this.res});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(color: colorScheme.outlineVariant, thickness: 1.h),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.h,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: colorScheme.outlineVariant, thickness: 1.h),
        ),
      ],
    );
  }
}

class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottom bar with M
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.3,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Top M
          Positioned(
            top: size * 0.15,
            child: Text(
              'M',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
