import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              title: const Text('A 端（被控端）'),
              onTap: () async {
                await Globals.saveRole('A');
                if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ACallScreen()));
              },
            ),
            ListTile(
              title: const Text('B 端（控制端）'),
              onTap: () async {
                await Globals.saveRole('B');
                if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const BCallScreen()));
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
    Color subText = Colors.grey;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // 图2 顶部占位 + 号码显示
            Expanded(
              flex: 1,
              child: Center(
                child: Text(_input.isEmpty ? "" : _input, style: TextStyle(fontSize: 40, color: text, fontWeight: FontWeight.w300)),
              ),
            ),
            
            // 3x4 按键区
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRow(['1','2','3'], keyBg, text, subText),
                    _buildRow(['4','5','6'], keyBg, text, subText),
                    _buildRow(['7','8','9'], keyBg, text, subText),
                    _buildRow(['*','0','#'], keyBg, text, subText),
                  ],
                ),
              ),
            ),
            
            // 底部呼叫键 + 删除键 (图2样式)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左边空出 70 宽度
                  const SizedBox(width: 70),
                  // 绿色拨号键
                  GestureDetector(
                    onTap: () {
                      if (_input.isNotEmpty) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ACallScreen()));
                      }
                    },
                    child: Container(
                      width: 75, height: 75,
                      decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                      child: const Icon(Icons.call, color: Colors.white, size: 32),
                    ),
                  ),
                  // 右侧删除键
                  SizedBox(
                    width: 70,
                    child: _input.isNotEmpty 
                        ? GestureDetector(
                            onTap: () => setState(() { _input = _input.substring(0, _input.length - 1); }),
                            child: Icon(Icons.backspace_outlined, color: text, size: 28),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
            
            // 底部导航栏 (图2、图3、图5、图6)
            _buildBottomNavBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.star, '个人收藏', false),
          _navItem(Icons.access_time, '最近通话', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RecordsScreen()))),
          _navItem(Icons.person, '通讯录', false),
          _navItem(Icons.dialpad, '拨号键盘', true),
          _navItem(Icons.voicemail, '语音信箱', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF0A84FF) : Colors.grey, size: 26),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF0A84FF) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys, Color bg, Color text, Color subText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) {
        String letter = '';
        if (k == '2') letter = 'ABC';
        if (k == '3') letter = 'DEF';
        if (k == '4') letter = 'GHI';
        if (k == '5') letter = 'JKL';
        if (k == '6') letter = 'MNO';
        if (k == '7') letter = 'PQRS';
        if (k == '8') letter = 'TUV';
        if (k == '9') letter = 'WXYZ';
        if (k == '0') letter = '+';

        return GestureDetector(
          onTap: () => _onPress(k),
          child: Container(
            width: 75, height: 75,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(k, style: TextStyle(fontSize: 32, color: text, fontWeight: FontWeight.w400)),
                if (letter.isNotEmpty)
                  Text(letter, style: TextStyle(fontSize: 9, color: subText, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}