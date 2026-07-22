import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar.dart';
import 'side_menu_list.dart';

class LayoutView extends StatefulWidget {
  const LayoutView({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<LayoutView> createState() => _LayoutViewState();
}

class _LayoutViewState extends State<LayoutView> {
  String _getCurrentPage() {
    final path = widget.navigationShell.shellRouteContext.routerState.uri.path;
    final name = path.substring(1);
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: const SideMenuList(),
      body:  widget.navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.navigationShell.currentIndex < 5
            ? widget.navigationShell.currentIndex
            : 0,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  // Widget _buildSideMenu() {
  //   return SideMenuList(
  //     currentIndex: _getCurrentPage(),
  //     onTab: (name) {
  //       final push = name == RoutesNames.settings;
  //       if (push) {
  //         context.pushNamed(name);
  //       } else {
  //         context.goNamed(name);
  //       }
  //     },
  //   );
  // }
}
