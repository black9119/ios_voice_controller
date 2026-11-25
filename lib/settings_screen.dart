import 'package:flutter/material.dart';

import 'b_call_screen.dart';
import 'globals.dart';
import 'pressable.dart';

/// 隐藏设置页：选择设备角色（A / B）与端口，保存后长期生效
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _blue = Color(0xFF0A84FF);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _card = Color(0xFF1C1C1E);

  String _role = 'A';
  String _port = '副号';

  @override
  void initState() {
    super.initState();
    _role = Globals.currentRole == 'B' ? 'B' : 'A';
    _port = Globals.currentPort;
  }

  Future<void> _save() async {
    await Globals.saveRole(_role);
    await Globals.savePort(_port);
    if (!mounted) return;
    if (_role == 'B') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (BuildContext c) => const BCallScreen()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _blue),
        title: const Text(
          '隐藏设置',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        children: <Widget>[
          const Text(
            '设备角色',
            style: TextStyle(color: _grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _roleCard(
            'A',
            'A 端（被叫方）',
            '使用拨号页拨出号码，自动入房并邀请 B 端接听',
          ),
          const SizedBox(height: 10),
          _roleCard(
            'B',
            'B 端（控制方）',
            '常驻接听页等待来电，可接听、挂断、变声与发指令',
          ),
          const SizedBox(height: 22),
          const Text(
            '端口（长期保存）',
            style: TextStyle(color: _grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: Globals.ports.map((String port) {
              final bool selected = _port == port;
              return Pressable(
                onTap: () => setState(() => _port = port),
                pressedScale: 0.95,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF2C2C2E) : _card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? _blue : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (selected)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.check, color: _blue, size: 14),
                        ),
                      Text(
                        port,
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFFB0B0B5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 26),
          const Text(
            '提示：拨号页输入 999999999 可再次进入本页修改角色与端口；'
            '保存后无需每次设置，除非再次进入修改。',
            style: TextStyle(color: _grey, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 26),
          Pressable(
            onTap: _save,
            pressedScale: 0.97,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _role == 'B' ? '保存并进入 B 端接听页' : '保存并进入拨号页',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleCard(String role, String title, String desc) {
    final bool selected = _role == role;
    return Pressable(
      onTap: () => setState(() => _role = role),
      pressedScale: 0.97,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _blue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: _grey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: _blue, size: 22)
            else
              const Icon(Icons.circle_outlined, color: _grey, size: 22),
          ],
        ),
      ),
    );
  }
}
