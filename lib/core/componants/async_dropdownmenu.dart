import 'dart:async';
import 'package:flutter/material.dart';

import '../packages/dropdown_search/dropdown_search.dart';


class DropdownButtonSearch<T> extends StatelessWidget {
  const DropdownButtonSearch({
    super.key,
     this.value,
    required this.onChanged,
     this.asyncItems,
    this.label,
    this.borderRadius,
    this.enableBorderColor,
    this.isWork = true,
    this.onView,
    this.validator,
    this.onBeforeOpening,
    this.items=const [],
    this.showSearchBox = true,
    this.fit = FlexFit.loose,
    this.constraints = const BoxConstraints(maxHeight: 350),
  });
  final bool showSearchBox;
  final T? value;
  final bool isWork;
  final String? label;
  final double? borderRadius;
  final Color? enableBorderColor;
  final FutureOr<List<T>> Function()? asyncItems;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? onView;
  final String? Function(T?)? validator;
  final Future<bool> Function(T?)? onBeforeOpening;
  final FlexFit fit;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return  DropdownSearch<T>(
      // clickProps: ClickProps(
      //   onTapDown: (details) {
      //     print("dsadsadas sdas ");
      //     onTap?.call();
      //   },
      // ),
      popupProps: PopupProps.menu(
        fit: fit,
        constraints: constraints,
        showSearchBox: showSearchBox,
        searchDelay: Duration.zero,
        itemBuilder: (context, item, isDisabled, isSelected) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            alignment: AlignmentDirectional.center,
            fit: BoxFit.scaleDown,
            child: Text(
              onView?.call(item) ?? item.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        onItemsLoaded: (value) {
          // onTap?.call();
        },
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            label: const Text("Search..."),
            contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: 10, vertical: 3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
              borderSide: BorderSide(
                color: enableBorderColor ?? Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
              borderSide: BorderSide(
                width: 0.1,
                color: enableBorderColor ?? Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            filled: true,
          ),
        ),
      ),
      selectedItem: value,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          suffixIcon: null,
          suffix: null,
          suffixText: null,
          label: label==null?null: Text(label!),

        ),
      ),
      enabled: isWork,
      items: (filter, loadProps) =>   asyncItems?.call()??items,
      compareFn:(item1, item2) => item1==item2 ,
      itemAsString: onView != null ? (item) => onView!(item) ?? "no view" : null,
      onSelected: onChanged,
      validator: validator,
      onBeforePopupOpening: onBeforeOpening,
    );
  }
}
