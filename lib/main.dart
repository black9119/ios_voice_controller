import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dialer_screen.dart';
import 'settings_screen.dart';
import 'call_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '电话',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, foregroundColor: Colors.white),
      ),
      themeMode: ThemeMode.system,
      home: const RoleDispatcherScreen(),
    );
  }
}

class RoleDispatcherScreen extends StatefulWidget {
  const RoleDispatcherScreen({super.key});
  @override
  State<RoleDispatcherScreen> createState() => _RoleDispatcherScreenState();
}

class _RoleDispatcherScreenState extends State<RoleDispatcherScreen> {
  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('device_role') ?? '';
    if (!mounted) return;
    // 无论选没选角色，默认先进拨号盘（没选的话隐藏设置里可以选）
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DialerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}