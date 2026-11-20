import 'package:flutter/material.dart';
import 'globals.dart';
import 'a_call_screen.dart';
import 'b_call_screen.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});
  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _input = '';

  void _onPress(String num) {
    setState(() { _input += num; });
    if (_input == '999999999') {
      _input = '';
      _showSettings();
    }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐藏设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('设为 A 端（被控端）'),
              onTap: () async {
                await Globals.saveRole('A');
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ACallScreen()));
              },
            ),
            ListTile(
              title: const Text('设为 B 端（控制端）'),
              onTap: () async {
                await Globals.saveRole('B');
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const BCallScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? Colors.black : Colors.white;
    Color text = isDark ? Colors.white : Colors.black;
    Color keyBg = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Text(_input, style: TextStyle(fontSize: 40, color: text, letterSpacing: 2)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _row(['1','2','3'], keyBg, text),
                    _row(['4','5','6'], keyBg, text),
                    _row(['7','8','9'], keyBg, text),
                    _row(['*','0','#'], keyBg, text),
                  ],
                ),
              ),
            ),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_input.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('呼叫逻辑待接入')));
                      }
                    },
                    child: Container(
                      width: 70, height: 70,
                      decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                      child: const Icon(Icons.call, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<String> keys, Color bg, Color text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => GestureDetector(
        onTap: () => _onPress(k),
        child: Container(
          width: 75, height: 75,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(child: Text(k, style: TextStyle(fontSize: 32, color: text))),
        ),
      )).toList(),
    );
  }
}