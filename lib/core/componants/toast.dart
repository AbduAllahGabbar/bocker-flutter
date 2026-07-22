import 'dart:async';
import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';


enum ToastState {
  success,
  error,
  info,
  warning;

  void snackBar(
      BuildContext context,
      String message, {
        Duration? duration,
      }) => showSnackBar(context, this, message, duration: duration);

  void overlay(
      BuildContext context,
      String message, {
        Duration? duration,
      }) => showToastOverlay( context, this, message, duration: duration);
}

Color _chooseToastColor(ToastState state) {
  Color color;
  switch (state) {
    case ToastState.success:
      color = Colors.green;
      break;
    case ToastState.error:
      color = Colors.red;
      break;
    case ToastState.warning:
      color = Colors.deepOrange;
      break;
    case ToastState.info:
      color = Colors.grey;
      break;
  }

  return color;
}

//for desktop
void showToastOverlay(
    BuildContext context,
    ToastState state,
    String message,
    {
      Duration? duration,
    }) {
  final overlay = OverlayEntry(
    builder:
        (context) => PositionedDirectional(
      bottom: 20,
      end: 20,
      width:
      (message.length * 8.9) > MediaQuery.sizeOf(context).width - 40
          ? MediaQuery.sizeOf(context).width - 40
          : (message.length * 8.9),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            color: _chooseToastColor(state).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlay);
  Timer( duration?? const Duration(seconds: 5), () => overlay.remove());
}

void showSnackBar(
    BuildContext context,
    ToastState state,
    String message, {
      Duration? duration,
    }) {
  final res =MyRes.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.h),
      backgroundColor: _chooseToastColor(state),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: Colors.white,
            fontSize: 14.h
        ),
      ),
      elevation: 5,
      duration: duration ?? Duration(seconds: 4),
      width: (message.length * 10 + 10).h,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

