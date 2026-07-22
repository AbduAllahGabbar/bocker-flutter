import 'package:flutter/material.dart';

import '../../dropdown_search.dart';

abstract class BaseTextFieldProps {
  final TextEditingController? controller;
  final ContainerBuilder? containerBuilder;

  const BaseTextFieldProps({
    this.controller,
    this.containerBuilder,
  });
}
