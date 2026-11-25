import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 圆形毛玻璃按钮底（iOS 通话页按钮质感）
class GlassCircle extends StatelessWidget {
  final double size;
  final Widget child;
  final Color tint;
  final double blur;

  const GlassCircle({
    super.key,
    required this.size,
    required this.child,
    this.tint = const Color(0x21FFFFFF),
    this.blur = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          color: tint,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

/// 圆角毛玻璃面板（B 端变声面板）
class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius radius;
  final Color tint;
  final double blur;

  const GlassPanel({
    super.key,
    required this.child,
    this.radius = const BorderRadius.all(Radius.circular(14)),
    this.tint = const Color(0x14FFFFFF),
    this.blur = 26,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(color: tint, child: child),
      ),
    );
  }
}

/// 通话页深灰渐变背景（让毛玻璃有层次可模糊）
class CallBackground extends StatelessWidget {
  final Widget child;

  const CallBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF3C3C41),
            Color(0xFF2C2C30),
            Color(0xFF1C1C1E),
            Color(0xFF161618),
          ],
          stops: <double>[0.0, 0.26, 0.62, 1.0],
        ),
      ),
      child: child,
    );
  }
}
