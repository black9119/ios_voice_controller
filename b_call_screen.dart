import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'app_fonts.dart';
import 'glass.dart';
import 'globals.dart';
import 'pressable.dart';
import 'zego_service.dart';

/// B 端：图11 接听页（常驻等待来电）
class BCallScreen extends StatefulWidget {
  const BCallScreen({super.key});

  @override
  State<BCallScreen> createState() => _BCallScreenState();
}

class _BCallScreenState extends State<BCallScreen> {
  static const Color _panel = Color(0xFF2C2C2E);
  static const Color _chip = Color(0xFF3A3A3C);
  static const Color _chipActive = Color(0xFF46415C);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _green = Color(0xFF34C759);
  static const Color _red = Color(0xFFFF3B30);

  final ZegoService _zego = ZegoService();
  final List<String> _voiceNames = <String>[
    '老年男人',
    '老年女人',
    '中年男',
    '中年女',
    '小孩男',
    '小孩女',
  ];
  final List<String> _effectNames = <String>['效果1', '效果2', '效果3', '效果4'];

  final Map<String, ZegoVoiceChangerPreset> _voiceMap =
      <String, ZegoVoiceChangerPreset>{
    '老年男人': ZegoVoiceChangerPreset.OptimusPrime,
    '老年女人': ZegoVoiceChangerPreset.Ethereal,
    '中年男': ZegoVoiceChangerPreset.MenToWomen,
    '中年女': ZegoVoiceChangerPreset.WomenToMen,
    '小孩男': ZegoVoiceChangerPreset.MenToChild,
    '小孩女': ZegoVoiceChangerPreset.WomenToChild,
  };

  // idle 等待来电 / ringing 来电中 / in_call 通话中
  String _status = 'idle';
  String _number = '';
  String _recordId = '';
  int _seconds = 0;
  Timer? _timer;

  int _selectedVoice = 0;
  int _selectedEffect = 0;
  List<double> _pitches = <double>[1.0, 1.0, 1.0, 1.0];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _zego.onSignalReceived = _onSignal;
    await _zego.loginRoom('B_User');
    _pitches = await Globals.loadEffects();
    _selectedEffect = await Globals.loadSelectedEffect();
    if (!mounted) return;
    setState(() {});
  }

  void _onSignal(Map<String, dynamic> data) {
    final String type = (data['type'] ?? '').toString();
    if (type == 'invite') {
      if (_status != 'idle') return; // 通话中不再接新来电
      _number = (data['number'] ?? '').toString();
      _status = 'ringing';
      if (mounted) setState(() {});
      _createRecord();
    } else if (type == 'hangup' || type == 'reject') {
      if (_status == 'idle') return;
      _finishTalk();
    }
  }

  Future<void> _createRecord() async {
    _recordId = await Globals.addCallRecord(_number, direction: 'in');
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  Future<void> _accept() async {
    if (_status == 'in_call') return;
    setState(() => _status = 'in_call');
    _startTimer();
    await _zego.send(<String, dynamic>{'type': 'accept'});
    if (_recordId.isNotEmpty) {
      await Globals.updateCallRecord(_recordId, answered: true);
    }
  }

  Future<void> _hangUp() async {
    if (_status == 'idle') return;
    await _zego.send(<String, dynamic>{'type': 'hangup'});
    await _finishTalk();
  }

  Future<void> _finishTalk() async {
    _timer?.cancel();
    final int duration = _seconds;
    final bool answered = _status == 'in_call';
    _status = 'idle';
    if (mounted) setState(() {});
    if (_recordId.isNotEmpty) {
      await Globals.updateCallRecord(
        _recordId,
        duration: duration,
        answered: answered,
      );
    }
    _recordId = '';
    _number = '';
    _seconds = 0;
  }

  Future<void> _sendCommand(String action) async {
    await _zego.send(<String, dynamic>{'type': 'command', 'action': action});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action == 'busy' ? '已发送：播放忙音' : '已发送：播放空号'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _selectVoice(int index) async {
    setState(() => _selectedVoice = index);
    final ZegoVoiceChangerPreset? preset = _voiceMap[_voiceNames[index]];
    if (preset != null) {
      await ZegoExpressEngine.instance.setVoiceChangerPreset(preset);
    }
  }

  Future<void> _selectEffect(int index) async {
    setState(() => _selectedEffect = index);
    await Globals.saveSelectedEffect(index);
    await ZegoExpressEngine.instance.setVoiceChangerParam(
      ZegoVoiceChangerParam(_pitches[index]),
    );
  }

  Future<void> _openFineTune() async {
    double value = _pitches[_selectedEffect];
    final double? result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setLocal) {
            return AlertDialog(
              backgroundColor: _panel,
              title: Text(
                '微调 ${_effectNames[_selectedEffect]}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  Slider(
                    value: value,
                    min: 0.5,
                    max: 2.0,
                    divisions: 30,
                    activeColor: const Color(0xFF0A84FF),
                    onChanged: (double v) {
                      setLocal(() => value = v);
                    },
                  ),
                  const Text(
                    '音调越低越低沉，越高越尖细',
                    style: TextStyle(color: _grey, fontSize: 12),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消',
                      style: TextStyle(color: _grey, fontSize: 14)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(value),
                  child: const Text('确定',
                      style: TextStyle(color: Color(0xFF0A84FF), fontSize: 14)),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == null) return;
    _pitches[_selectedEffect] = result;
    await Globals.saveEffect(_selectedEffect, result);
    await ZegoExpressEngine.instance.setVoiceChangerParam(
      ZegoVoiceChangerParam(result),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _saveAll() async {
    await Globals.saveEffects(_pitches);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('微调已保存，长期生效')),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _zego.onSignalReceived = null;
    _zego.logoutRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CallBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 22),
              const Text(
                'B 端（控制）',
                style: TextStyle(color: Color(0x8AFFFFFF), fontSize: 14),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _number.isEmpty ? '等待来电' : _number,
                    maxLines: 1,
                    style: TextStyle(
                      color: _number.isEmpty
                          ? const Color(0xFF6E6E73)
                          : Colors.white,
                      fontFamily: AppFonts.displayFamily,
                      fontSize: 34,
                      fontWeight: FontWeight.w300,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _status == 'ringing'
                    ? '来电中...'
                    : Globals.formatDuration(_seconds),
                style: const TextStyle(
                  color: _grey,
                  fontSize: 20,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildPanel(),
                ),
              ),
              _buildCommandRow(),
              const SizedBox(height: 18),
              _buildAnswerRow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassPanel(
        tint: const Color(0x16FFFFFF),
        blur: 28,
        radius: const BorderRadius.all(Radius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            children: <Widget>[
              const Text(
                '变声与指令面板',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.generate(_voiceNames.length, (int i) {
                  return _chipBox(
                    _voiceNames[i],
                    _selectedVoice == i,
                    () => _selectVoice(i),
                  );
                }),
              ),
              const Divider(color: Color(0x33FFFFFF), height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.generate(_effectNames.length, (int i) {
                  return _chipBox(
                    _effectNames[i],
                    _selectedEffect == i,
                    () => _selectEffect(i),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _panelButton('微调', Icons.tune, _openFineTune),
                  _panelButton('保存', Icons.save_outlined, _saveAll),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipBox(String label, bool selected, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.93,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _chipActive : _chip,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              ),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panelButton(String label, IconData icon, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.93,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: const Color(0xFF0A84FF), size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _commandButton('播放忙音', () => _sendCommand('busy')),
        _commandButton('播放空号', () => _sendCommand('empty')),
      ],
    );
  }

  Widget _commandButton(String label, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: _chip,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  Widget _buildAnswerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_status != 'in_call') ...<Widget>[
          _circleButton(
            Icons.call,
            _green,
            _accept,
          ),
          const SizedBox(width: 64),
        ],
        _circleButton(
          Icons.call_end,
          _red,
          _hangUp,
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.93,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
