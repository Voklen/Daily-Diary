import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/widgets/settings_widgets.dart';
import 'package:daily_diary/screens/settings.dart';

main() {
  savePath = const SavePath.normal('');
  newSavePath = savePath;

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

  testWidgets('Spell check setting', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpellCheckToggle(),
        ),
      ),
    );

    expect(App.settingsNotifier.value.checkSpelling, true);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(App.settingsNotifier.value.checkSpelling, false);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(App.settingsNotifier.value.checkSpelling, true);
  });

  testWidgets('Settings reset button display', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    await tester.tap(find.text('Select settings to reset'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.restore), findsWidgets);
    expect(find.text('Select settings to reset'), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Select settings to reset'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
  });
}
