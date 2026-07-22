import 'dart:math';
import 'package:flutter/material.dart';


extension ContextEx on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// لحساب حجم الخط باستخدام مقياس مخصص يعتمد على حجم الشاشة
  double setSp(double fontSize, {double? scaleFraction}) {
    final scaleText = min(screenWidth / 375, screenHeight / 812);
    final scaledFont = fontSize * scaleText;
    return scaledFont * (scaleFraction ?? 1.0);
  }

  /// لحساب حجم خط مرن بين min/max
  double resFont({
    double minSize = 12,
    double maxSize = 20,
    double scaleFactor = 0.05,
  }) {
    final calculatedSize = screenWidth * scaleFactor;
    return max(minSize, min(calculatedSize, maxSize));
  }


}
