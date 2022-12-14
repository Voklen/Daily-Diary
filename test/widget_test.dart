import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/screens/settings.dart';

void main() {
  testWidgets('Appbar icons smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Daily Diary'), findsOneWidget);
    expect(find.byIcon(Icons.list_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('Settings theme buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SettingsScreen(),
    ));

    await tester.tap(find.text('Dark'));
    await tester.pump();
    await tester.tap(find.text('System'));
    await tester.pump();
    await tester.tap(find.text('Light'));
    await tester.pump();
  });
}
