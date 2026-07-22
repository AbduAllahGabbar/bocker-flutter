import '../../base_dropdown_search.dart';
import 'scroll_props.dart';
import 'wrap_props.dart';
import 'package:flutter/material.dart';

import 'chip_props.dart';

typedef SuggestionsBuilder<T> = Widget Function(List<T> suggestedItems);

///[items] are the original item on which we want extract suggestions
typedef SuggestedItems<T> = List<T> Function(List<T> items);

class SuggestionsProps<T> {
  final SuggestedItemProps<T>? itemProps;
  final SuggestionsBuilder<T>? builder;
  final bool showSuggestions;

  ///suggested items list
  final SuggestedItems<T>? items;

  const SuggestionsProps({
    this.itemProps,
    this.builder,
    this.showSuggestions = false,
    this.items,
  }) : assert(
          builder == null || itemProps == null,
          'Cannot provide both a builder and a itemProps. '
          'builder is overriding the hole suggestion widget',
        );
}

class SuggestedItemProps<T> {
  final ContainerBuilder? containerBuilder;
  final ScrollProps scrollProps;
  final ChipProps? chipProps;
  final WrapProps wrapProps;

  const SuggestedItemProps({
    this.containerBuilder,
    this.chipProps,
    this.wrapProps = const WrapProps(runSpacing: 4, spacing: 4),
    this.scrollProps = const ScrollProps(scrollDirection: Axis.horizontal),
  });
}
