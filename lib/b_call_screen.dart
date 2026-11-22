import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'globals.dart';
import 'zego_service.dart';
import 'dialer_screen.dart';

class BCallScreen extends StatefulWidget {
  const BCallScreen({super.key});
  @override
  State<BCallScreen> createState() => _BCallScreenState();
}

class _BCallScreenState extends State<BCallScreen> {
  final ZegoService _zego = ZegoService();
  Timer? _timer;
  int _seconds = 0;
  bool _inCall = false;
  int _selectedVoiceIndex = 0;
  int _selectedEffectIndex = 0;

  final List<String> voiceNames = ['老年男人', '老年女人', '中年男', '中年女', '小孩男', '小孩女'];
  final List<ZegoVoiceChangerPreset> voicePresetList = [
    ZegoVoiceChangerPreset.OptimusPrime,
    ZegoVoiceChangerPreset.Ethereal,
    ZegoVoiceChangerPreset.MenToWomen,
    ZegoVoiceChangerPreset.WomenToMen,
    ZegoVoiceChangerPreset.MenToChild,
    ZegoVoiceChangerPreset.WomenToChild,
  ];
  final List<String> effectNames = ['效果1', '效果2', '效果3', '效果4'];

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    await _zego.loginRoom('B_User');
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

  // ========= 修改这里，直接调用引擎发送广播 =========
  Future<void> _sendCmd(String cmd) async {
    await ZegoExpressEngine.instance.sendBroadcastMessage("voice_call_room", cmd);
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已下发指令: $cmd')));
    }
  }

  void _changeVoice(int index) {
    setState(() { _selectedVoiceIndex = index; });
    ZegoVoiceChangerPreset preset = voicePresetList[index];
    _zego.setVoicePreset(preset);
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            const Text('B 端（控制）', style: TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 20),
            const Text('13800138000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300)),
            const SizedBox(height: 10),
            Text(_inCall ? _formatTime(_seconds) : '连接中...', style: const TextStyle(color: Colors.white70, fontSize: 20)),
            
            const Spacer(),
            
            _buildVoicePanel(),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCmdBtn('播放忙音', 'busy'),
                _buildCmdBtn('播放空号', 'empty'),
                _buildCmdBtn('停止播放', 'stop'),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                await _zego.logoutRoom();
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DialerScreen()));
              },
              child: Container(
                width: 75, height: 75,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.call_end, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildVoicePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('变声与指令面板', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(voiceNames.length, (index) {
              bool selected = _selectedVoiceIndex == index;
              return ChoiceChip(
                label: Text(voiceNames[index]),
                selected: selected,
                onSelected: (val) => _changeVoice(index),
              );
            }),
          ),
          const Divider(color: Colors.white24, height: 30),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(effectNames.length, (index) {
              bool selected = _selectedEffectIndex == index;
              return ChoiceChip(
                label: Text(effectNames[index]),
                selected: selected,
                onSelected: (val) {
                  setState(() { _selectedEffectIndex = index; });
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已应用微调: ${effectNames[index]}')));
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCmdBtn(String label, String cmd) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A3A3C)),
      onPressed: () => _sendCmd(cmd),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
