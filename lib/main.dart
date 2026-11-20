import 'package:flutter/material.dart';
import 'globals.dart';
import 'dialer_screen.dart';
import 'a_call_screen.dart';
import 'b_call_screen.dart';

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
      title: '语音控制',
      theme: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
      darkTheme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      themeMode: ThemeMode.system,
      home: const RoleDispatcher(),
    );
  }
}

class RoleDispatcher extends StatelessWidget {
  const RoleDispatcher({super.key});

  @override
  Widget build(BuildContext context) {
    if (Globals.currentRole == 'A') {
      return const ACallScreen();
    } else if (Globals.currentRole == 'B') {
      return const BCallScreen();
    } else {
      return const DialerScreen();
    }
  }
}