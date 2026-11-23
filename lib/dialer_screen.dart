import 'package:flutter/material.dart';
import 'globals.dart';
import 'a_call_screen.dart';
import 'b_call_screen.dart';
import 'records_screen.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});
  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _input = '';
  final TextEditingController _searchController = TextEditingController();

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
              title: const Text('设为 A 端（被叫）'),
              onTap: () async {
                await Globals.saveRole('A');
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ACallScreen()));
              },
            ),
            ListTile(
              title: const Text('设为 B 端（主叫）'),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_input.isEmpty ? " " : _input, style: TextStyle(fontSize: 40, color: text, fontWeight: FontWeight.w300)),
                    const SizedBox(height: 10),
                    if (_input.isNotEmpty)
                      Text('正在呼叫...', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
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
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 70),
                  GestureDetector(
                    onTap: () {
                      if (_input.isNotEmpty) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ACallScreen()));
                      }
                    },
                    child: Container(
                      width: 70, height: 70,
                      decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                      child: const Icon(Icons.call, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 70),
                ],
              ),
            ),
            // 底部导航 (图3要求保留的4个按钮)
            _buildBottomNavBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.star_border, '个人收藏', () {}),
          _navItem(Icons.access_time, '最近通话', () { Navigator.push(context, MaterialPageRoute(builder: (c) => const RecordsScreen())); }),
          _navItem(Icons.person_outline, '通讯录', () {}),
          _navItem(Icons.dialpad, '拨号键盘', () {}),
          _navItem(Icons.voicemail, '语音信箱', () {}),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
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
          child: Center(child: Text(k, style: TextStyle(fontSize: 32, color: text, fontWeight: FontWeight.w300))),
        ),
      )).toList(),
    );
  }
}
