import 'package:boker/core/utils/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';


class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,

    /// Action
    this.onPressed,
    this.onLongPress,

    /// Content
    this.child,
    this.label,
    this.prefix,
    this.suffix,

    /// States
    this.isLoading = false,
    this.enabled = true,

    /// Layout
    this.expand = false,
    this.alignment = MainAxisAlignment.center,

    /// Style
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.overlayColor,
    this.elevation,
    this.borderRadius,
    this.side,
    this.padding,
    this.minimumSize,
    this.maximumSize,
    this.textStyle,

    /// Loader
    this.loaderSize = 18,
    this.loaderStrokeWidth = 2,
    this.loaderColor, this.res, this.height,
  }) : assert(child != null || label != null, 'Provide child or label');

  /// Actions
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  /// Content
  final Widget? child;
  final String? label;
  final Widget? prefix;
  final Widget? suffix;

  /// States
  final bool isLoading;
  final bool enabled;

  /// Layout
  final bool expand;
  final double? height;
  final MainAxisAlignment alignment;

  /// Style
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Color? overlayColor;
  final double? elevation;
  final double? borderRadius;
  final BorderSide? side;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final Size? maximumSize;
  final TextStyle? textStyle;

  /// Loader
  final double loaderSize;
  final double loaderStrokeWidth;
  final Color? loaderColor;
final ResHelper? res ;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isDisabled = !enabled || isLoading || onPressed == null;
    final res = this.res ?? MyRes.of(context);
    final style = ButtonStyle(

      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledBackgroundColor ?? scheme.onSurface.withValues(alpha: 0.12);
        }
        return backgroundColor ?? scheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledForegroundColor ?? scheme.onSurface.withValues(alpha: 0.38);
        }
        return foregroundColor ?? scheme.onPrimary;
      }),
      overlayColor: overlayColor != null
          ? WidgetStatePropertyAll(overlayColor)
          : null,
      elevation: WidgetStatePropertyAll(elevation ?? 2),
      padding: WidgetStatePropertyAll(
        padding ??  EdgeInsets.symmetric(horizontal: 20, vertical: 14.h),
      ),
      minimumSize: WidgetStatePropertyAll(minimumSize),
      maximumSize: WidgetStatePropertyAll(maximumSize),
      textStyle: WidgetStatePropertyAll(
        textStyle ?? theme.textTheme.labelLarge?.copyWith(
          fontSize: 16.h,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadius16),
          side: side ?? BorderSide.none,
        ),
      ),
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        onLongPress: isDisabled ? null : onLongPress,
        style: style,
        child: _buildChild(scheme),
      ),
    );
  }

  Widget _buildChild(ColorScheme scheme) {
    if (isLoading) {
      return SizedBox(
        width: loaderSize,
        height: loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: loaderStrokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            loaderColor ?? scheme.onPrimary,
          ),
        ),
      );
    }

    if (child != null) return child!;

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        if (prefix != null) ...[
          prefix!,
          const SizedBox(width: 8),
        ],
        Text(label!,
        style: textStyle,
        ),
        if (suffix != null) ...[
          const SizedBox(width: 8),
          suffix!,
        ],
      ],
    );
  }
}

enum ButtonVariant { filled, outlined, text }
enum ButtonSize { small, medium, large }

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    this.onPressed,
    this.child,
    this.label,
    this.prefix,
    this.suffix,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.expand = false,

    /// Style overrides
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.textStyle,
    this.loaderColor,
    this.loaderSize,
  }) : assert(child != null || label != null, 'Provide child or label');

  final VoidCallback? onPressed;

  /// Content
  final Widget? child;
  final String? label;
  final Widget? prefix;
  final Widget? suffix;

  /// Behavior
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool expand;

  /// Style overrides
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  /// Loader
  final Color? loaderColor;
  final double? loaderSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final size = _resolveSize();
    final colors = _resolveColors(scheme);

    final style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(colors.background),
      foregroundColor: WidgetStatePropertyAll(colors.foreground),
      elevation: WidgetStatePropertyAll(elevation ?? colors.elevation),
      padding: WidgetStatePropertyAll(padding ?? size.padding),
      minimumSize: WidgetStatePropertyAll(size.minSize),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          side: variant == ButtonVariant.outlined
              ? BorderSide(color: borderColor ?? colors.border!)
              : BorderSide.none,
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        textStyle ?? theme.textTheme.labelLarge,
      ),
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      child: _buildButton(style, colors),
    );
  }

  Widget _buildButton(ButtonStyle style, _ButtonColors colors) {
    final content = isLoading
        ? SizedBox(
      width: loaderSize ?? 18,
      height: loaderSize ?? 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          loaderColor ?? colors.foreground,
        ),
      ),
    )
        : _buildContent();

    switch (variant) {
      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: content,
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: content,
        );
      case ButtonVariant.filled:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: content,
        );
    }
  }

  Widget _buildContent() {
    if (child != null) return child!;

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefix != null) ...[
          prefix!,
          const SizedBox(width: 8),
        ],
        Text(label!),
        if (suffix != null) ...[
          const SizedBox(width: 8),
          suffix!,
        ],
      ],
    );
  }

  _ButtonSize _resolveSize() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonSize(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minSize: const Size(64, 36),
        );
      case ButtonSize.large:
        return _ButtonSize(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minSize: const Size(120, 56),
        );
      case ButtonSize.medium:
      default:
        return _ButtonSize(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minSize: const Size(88, 48),
        );
    }
  }

  _ButtonColors _resolveColors(ColorScheme scheme) {
    switch (variant) {
      case ButtonVariant.outlined:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: foregroundColor ?? scheme.primary,
          border: borderColor ?? scheme.primary,
          elevation: 0,
        );
      case ButtonVariant.text:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: foregroundColor ?? scheme.primary,
          elevation: 0,
        );
      case ButtonVariant.filled:
      default:
        return _ButtonColors(
          background: backgroundColor ?? scheme.primary,
          foreground: foregroundColor ?? scheme.onPrimary,
          elevation: 2,
        );
    }
  }
}

class _ButtonSize {
  final EdgeInsetsGeometry padding;
  final Size minSize;

  _ButtonSize({
    required this.padding,
    required this.minSize,
  });
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color? border;
  final double elevation;

  _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
    required this.elevation,
  });
}