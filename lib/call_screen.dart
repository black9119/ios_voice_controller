import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'zego_service.dart';
import 'audio_manager.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final ZegoService _zegoService = ZegoService();
  final AudioManager _audioManager = AudioManager();

  String _role = 'A';
  String _status = '正在初始化...';

  @override
  void initState() {
    super.initState();
    _loadRoleAndStart();
  }

  Future<void> _loadRoleAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('device_role') ?? 'A';

    _zegoService.initZego();
    // 统一使用Zego IM接收指令，移除WebSocket服务
    _zegoService.onCommandReceived = (cmd) {
      if (cmd == 'busy') _audioManager.playSound('busy');
      if (cmd == 'empty') _audioManager.playSound('empty');
      if (cmd == 'stop') _audioManager.stop();
    };

    setState(() {
      _status = _role == 'A' ? 'A端，等待通话指令' : 'B端，控制端已就绪';
    });
  }

  // B端发送指令，调用Zego广播指令，删掉WebSocket
  Future<void> _sendCommandToA(String cmd) async {
    try {
      await _zegoService.sendControlCommand(cmd);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('指令已下发: $cmd')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发送失败')));
      }
    }
  }

  @override
  void dispose() {
    _audioManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_role == 'A' ? 'A 端 - 被控' : 'B 端 - 控制')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue[100],
            padding: const EdgeInsets.all(12),
            child: Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ZEGO 语音通话已激活', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  if (_role == 'B') ...[
                    const Text('指令控制面板', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildCmdBtn('播放忙音', 'busy'),
                    _buildCmdBtn('播放空号', 'empty'),
                    _buildCmdBtn('停止播放', 'stop'),
                    const Divider(),
                    const Text('变声面板', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _voiceBtn('正常', 0),
                        _voiceBtn('机器人', 1),
                        _voiceBtn('萝莉', 2),
                        _voiceBtn('大叔', 3),
                      ],
                    )
                  ] else ...[
                    ElevatedButton(
                      onPressed: () => _audioManager.stop(),
                      child: const Text('手动停止提示音'),
                    )
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCmdBtn(String text, String cmd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () => _sendCommandToA(cmd),
          child: Text(text),
        ),
      ),
    );
  }

  Widget _voiceBtn(String text, int preset) {
    return ElevatedButton(
      onPressed: () => _zegoService.setVoicePreset(preset),
      child: Text(text),
    );
  }
}
