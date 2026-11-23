import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';
import 'dialer_screen.dart';
import 'zego_service.dart';

class BCallScreen extends StatefulWidget {
  const BCallScreen({super.key});
  @override
  State<BCallScreen> createState() => _BCallScreenState();
}

class _BCallScreenState extends State<BCallScreen> {
  final ZegoService _zego = ZegoService();
  bool _isConnected = false;
  int _seconds = 0;
  Timer? _timer;
  int _selectedVoice = 0;
  int _selectedEffect = 0;
  bool _isAnswered = false;

  final voiceNames = ['老年男人', '老年女人', '中年男', '中年女', '小孩男', '小孩女'];
  final effectNames = ['效果1', '效果2', '效果3', '效果4'];

  @override
  void initState() {
    super.initState();
    _initB();
  }

  Future<void> _initB() async {
    await _zego.loginRoom('B_User');
    // 监听 A 端是否发来呼叫（此处假设 ZEGO 房间状态）
  }

  void _acceptCall() async {
    setState(() { _isAnswered = true; _isConnected = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) { if (mounted) setState(() { _seconds++; }); });
  }

  void _hangup() async {
    await Globals.saveCallRecord('未知号码', _seconds, false);
    _zego.logoutRoom();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DialerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('B 端（控制）', style: TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 20),
            Text('13800138000', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300)),
            const SizedBox(height: 10),
            Text(_isConnected ? _formatTime(_seconds) : '等待接听...', style: const TextStyle(color: Colors.white70, fontSize: 20)),
            
            const Spacer(),
            
            // 变声面板
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('变声与指令面板', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: List.generate(voiceNames.length, (index) {
                      return ChoiceChip(
                        label: Text(voiceNames[index], style: const TextStyle(color: Colors.white, fontSize: 12)),
                        selected: _selectedVoice == index,
                        onSelected: (val) => setState(() => _selectedVoice = index),
                      );
                    }),
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: List.generate(effectNames.length, (index) {
                      return ChoiceChip(
                        label: Text(effectNames[index], style: const TextStyle(color: Colors.white, fontSize: 12)),
                        selected: _selectedEffect == index,
                        onSelected: (val) => setState(() => _selectedEffect = index),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('微调保存成功')));
                    },
                    child: const Text('保存微调设置'),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 指令按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cmdBtn('播放忙音', 'busy'),
                _cmdBtn('播放空号', 'empty'),
              ],
            ),
            const SizedBox(height: 20),
            
            // 挂断/接听
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 绿色接听按钮
                GestureDetector(
                  onTap: _isAnswered ? null : _acceptCall,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: _isAnswered ? Colors.grey : const Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call, color: Colors.white, size: 30),
                  ),
                ),
                // 红色挂断按钮
                GestureDetector(
                  onTap: _hangup,
                  child: Container(
                    width: 70, height: 70,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _cmdBtn(String label, String cmd) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A3A3C)),
      onPressed: () {
        _zego.sendCommand(cmd);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已发送: $label')));
      },
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _zego.logoutRoom();
    super.dispose();
  }
}
