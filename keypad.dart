import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'pressable.dart';

class KeypadKey {
  final String digit;
  final String letters;
  const KeypadKey(this.digit, this.letters);
}

const List<List<KeypadKey>> numberpadLayout = <List<KeypadKey>>[
  <KeypadKey>[KeypadKey('1', ''), KeypadKey('2', 'ABC'), KeypadKey('3', 'DEF')],
  <KeypadKey>[KeypadKey('4', 'GHI'), KeypadKey('5', 'JKL'), KeypadKey('6', 'MNO')],
  <KeypadKey>[
    KeypadKey('7', 'PQRS'),
    KeypadKey('8', 'TUV'),
    KeypadKey('9', 'WXYZ'),
  ],
  <KeypadKey>[KeypadKey('*', ''), KeypadKey('0', '+'), KeypadKey('#', '')],
];

/// 3x4 数字键盘（拨号页与通话中键盘共用）
class NumberKeypad extends StatelessWidget {
  final void Function(String digit) onTap;
  final Color keyColor;
  final Color digitColor;
  final Color letterColor;
  final double maxKeySize;
  final double horizontalPadding;
  final double verticalGap;

  const NumberKeypad({
    super.key,
    required this.onTap,
    this.keyColor = const Color(0xFF333333),
    this.digitColor = Colors.white,
    this.letterColor = const Color(0xFFB0B0B5),
    this.maxKeySize = 86,
    this.horizontalPadding = 18,
    this.verticalGap = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double usableWidth =
            constraints.maxWidth - horizontalPadding * 2 - 20 * 2;
        final double byWidth = usableWidth / 3;
        final double byHeight =
            (constraints.maxHeight - verticalGap * 3) / 4;
        final double size = math.max(
          46.0,
          math.min(math.min(math.min(byWidth, byHeight), maxKeySize), 110.0),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: numberpadLayout.map((List<KeypadKey> row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((KeypadKey key) {
                return _buildKey(key, size);
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildKey(KeypadKey key, double size) {
    return Pressable(
      onTap: () => onTap(key.digit),
      pressedScale: 0.93,
      child: Semantics(
        button: true,
        label: key.digit,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: keyColor, shape: BoxShape.circle),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                key.digit,
                style: TextStyle(
                  color: digitColor,
                  fontFamily: AppFonts.displayFamily,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                  letterSpacing: 0.5,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              if (key.letters.isNotEmpty) ...<Widget>[
                SizedBox(height: size * 0.04),
                Text(
                  key.letters,
                  style: TextStyle(
                    color: letterColor,
                    fontSize: math.max(8.0, size * 0.135),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
