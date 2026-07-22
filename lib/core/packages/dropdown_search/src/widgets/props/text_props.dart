import 'package:flutter/material.dart';

class TextProps {
  final TextStyle? style;

  final TextAlign? textAlign;

  final bool? softWrap;

  final TextOverflow? overflow;

  final int? maxLines;

  final TextWidthBasis? textWidthBasis;

  const TextProps({
    this.style,
    this.textAlign,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.textWidthBasis = TextWidthBasis.parent,
  });
}
