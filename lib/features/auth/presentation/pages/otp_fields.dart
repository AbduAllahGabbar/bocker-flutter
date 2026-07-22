import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/componants/my_from_field.dart';
import '../../../../core/config/language/language_manager.dart';
import '../auth_widgets.dart';

class OtpFields extends StatefulWidget {
  const OtpFields({
    super.key,
    required this.onVerify,
    required this.onResend,
    this.isLoading = false,
    this.digits = 4, this.res,
  });
  final ResHelper? res;
  final void Function(String otp) onVerify;
  final Future<bool> Function() onResend;
  final bool isLoading;
  final int digits;
  @override
  State<OtpFields> createState() => _OtpFieldsState();
}

class _OtpFieldsState extends State<OtpFields> {
  Timer? _timer;
  int _secondsRemaining = 60;

  late final List<TextEditingController> _pinControllers = List.generate(
    widget.digits,
    (_) => TextEditingController(),
  );

  late final List<FocusNode> _pinFocusNodes = List.generate(
    widget.digits,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.digits; i++) {
      _pinFocusNodes[i].addListener(() {
        if (mounted) setState(() {});
      });
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final res =widget.res??MyRes.of(context);
    return Column(
      children: [
        // Title
        Text(
          'Enter the 6-digit code'.tran,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
            fontSize: 24.h
          ),
          textAlign: TextAlign.center,
        ),
         SizedBox(height: 40.h),

        // 6-digit PIN Input Fields
        Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            widget.digits,
            (index) => _buildPinField(index,res),
          ),
        ),
         SizedBox(height: 24.h),

        // Resend Code and Timer
        Align(
          alignment: Alignment.centerLeft,
          child: _secondsRemaining > 0
              ? Text(
                  "${'Resend code'.tran} (00:${_secondsRemaining.toString().padLeft(2, '0')})",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16.h
                  ),
                )
              : TextButton(
                  onPressed: _handleResendOtp,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Resend code'.tran,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.h
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 48),

        // Submit / Verify Button
        Builder(
          builder: (context) {
            final otp = _pinControllers.map((c) => c.text).join();
            final isOtpComplete = otp.length == widget.digits;

            return AuthButton(
              res:res,
              text: 'Verify'.tran,
              onPressed: isOtpComplete ? _verifyOtp : null,
              isLoading: widget.isLoading,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPinField(int index,ResHelper res) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Flexible(
      child: Container(
        margin:  EdgeInsets.symmetric(horizontal: 4.h),
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _pinFocusNodes[index].hasFocus
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: 1.5.h,
          ),
        ),
        child: MyTextFormField(
          controller: _pinControllers[index],
          focusNode: _pinFocusNodes[index],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(widget.digits),
          ],
          onChanged: (value) {
            if (value.length >= widget.digits) {
              final digits = value
                  .trim()
                  .split('')
                  .where((char) => RegExp(r'[0-9]').hasMatch(char))
                  .take(widget.digits)
                  .toList();
              for (int i = 0; i < widget.digits; i++) {
                if (i < digits.length) {
                  _pinControllers[i].text = digits[i];
                } else {
                  _pinControllers[i].clear();
                }
              }
              setState(() {});
              _pinFocusNodes[widget.digits - 1].requestFocus();
              if (digits.length == widget.digits) {
                _verifyOtp();
              }
              return;
            }

            if (value.length > 1) {
              _pinControllers[index].text = value.substring(value.length - 1);
              _pinControllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _pinControllers[index].text.length),
              );
              if (index < widget.digits - 1) {
                _pinFocusNodes[index + 1].requestFocus();
              }
              setState(() {});
              return;
            }

            if (value.isNotEmpty) {
              if (index < widget.digits - 1) {
                _pinFocusNodes[index + 1].requestFocus();
              } else {
                _pinFocusNodes[index].unfocus();
                _verifyOtp();
              }
            } else {
              if (index > 0) {
                _pinFocusNodes[index - 1].requestFocus();
              }
            }
            setState(() {});
          },
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
        ),
      ),
    );
  }

  void _verifyOtp() {
    final otp = _pinControllers.map((c) => c.text).join();
    if (otp.length == widget.digits) {
      widget.onVerify(otp);
    }
  }

  Future<void> _handleResendOtp() async {
    final success = await widget.onResend();
    if (success) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }
}
