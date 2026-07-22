import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MyTabBarWidget extends StatefulWidget {
  const MyTabBarWidget({
    super.key,
    this.onTap,
    required this.tabs,
    this.initialIndex = 0,
    this.selectedIndex,
    this.labelStyle,
    this.dividerHeight,
    this.indicatorWeight = 2,
    this.indicator,
    this.indicatorSize,
    this.labelColor,
    this.unselectedLabelColor,
    this.padding,
    this.labelPadding,
  });

  final void Function(int index)? onTap;
  final List<Tab> tabs;
  final int initialIndex;
  final int? selectedIndex;
  final TextStyle? labelStyle;
  final double? dividerHeight;
  final double indicatorWeight;
  final Decoration? indicator;
  final TabBarIndicatorSize? indicatorSize;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? labelPadding;

  @override
  State<MyTabBarWidget> createState() => _MyTabBarWidgetState();
}

class _MyTabBarWidgetState extends State<MyTabBarWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool showScroll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.selectedIndex ?? widget.initialIndex,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant MyTabBarWidget oldWidget) {
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabController = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: widget.selectedIndex ?? widget.initialIndex,
        animationDuration: const Duration(milliseconds: 300),
      );
    }
    if (widget.selectedIndex != oldWidget.selectedIndex && widget.selectedIndex != null) {
      _tabController.animateTo(widget.selectedIndex!);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: _tabController.length,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double totalTabWidth = _tabController.length * 120;
          showScroll = totalTabWidth > constraints.maxWidth;
          Widget tabBarWidget = TabBar(
            isScrollable: true,
            onTap: widget.onTap,
            dividerHeight: widget.dividerHeight,
            indicatorWeight: widget.indicatorWeight,
            controller: _tabController,
            tabAlignment: TabAlignment.start,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            indicatorColor: widget.selectedIndex == null ? Colors.transparent : (widget.indicator != null ? Colors.transparent : theme.primaryColor),
            indicator: widget.selectedIndex == null ? const BoxDecoration(color: Colors.transparent) : widget.indicator,
            indicatorSize: widget.indicatorSize,
            labelColor: widget.labelColor ?? theme.textTheme.labelMedium?.color,
            unselectedLabelColor: widget.unselectedLabelColor ?? theme.textTheme.labelMedium?.color,
            labelStyle: widget.labelStyle ?? theme.textTheme.labelMedium,
            labelPadding: widget.labelPadding,
            tabs: widget.tabs,
          );

          if (showScroll) {
            // إذا كان هناك Overflow، فعّل التمرير بالماوس
            return Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _scrollController.jumpTo(
                    _scrollController.offset + event.scrollDelta.dy,
                  );
                }
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: tabBarWidget,
              ),
            );
          } else {
            return tabBarWidget;
          }
        },
      ),
    );
  }
}
