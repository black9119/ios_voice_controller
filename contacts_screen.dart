import 'package:flutter/material.dart';

import 'app_fonts.dart';
/// 图3 通讯录（无数据，仅保留结构）
class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  static const Color _blue = Color(0xFF0A84FF);
  static const Color _grey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    const List<String> letters = <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Icon(Icons.chevron_left, color: _blue, size: 20),
                  Text('列表', style: TextStyle(color: _blue, fontSize: 16)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.add, color: _blue, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'iPhone',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFonts.displayFamily,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const <Widget>[
                Icon(Icons.search, color: _grey, size: 20),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '搜索',
                    style: TextStyle(color: _grey, fontSize: 15),
                  ),
                ),
                Icon(Icons.mic_none, color: _grey, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF3A3A3C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFB0B0B5),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    '我的名片',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '我的名片',
                    style: TextStyle(color: _grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Divider(color: Color(0x33FFFFFF), height: 1),
        Expanded(
          child: Row(
            children: <Widget>[
              const Expanded(
                child: Center(
                  child: Text(
                    '暂无联系人',
                    style: TextStyle(color: _grey, fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: letters
                      .map(
                        (String letter) => Text(
                          letter,
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
