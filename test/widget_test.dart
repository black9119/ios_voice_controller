// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ios_voice_controller/main.dart';

void main() {
  testWidgets('App launch test', (WidgetTester tester) async {
    // 这里替换成你main.dart里根App的类名，默认是MyApp
    await tester.pumpWidget(const MyApp());

    // 删掉原来计数器的断言，这个项目没有计数器
    expect(find.byType(MyApp), findsOneWidget);
  });
}
