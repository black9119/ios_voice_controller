import 'package:flutter/material.dart';
import 'globals.dart';
import 'dialer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.loadRole();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialer',
      theme: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
      darkTheme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      themeMode: ThemeMode.system,
      home: const DialerScreen(),
    );
  }
}
