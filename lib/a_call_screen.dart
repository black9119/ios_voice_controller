import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'globals.dart';
import 'zego_service.dart';
import 'dialer_screen.dart';

class ACallScreen extends StatefulWidget {
  const ACallScreen({super.key});
  @override
  State<ACallScreen> createState() => _ACallScreenState();
}

class _ACallScreenState extends State<ACallScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ZegoService _zego = ZegoService();
  Timer? _timer;
  int _seconds = 0;
  bool _inCall = false;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    _zego.onCommandReceived = (command) {
      if (command == 'busy') {
        _audioPlayer.play(AssetSource('audio/busy.mp3'));
      } else if (command == 'empty') {
        _audioPlayer.play(AssetSource('audio/empty.mp3'));
      } else if (command == 'stop') {
        _audioPlayer.stop();
      }
    };

    await _zego.loginRoom('A_User');
    setState(() { _inCall = true; });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() { _seconds++; });
    });
  }

  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _zego.logoutRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('A 端（被控）', style: TextStyle(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 20),
                const Icon(Icons.person, size: 80, color: Colors.white24),
                const SizedBox(height: 20),
                const Text('ZEGO 房间已连接', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300)),
                const SizedBox(height: 10),
                Text(_inCall ? _formatTime(_seconds) : '连接中...', style: const TextStyle(color: Colors.white70, fontSize: 20)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionBtn(Icons.settings_backup_restore, '重置', () async {
                  await Globals.saveRole('');
                  if (!context.mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DialerScreen()));
                }),
                const SizedBox(width: 40),
                _buildActionBtn(Icons.call_end, '挂断', () async {
                  await _zego.logoutRoom();
                  _audioPlayer.stop();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DialerScreen()));
                }, color: Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap, {Color color = const Color(0xFF333333)}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}