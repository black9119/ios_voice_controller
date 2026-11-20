import 'dart:async';
import 'dart:io';
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
  String _targetIp = '127.0.0.1';
  HttpServer? _server;

  @override
  void initState() {
    super.initState();
    _loadRoleAndStart();
  }

  Future<void> _loadRoleAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('device_role') ?? 'A';
    _targetIp = prefs.getString('target_ip') ?? '127.0.0.1';
    
    if (_role == 'A') {
      await _startWebSocketServer();
      _zegoService.initZego();
      _zegoService.onCommandReceived = (cmd) {
        if (cmd == 'busy') _audioManager.playSound('busy');
        if (cmd == 'empty') _audioManager.playSound('empty');
        if (cmd == 'stop') _audioManager.stop();
      };
    } else {
      _zegoService.initZego();
    }
    setState(() { _status = _role == 'A' ? '等待 B 端连接...' : '已连接到 A 端'; });
  }

  // A 端启动 WebSocket 接收 B 端指令
  Future<void> _startWebSocketServer() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      _server!.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          setState(() { _status = 'B 端已连接'; });
          socket.listen((msg) {
            final cmd = msg.toString();
            if (cmd == 'busy') _audioManager.playSound('busy');
            if (cmd == 'empty') _audioManager.playSound('empty');
            if (cmd == 'stop') _audioManager.stop();
          }, onDone: () => setState(() { _status = 'B 端断开'; }));
        }
      });
    } catch (e) {
      setState(() { _status = '服务器启动失败'; });
    }
  }

  // B 端发送指令到 A 端
  Future<void> _sendCommandToA(String cmd) async {
    try {
      final uri = Uri.parse('ws://$_targetIp:8080');
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      channel.sink.add(cmd);
      await channel.sink.close();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('指令已下发: $cmd')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发送失败，请检查 IP')));
    }
  }

  @override
  void dispose() {
    _server?.close();
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