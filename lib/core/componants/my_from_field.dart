import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/utils/constants/app_constants.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.onSubmit,
    this.borderRadius,
    this.enableBorderColor,
    this.onSaved,
    this.onTap,
    this.autofillHints,
    this.textAlign,
    this.initialValue,
    this.onChanged,
    this.suffixOnPressed,
    this.validator,
    this.prefixText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.minLines,
    this.isPassword = false,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.fillColor,
    this.suffixColor,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffix,
    this.suffixWidget,
    this.iconSize=20,
    this.svgPrefix,
    this.focusNode,
    this.buildCounter,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final InputCounterWidgetBuilder? buildCounter;
  final TextInputType keyboardType;
  final Function(String value)? onSubmit;
  final Function(String value)? onChanged;
  final Function()? suffixOnPressed;
  final Function()? onTap;
  final String? Function(String? value)? validator;
  final String? hintText;
  final String? helperText;
  final String? prefixText;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffix;
  final Widget? suffixWidget;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final Color? fillColor;
  final Color? suffixColor;
  final String? svgPrefix;
  final FocusNode? focusNode;

  final String? labelText;
  final List<String>? autofillHints;
  final Function(String? value)? onSaved;
  final String? initialValue;
  final TextAlign? textAlign;
  final double? borderRadius;
  final Color? enableBorderColor;
  final double iconSize;
final EdgeInsetsGeometry? contentPadding;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      controller: controller,
      textAlign: textAlign ?? TextAlign.start,
      keyboardType: keyboardType,
      obscureText: isPassword,
      onChanged: onChanged,
      onSaved: onSaved,
      readOnly: readOnly,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      initialValue: initialValue,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmit,
        buildCounter:buildCounter,
      style: Theme.of(context)
          .textTheme
          .bodySmall!
          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant,fontSize: 14.h),
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        constraints: BoxConstraints(
          maxHeight:56.h,
        ),
        hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.h,
        ),
        prefixText: prefixText,
        errorMaxLines: 1,
        suffix: suffix,
        prefix: prefixWidget,

        prefixIcon:   (prefixIcon != null)
            ? Padding(
          padding:  EdgeInsets.symmetric(horizontal: 14.h),
              child: Icon(
                        prefixIcon,
                        size: iconSize.h,
                      ),
            )
            : null,
        suffixIcon: suffixIcon == null
            ? suffixWidget
            : IconButton(
          icon:Padding(
            padding:  EdgeInsets.symmetric(horizontal: 14.h),
            child: Icon(
              suffixIcon,
              size: iconSize.h,
            ),
          ),
          onPressed: suffixOnPressed,
        ),
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 12.h,
        ),
        errorStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 10.h,
          color: Colors.red
        ),
        contentPadding: contentPadding?? EdgeInsets.symmetric(horizontal:14.h,vertical: 14.h),
      ),
      validator: validator,
      textInputAction: textInputAction,
    );
  }
}

