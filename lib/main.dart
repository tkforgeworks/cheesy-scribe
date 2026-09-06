import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Phone-portrait UI only (CHEESE-1 §3 C); the manifest also pins it.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ScribeApp());
}

/// Root widget. Theme, routing and the drawer shell arrive with CHEESE-17 and
/// CHEESE-19; until then this is a bare Material app that proves the scaffold.
class ScribeApp extends StatelessWidget {
  const ScribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cheesy Scribe',
      home: Scaffold(body: Center(child: Text('Cheesy Scribe'))),
    );
  }
}
