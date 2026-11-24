import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'globals.dart';
import 'dialer_screen.dart';
import 'zego_service.dart';
import 'package:audioplayers/audioplayers.dart';

class ACallScreen extends StatefulWidget {
  const ACallScreen({super.key});
  @override
  State<ACallScreen> createState() => _ACallScreenState();
}

class _ACallScreenState extends State<ACallScreen> {
  final ZegoService _zego = ZegoService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _showKeypad = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    await _zego.loginRoom('A_User');
    _zego.onCommandReceived = (command) {
      if (command == 'busy') _audioPlayer.play(AssetSource('audio/busy.mp3'));
      else if (command == 'empty') _audioPlayer.play(AssetSource('audio/empty.mp3'));
      else if (command == 'stop') _audioPlayer.stop();
    };
    _timer = Timer.periodic(const Duration(seconds: 1), (t) { if (mounted) setState(() { _seconds++; }); });
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
          children: [
            const SizedBox(height: 20),
            Text(_formatTime(_seconds), style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 10),
            const Text('10086', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w300)),
            const Spacer(),
            if (_showKeypad) _buildKeypad(),
            if (!_showKeypad) _buildControls(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _row(['1','2','3']),
          _row(['4','5','6']),
          _row(['7','8','9']),
          _row(['*','0','#']),
        ],
      ),
    );
  }

  Widget _row(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => GestureDetector(
        onTap: () {},
        child: Container(
          width: 70, height: 70,
          decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle),
          child: Center(child: Text(k, style: const TextStyle(fontSize: 30, color: Colors.white))),
        ),
      )).toList(),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionBtn(Icons.volume_up, _isSpeaker ? '免提中' : '免提', () async {
                setState(() => _isSpeaker = !_isSpeaker);
                await ZegoExpressEngine.instance.enableSpeaker(_isSpeaker);
              }),
              _actionBtn(Icons.mic_off, _isMuted ? '静音中' : '静音', () async {
                setState(() => _isMuted = !_isMuted);
                await ZegoExpressEngine.instance.muteMicrophone(_isMuted);
              }),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              await Globals.saveCallRecord('10086', _seconds, _seconds == 0);
              _zego.logoutRoom();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DialerScreen()));
            },
            child: Container(
              width: 70, height: 70,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.call_end, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _showKeypad = !_showKeypad),
            child: Text(_showKeypad ? '隐藏拨号键盘' : '拨号键盘', style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}