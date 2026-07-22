import 'package:flutter/material.dart';
import 'package:boker/core/componants/logo_widget.dart';

/// Wraps the root widget and exposes a static [restartApp] method.
/// Calling [restartApp] replaces the key on the child, forcing Flutter to
/// tear down and rebuild the entire widget tree — equivalent to a hot-restart
/// without actually killing the process.
///
/// Usage:
/// ```dart
/// // In main.dart — wrap MyApp:
/// child: RestartWidget(child: MyApp())
///
/// // Anywhere in the tree — trigger restart:
/// RestartWidget.restartApp(context);
/// ```
class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  /// Triggers a full widget-tree rebuild from the root.
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();
  bool _isRestarting = false;

  void restartApp() {
    setState(() {
      _isRestarting = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _key = UniqueKey();
          _isRestarting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestarting) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoWidget(height: 150,width: 150,),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: Color(0xFF1D3A99),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
