import 'package:flutter/material.dart';

/// 图5 个人收藏（空态）
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Center(
          child: Text(
            '无个人收藏',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 20),
          ),
        ),
        Column(
          children: <Widget>[
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const Text(
                    '个人收藏',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    right: 18,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF0A84FF),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
