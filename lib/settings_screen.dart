import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'call_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _role = '未分配';
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _role = prefs.getString('device_role') ?? '未分配';
        _ipController.text = prefs.getString('target_ip') ?? '127.0.0.1';
      });
    }
  }

  Future<void> _saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_role', role);
    if (mounted) {
      setState(() => _role = role);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已设为 $role 端')));
    }
  }

  Future<void> _saveIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('target_ip', _ipController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IP 已保存')));
    }
  }

  void _enterApp() {
    if (_role == '未分配') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先选择角色')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (c) => const CallScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐藏设置页')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('当前角色'),
            subtitle: Text(_role, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ListTile(
            title: const Text('选为 A 端（被控）'),
            trailing: _role == 'A' ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => _saveRole('A'),
          ),
          ListTile(
            title: const Text('选为 B 端（控制）'),
            trailing: _role == 'B' ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => _saveRole('B'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('A端填写: 目标 B 端的 IP 地址 (4G/局域网)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _ipController)),
                    ElevatedButton(onPressed: _saveIp, child: const Text('保存')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _enterApp,
              child: const Text('进入通话界面'),
            ),
          ),
        ],
      ),
    );
  }
}