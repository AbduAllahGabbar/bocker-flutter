import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double width;
  final double height;
  final String assetPath;
  final BoxFit fit;

  const LogoWidget({
    super.key,
    this.height = 96,
    this.width = 96,
    this.assetPath = 'assets/logo.png',
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
