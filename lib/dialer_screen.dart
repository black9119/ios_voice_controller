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
  int _currentIndex = 3; // 默认选中拨号键盘

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
    Color bgColor = isDark ? Colors.black : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color keyBg = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5EA);
    Color navBg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  _input, 
                  style: TextStyle(fontSize: 36, color: textColor, fontWeight: FontWeight.w300, letterSpacing: 1.5),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialRow(['1', '2', '3'], ['', 'ABC', 'DEF'], keyBg, textColor),
                    _buildDialRow(['4', '5', '6'], ['GHI', 'JKL', 'MNO'], keyBg, textColor),
                    _buildDialRow(['7', '8', '9'], ['PQRS', 'TUV', 'WXYZ'], keyBg, textColor),
                    _buildDialRow(['*', '0', '#'], ['', '+', ''], keyBg, textColor),
                  ],
                ),
              ),
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                ],
              ),
            ),
            _buildBottomNavBar(navBg, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDialRow(List<String> numbers, List<String> letters, Color bg, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return GestureDetector(
          onTap: () => _onPress(numbers[index]),
          child: Container(
            width: 75, height: 75,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(numbers[index], style: TextStyle(fontSize: 32, color: textColor, fontWeight: FontWeight.w400)),
                if (letters[index].isNotEmpty)
                  Text(letters[index], style: TextStyle(fontSize: 9, color: textColor, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomNavBar(Color bg, bool isDark) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.star_border, Icons.star, '个人收藏', 0),
          _navItem(Icons.access_time, Icons.access_time_filled, '最近通话', 1, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const RecordsScreen()));
          }),
          _navItem(Icons.person_outline, Icons.person, '通讯录', 2),
          _navItem(Icons.dialpad, Icons.dialpad, '拨号键盘', 3),
          _navItem(Icons.voicemail, Icons.voicemail, '语音留言', 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index, {VoidCallback? onTap}) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isActive ? activeIcon : icon, color: isActive ? const Color(0xFF0A84FF) : Colors.grey, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF0A84FF) : Colors.grey)),
        ],
      ),
    );
  }
}