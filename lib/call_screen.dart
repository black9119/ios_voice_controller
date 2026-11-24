import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'globals.dart';
import 'zego_service.dart';

class CallScreen extends StatefulWidget {
  final String dialedNumber;
  const CallScreen({super.key, required this.dialedNumber});
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ZegoService _zego = ZegoService();

  Timer? _timer;
  int _seconds = 0;

  // 状态机: 'calling' 呼出中, 'ringing' 收到邀请, 'in_call' 通话中, 'ended' 已结束
  String _callStatus = 'calling';
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _showKeypad = false;

  String _selectedVoice = '中年男';
  int _selectedEffect = 0;

  final Map<String, ZegoVoiceChangerPreset> voiceMap = {
    '老年男人': ZegoVoiceChangerPreset.OptimusPrime,
    '老年女人': ZegoVoiceChangerPreset.Ethereal,
    '中年男': ZegoVoiceChangerPreset.MenToWomen,
    '中年女': ZegoVoiceChangerPreset.WomenToMen,
    '小孩男': ZegoVoiceChangerPreset.MenToChild,
    '小孩女': ZegoVoiceChangerPreset.WomenToChild,
  };

  @override
  void initState() {
    super.initState();
    _initCallLogic();
  }

  Future<void> _initCallLogic() async {
    await _zego.loginRoom(Globals.currentRole == 'A' ? 'A_User' : 'B_User');

    _zego.onSignalReceived = (data) {
      if (data['type'] == 'invite') {
        // B 端收到 A 端的呼叫邀请
        if (Globals.currentRole == 'B') {
          setState(() {
            _callStatus = 'ringing';
          });
        }
      } else if (data['type'] == 'accept') {
        // A 端收到 B 端的接听
        if (Globals.currentRole == 'A') {
          setState(() {
            _callStatus = 'in_call';
            _startTimer();
          });
          _sendSignalRaw({'type': 'start_timer'});
        }
      } else if (data['type'] == 'start_timer') {
        // B 端收到开始计时
        if (Globals.currentRole == 'B') {
          setState(() {
            _callStatus = 'in_call';
            _startTimer();
          });
        }
      } else if (data['type'] == 'hangup') {
        _handleRemoteHangup();
      } else if (data['type'] == 'command') {
        _handleRemoteCommand(data['action']);
      }
    };

    // 如果 A 端，则主动发起邀请
    if (Globals.currentRole == 'A') {
      _sendSignalRaw({'type': 'invite', 'number': widget.dialedNumber});
    }
  }

  Future<void> _sendSignalRaw(Map<String, dynamic> data) async {
    String msg = jsonEncode(data);
    await ZegoExpressEngine.instance.sendBroadcastMessage(Globals.zegoRoomId, msg);
  }

  void _handleRemoteCommand(String action) {
    if (Globals.currentRole == 'A') {
      if (action == 'busy') {
        _audioPlayer.play(AssetSource('audio/busy.mp3'));
      } else if (action == 'empty') {
        _audioPlayer.play(AssetSource('audio/empty.mp3'));
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _saveCallRecord() async {
    if (_seconds == 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('call_history');
    List<dynamic> history = historyJson != null ? jsonDecode(historyJson) : [];

    history.insert(0, {
      'number': widget.dialedNumber,
      'time': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      'duration': _formatTime(_seconds),
    });
    await prefs.setString('call_history', jsonEncode(history));
  }

  Future<void> _hangUp() async {
    _sendSignalRaw({'type': 'hangup'});
    _handleRemoteHangup();
  }

  void _handleRemoteHangup() {
    _timer?.cancel();
    _audioPlayer.stop();
    _zego.logoutRoom();
    _saveCallRecord();

    if (Globals.currentRole == 'A') {
      _audioPlayer.play(AssetSource('audio/busy.mp3'));
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 删除未使用变量 isDark
    Color bg = const Color(0xFF1C1C1E);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _callStatus == 'ringing' ? _buildBIncomingUI() : _buildCallingUI(),
      ),
    );
  }

  Widget _buildCallingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              _callStatus == 'calling' ? '正在呼叫...' : _formatTime(_seconds),
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(widget.dialedNumber, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w300)),
          ],
        ),

        if (Globals.currentRole == 'B' && _callStatus == 'in_call') _buildVoicePanel(),

        if (!_showKeypad)
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildActionBtn(Icons.volume_up, _isSpeakerOn ? '免提开' : '免提', () async {
                setState(() {
                  _isSpeakerOn = !_isSpeakerOn;
                });
                await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_isSpeakerOn);
              }),
              _buildActionBtn(Icons.mic_off, _isMuted ? '取消静音' : '静音', () async {
                setState(() {
                  _isMuted = !_isMuted;
                });
                await ZegoExpressEngine.instance.muteMicrophone(_isMuted);
              }),
              _buildActionBtn(Icons.dialpad, '拨号键盘', () {
                setState(() {
                  _showKeypad = true;
                });
              }),
            ],
          )
        else
          _buildNumberPad(),

        GestureDetector(
          onTap: _hangUp,
          child: Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.call_end, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBIncomingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text('收到语音邀请', style: TextStyle(color: Colors.white70, fontSize: 20)),
        Text(widget.dialedNumber, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w300)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: _hangUp,
              child: Container(
                width: 75,
                height: 75,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.call_end, color: Colors.white, size: 32),
              ),
            ),
            GestureDetector(
              onTap: () {
                _sendSignalRaw({'type': 'accept'});
                setState(() {
                  _callStatus = 'in_call';
                  _startTimer();
                });
              },
              child: Container(
                width: 75,
                height: 75,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.call, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoicePanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Text('变声与指令面板', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['老年男人', '老年女人', '中年男', '中年女', '小孩男', '小孩女'].map((v) {
              bool selected = _selectedVoice == v;
              return ChoiceChip(
                label: Text(v, style: TextStyle(color: selected ? Colors.black : Colors.white)),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    _selectedVoice = v;
                  });
                  final preset = voiceMap[v]!;
                  ZegoExpressEngine.instance.setVoiceChangerPreset(preset);
                },
              );
            }).toList(),
          ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cmdBtn('播放忙音', 'busy'),
              _cmdBtn('播放空号', 'empty'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: List.generate(4, (i) {
              return ActionChip(
                label: Text('效果${i + 1}', style: const TextStyle(color: Colors.white)),
                onPressed: () async {
                  setState(() {
                    _selectedEffect = i;
                  });
                  double savedPitch = await Globals.loadEffect(i);
                  ZegoVoiceChangerParam param = ZegoVoiceChangerParam(savedPitch);
                  await ZegoExpressEngine.instance.setVoiceChangerParam(param);
                },
              );
            }),
          ),
          TextButton.icon(
            onPressed: () async {
              await Globals.saveEffect(_selectedEffect, 1.5);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('微调已保存')));
              }
            },
            icon: const Icon(Icons.save, color: Colors.blue),
            label: const Text('保存当前微调', style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
    );
  }

  Widget _cmdBtn(String text, String cmd) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A3A3C)),
      onPressed: () => _sendSignalRaw({'type': 'command', 'action': cmd}),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['*', '0', '#']
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) => TextButton(
              onPressed: () {},
              child: Text(k, style: const TextStyle(fontSize: 32, color: Colors.white)),
            )).toList(),
          ),
        TextButton(
          onPressed: () {
            setState(() {
              _showKeypad = false;
            });
          },
          child: const Text('隐藏拨号键盘', style: TextStyle(color: Colors.white70)),
        )
      ],
    );
  }
}
