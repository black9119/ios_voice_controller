import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'globals.dart';
import 'call_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});
  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  int _currentTab = 3; // 默认在拨号键盘
  String _input = '';
  List<Map<String, dynamic>> _callHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('call_history');
    if (historyJson != null) {
      setState(() {
        _callHistory = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      });
    }
  }

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
              title: const Text('设为 A 端（被叫端）'),
              onTap: () async {
                await Globals.saveRole('A');
                if (!context.mounted) return;
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('设为 B 端（主叫端）'),
              onTap: () async {
                await Globals.saveRole('B');
                if (!context.mounted) return;
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _makeCall() {
    if (_input.isEmpty) return;
    if (Globals.currentRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先输入 999999999 设置角色')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (c) => CallScreen(dialedNumber: _input)));
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
        child: IndexedStack(
          index: _currentTab,
          children: [
            _buildPlaceholderTab('个人收藏'),
            _buildCallHistoryTab(isDark),
            _buildPlaceholderTab('通讯录'),
            _buildDialerTab(text, keyBg),
            _buildPlaceholderTab('语音信箱'),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark, text),
    );
  }

  Widget _buildDialerTab(Color text, Color keyBg) {
    return Column(
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
                onTap: _makeCall,
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

  Widget _buildBottomNav(bool isDark, Color text) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.star_border, '个人收藏'),
          _navItem(1, Icons.access_time, '最近通话'),
          _navItem(2, Icons.person_outline, '通讯录'),
          _navItem(3, Icons.dialpad, '拨号键盘'),
          _navItem(4, Icons.voicemail, '语音信箱'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF0A84FF) : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF0A84FF) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(child: Text('暂无$title', style: const TextStyle(color: Colors.grey)));
  }

  Widget _buildCallHistoryTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('最近通话', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        ),
        Expanded(
          child: _callHistory.isEmpty
              ? const Center(child: Text('无通话记录', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: _callHistory.length,
                  itemBuilder: (context, i) {
                    final record = _callHistory[i];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.grey),
                      title: Text(record['number'], style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      subtitle: Text('${record['time']} | 时长: ${record['duration']}', style: const TextStyle(color: Colors.grey)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}