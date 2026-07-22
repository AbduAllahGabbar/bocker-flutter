import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.icon,
    this.isLoading = false,
  });

  final String title;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (icon != null) {
      return TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? theme.colorScheme.primary,
                  ),
                ),
              )
            : icon!,
        label: Text(title),
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? theme.colorScheme.primary,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? theme.colorScheme.primary,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? theme.colorScheme.primary,
                ),
              ),
            )
          : Text(title),
    );
  }
}

