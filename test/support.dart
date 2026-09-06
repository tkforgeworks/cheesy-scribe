import 'package:cheesy_scribe/app/theme/scribe_theme.dart';
import 'package:flutter/material.dart';

/// Wraps [child] in a themed MaterialApp + Scaffold for widget tests.
Widget wrap(Widget child, {bool dark = false}) => MaterialApp(
  theme: ScribeTheme.light(),
  darkTheme: ScribeTheme.dark(),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  home: Scaffold(body: Center(child: child)),
);
