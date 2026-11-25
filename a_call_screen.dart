import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'audio_manager.dart';
import 'app_fonts.dart';
import 'glass.dart';
import 'globals.dart';
import 'keypad.dart';
import 'pressable.dart';
import 'zego_service.dart';

/// A 端：图7 去电中 / 图10 通话中 / 图8 通话中拨号键盘
class ACallScreen extends StatefulWidget {
  final String number;
  final String recordId;

  const ACallScreen({
    super.key,
    required this.number,
    required this.recordId,
  });

  @override
  State<ACallScreen> createState() => _ACallScreenState();
}

class _ACallScreenState extends State<ACallScreen> {
  static const Color _btnBg = Color(0xFF3A3A3C);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _dim = Color(0xFF5A5A5E);
  static const Color _red = Color(0xFFFF3B30);

  final ZegoService _zego = ZegoService();

  bool _connected = false;
  bool _muted = false;
  bool _speaker = false;
  bool _showKeypad = false;
  bool _ended = false;

  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  Future<void> _startCall() async {
    _zego.onSignalReceived = _onSignal;
    _zego.onCommandReceived = _onCommand;
    await _zego.loginRoom('A_User');
    await _zego.send(<String, dynamic>{
      'type': 'invite',
      'number': widget.number,
    });
  }

  void _onSignal(Map<String, dynamic> data) {
    if (_ended) return;
    final String type = (data['type'] ?? '').toString();
    if (type == 'accept') {
      if (_connected) return;
      _connected = true;
      _startTimer();
      if (mounted) setState(() {});
      _zego.send(<String, dynamic>{'type': 'start_timer'});
      Globals.updateCallRecord(widget.recordId, answered: true);
    } else if (type == 'hangup' || type == 'reject') {
      _finish(playBusy: true);
    }
  }

  void _onCommand(String action) {
    if (action == 'busy' || action == 'empty') {
      AudioManager().playSound(action);
    } else if (action == 'stop') {
      AudioManager().stop();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _speaker = !_speaker);
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(_speaker);
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await ZegoExpressEngine.instance.muteMicrophone(_muted);
  }

  Future<void> _hangUp() async {
    await _zego.send(<String, dynamic>{'type': 'hangup'});
    // 自己挂断：直接回拨号页；对端挂断：_onSignal 里播 3 秒忙音后返回
    await _finish(playBusy: false);
  }

  Future<void> _finish({required bool playBusy}) async {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();
    await Globals.updateCallRecord(
      widget.recordId,
      duration: _seconds,
      answered: _connected,
    );
    await _zego.logoutRoom();

    if (playBusy) {
      await AudioManager().playSound('busy');
      await Future<void>.delayed(const Duration(seconds: 3));
      await AudioManager().stop();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioManager().stop();
    _zego.onSignalReceived = null;
    _zego.onCommandReceived = null;
    _zego.logoutRoom();
    super.dispose();
  }

  String get _timeText {
    return _connected
        ? Globals.formatDuration(_seconds)
        : '正在呼叫...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CallBackground(
        child: SafeArea(
          child: _showKeypad ? _buildKeypadUI() : _buildCallUI(),
        ),
      ),
    );
  }

  // ================= 图7 / 图10 =================
  Widget _buildCallUI() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: const <Widget>[
              Icon(Icons.graphic_eq, color: _dim, size: 26),
              Spacer(),
              Icon(Icons.info_outline, color: _grey, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 52),
        _buildNumberHeader(),
        const Spacer(),
        _buildActionGrid(),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildNumberHeader() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                Globals.currentPort,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _timeText,
              style: const TextStyle(
                color: _grey,
                fontSize: 18,
                fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.number,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: AppFonts.displayFamily,
                fontSize: 44,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _actionBtn(Icons.volume_up, '免提', _toggleSpeaker,
                active: _speaker),
            const SizedBox(width: 30),
            _actionBtn(Icons.videocam, 'FaceTime 通话', null),
            const SizedBox(width: 30),
            _actionBtn(Icons.mic_off, '静音', _toggleMute, active: _muted),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _actionBtn(Icons.person_add_alt_1, '添加', null),
            const SizedBox(width: 30),
            _hangUpBtn(),
            const SizedBox(width: 30),
            _actionBtn(Icons.dialpad, '拨号键盘', () {
              setState(() => _showKeypad = true);
            }),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool active = false,
  }) {
    final bool enabled = onTap != null;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.93,
      child: Column(
        children: <Widget>[
          GlassCircle(
            size: 78,
            tint: enabled ? const Color(0x24FFFFFF) : const Color(0x0FFFFFFF),
            blur: 24,
            child: Icon(
              icon,
              color: !enabled
                  ? _dim
                  : (active ? const Color(0xFF34C759) : Colors.white),
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : _dim,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hangUpBtn() {
    return Pressable(
      onTap: _hangUp,
      pressedScale: 0.93,
      child: Column(
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: _red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_end, color: Colors.white, size: 38),
          ),
          const SizedBox(height: 8),
          const Text('结束', style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  // ================= 图8 通话中拨号键盘 =================
  Widget _buildKeypadUI() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: <Widget>[
              Spacer(),
              Icon(Icons.info_outline, color: _grey, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 26),
        _buildNumberHeader(),
        const SizedBox(height: 12),
        Expanded(
          child: NumberKeypad(
            onTap: (_) {},
            keyColor: _btnBg,
            maxKeySize: 108,
            horizontalPadding: 22,
            verticalGap: 16,
          ),
        ),
        SizedBox(
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Pressable(
                onTap: _hangUp,
                pressedScale: 0.93,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: _red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 36),
                ),
              ),
              Positioned(
                right: 40,
                child: Pressable(
                  onTap: () => setState(() => _showKeypad = false),
                  child: const Text(
                    '隐藏拨号键盘',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
