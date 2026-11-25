import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'b_call_screen.dart';
import 'dialer_screen.dart';
import 'globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.loadConfig();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        // 100% SF 字形：useSF=true 时用打包的 SF Pro Text，中文回退苹方
        fontFamily: AppFonts.family,
        fontFamilyFallback: AppFonts.fallback,
        // 关掉 Material 水波纹，避免破坏 iOS 观感
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF0A84FF)),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2C2C2E),
          contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      home: Globals.currentRole == 'B'
          ? const BCallScreen()
          : const DialerScreen(),
    );
  }
}
