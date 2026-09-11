import 'package:flutter/material.dart';

import 'scribe_drawer.dart';

/// The `ShellRoute` chrome for the four top-level destinations: a Scaffold
/// that owns the navigation drawer, with the routed screen as its body.
///
/// Screens inside the shell are Scaffolds of their own (app bar, FAB,
/// hide-on-scroll all stay per-screen); they open the drawer through
/// [ScribeShell.openDrawer] rather than `Scaffold.of`, which would find
/// their own drawer-less Scaffold first.
class ScribeShell extends StatefulWidget {
  const ScribeShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  /// Current location path, used to mark the drawer's selected pill.
  final String currentPath;
  final Widget child;

  /// Opens the shell drawer from anywhere below the shell.
  static void openDrawer(BuildContext context) {
    final shell = context.findAncestorStateOfType<_ScribeShellState>();
    assert(shell != null, 'ScribeShell.openDrawer called outside the shell');
    shell?._scaffoldKey.currentState?.openDrawer();
  }

  @override
  State<ScribeShell> createState() => _ScribeShellState();
}

class _ScribeShellState extends State<ScribeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ScribeDrawer(selectedPath: widget.currentPath),
      body: widget.child,
    );
  }
}
