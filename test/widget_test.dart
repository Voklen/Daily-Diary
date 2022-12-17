import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/screens/settings.dart';

void main() {
  testWidgets('Navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Daily Diary'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Daily Diary'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.list_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Previous Entries'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Daily Diary'), findsOneWidget);
  });

  testWidgets('Appbar icons', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Daily Diary'), findsOneWidget);
    expect(find.byIcon(Icons.list_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('Theme setting', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ThemeSetting(),
      ),
    );

    await tester.tap(find.text('Dark'));
    expect(App.settingsNotifier.value.theme, ThemeMode.dark);
    await tester.tap(find.text('System'));
    expect(App.settingsNotifier.value.theme, ThemeMode.system);
    await tester.tap(find.text('Light'));
    expect(App.settingsNotifier.value.theme, ThemeMode.light);
  });

  testWidgets('Font setting', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FontSetting(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '30');
    expect(App.settingsNotifier.value.fontSize, 30);
    await tester.enterText(find.byType(TextField), '2');
    expect(App.settingsNotifier.value.fontSize, 2);
  });
}
