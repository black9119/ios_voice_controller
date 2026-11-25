import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'a_call_screen.dart';
import 'app_fonts.dart';
import 'contacts_screen.dart';
import 'favorites_screen.dart';
import 'globals.dart';
import 'keypad.dart';
import 'pressable.dart';
import 'records_screen.dart';
import 'settings_screen.dart';
import 'voicemail_screen.dart';

/// 图2 样式的主拨号页面 + 底部五个 Tab
class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  static const Color _bg = Color(0xFF000000);
  static const Color _keyBg = Color(0xFF333333);
  static const Color _blue = Color(0xFF0A84FF);
  static const Color _grey = Color(0xFF8E8E93);

  String _input = '';
  int _tab = 3;

  @override
  void initState() {
    super.initState();
  }

  void _pressKey(String digit) {
    if (_input.length >= 20) return;
    final String next = _input + digit;
    setState(() => _input = next);

    if (next == Globals.secretCode) {
      setState(() => _input = '');
      _openSettings();
    }
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _clearAll() {
    if (_input.isEmpty) return;
    setState(() => _input = '');
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext c) => const SettingsScreen(),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _call() async {
    if (_input.isEmpty) return;
    final String number = _input;
    final String recordId =
        await Globals.addCallRecord(number, direction: 'out');
    if (!mounted) return;
    setState(() => _input = '');
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext c) =>
            ACallScreen(number: number, recordId: recordId),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: _buildTabBody()),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    switch (_tab) {
      case 0:
        return const FavoritesView();
      case 1:
        return const RecentCallsView();
      case 2:
        return const ContactsView();
      case 4:
        return const VoicemailView();
      default:
        return _buildDialerBody();
    }
  }

  // ================= 拨号页（图2） =================
  Widget _buildDialerBody() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: <Widget>[
              _buildPortTag(),
              const Spacer(),
              const SizedBox(
                height: 44,
                child: Icon(
                  Icons.supervisor_account,
                  color: _blue,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 56,
          child: Center(
            child: Pressable(
              haptic: false,
              onLongPress: _clearAll,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _input,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AppFonts.displayFamily,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 44, child: _buildMatchRow()),
        const SizedBox(height: 2),
        Expanded(
          child: NumberKeypad(
            onTap: _pressKey,
            keyColor: _keyBg,
            maxKeySize: 96,
            horizontalPadding: 16,
            verticalGap: 10,
          ),
        ),
        SizedBox(
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Pressable(
                onTap: _call,
                pressedScale: 0.95,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: _input.isEmpty
                        ? const Color(0xFF30D158)
                        : const Color(0xFF34C759),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 34),
                ),
              ),
              if (_input.isNotEmpty)
                Positioned(
                  right: 42,
                  child: Pressable(
                    onTap: _backspace,
                    child: Container(
                      width: 46,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.backspace_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortTag() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        Globals.currentPort,
        style: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 号码联想行（无通讯录数据时显示号码预览，保持图2布局）
  Widget _buildMatchRow() {
    if (_input.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFFB0B0B5), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _input,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFB0B0B5), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 底部 TabBar =================
  Widget _buildTabBar() {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        border: Border(top: BorderSide(color: Color(0x33FFFFFF), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _navItem(0, Icons.star, Icons.star_border, '个人收藏'),
          _navItem(1, Icons.access_time, Icons.access_time, '最近通话'),
          _navItem(2, Icons.person, Icons.person_outline, '通讯录'),
          _navItem(3, Icons.dialpad, Icons.dialpad, '拨号键盘'),
          _navItem(4, Icons.voicemail, Icons.voicemail, '语音信箱'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData normalIcon,
      String label) {
    final bool active = _tab == index;
    final Color color = active ? _blue : _grey;
    return Expanded(
      child: Pressable(
        onTap: () => setState(() => _tab = index),
        pressedScale: 0.92,
        child: SizedBox(
          height: 62,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(active ? activeIcon : normalIcon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
