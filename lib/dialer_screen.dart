import 'package:flutter/material.dart';
import 'settings_screen.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});
  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _input = '';
  final Map<String, String> _letters = {
    '2': 'ABC', '3': 'DEF', '4': 'GHI', '5': 'JKL', '6': 'MNO',
    '7': 'PQRS', '8': 'TUV', '9': 'WXYZ', '0': '+'
  };

  void _onPress(String num) {
    setState(() { _input += num; });
    if (_input == '999999999') {
      _input = '';
      Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen()));
    }
  }

  void _onDelete() {
    if (_input.isNotEmpty) {
      setState(() { _input = _input.substring(0, _input.length - 1); });
    }
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
                    _buildRow(['1', '2', '3'], keyBg, text),
                    _buildRow(['4', '5', '6'], keyBg, text),
                    _buildRow(['7', '8', '9'], keyBg, text),
                    _buildRow(['*', '0', '#'], keyBg, text),
                  ],
                ),
              ),
            ),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  GestureDetector(
                    onTap: () {
                      if (_input.isNotEmpty) {
                        // 预留呼叫逻辑
                      }
                    },
                    child: Container(
                      width: 70, height: 70,
                      decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                      child: const Icon(Icons.call, color: Colors.white, size: 32),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onDelete,
                    child: Container(
                      width: 60, alignment: Alignment.center,
                      child: _input.isNotEmpty ? Icon(Icons.backspace_outlined, color: text, size: 28) : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys, Color bg, Color text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key, bg, text)).toList(),
    );
  }

  Widget _buildKey(String key, Color bg, Color text) {
    String letter = _letters[key] ?? '';
    return GestureDetector(
      onTap: () => _onPress(key),
      child: Container(
        width: 75, height: 75,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(key, style: TextStyle(fontSize: 32, color: text, fontWeight: FontWeight.w400)),
            if (letter.isNotEmpty)
              Text(letter, style: TextStyle(fontSize: 10, color: text, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}