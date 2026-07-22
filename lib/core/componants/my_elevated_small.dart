import 'package:flutter/material.dart';

class MyElevatedSmall extends StatelessWidget {
  const MyElevatedSmall({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
  });

  final String title;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: foregroundColor ?? colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
          textStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(title),
      ),
    );
  }
}

