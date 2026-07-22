import 'package:flutter/material.dart';

import '../../dropdown_search.dart';

class DropdownSuffixProps {
  final ClearButtonProps? clearButtonProps;
  final DropdownButtonProps? dropdownButtonProps;
  final TextDirection? direction;

  const DropdownSuffixProps({
    this.clearButtonProps,
    this.dropdownButtonProps,
    this.direction,
  });
}
