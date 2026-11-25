import 'package:flutter/material.dart';

import 'globals.dart';

/// 图6 语音信箱（静态结构）
class VoicemailView extends StatelessWidget {
  const VoicemailView({super.key});

  static const Color _blue = Color(0xFF0A84FF);
  static const Color _grey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const Text(
                '语音信箱',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Positioned(
                left: 18,
                child: Text(
                  '编辑',
                  style: TextStyle(color: _blue, fontSize: 16),
                ),
              ),
              Positioned(
                right: 18,
                child: Text(
                  '应答语',
                  style: TextStyle(color: _blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '运营商语音信箱',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Globals.currentPort,
                      style: const TextStyle(color: _grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '呼叫',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            '其他',
            style: TextStyle(color: _grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 6),
        const Divider(color: Color(0x33FFFFFF), height: 1),
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: const <Widget>[
                Expanded(
                  child: Text(
                    '已删除的留言',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
                Icon(Icons.chevron_right, color: _grey, size: 22),
              ],
            ),
          ),
        ),
        const Divider(color: Color(0x33FFFFFF), height: 1),
      ],
    );
  }
}
