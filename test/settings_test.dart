import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/screens/settings.dart';
import 'package:daily_diary/widgets/settings_widgets/date_format.dart';
import 'package:daily_diary/widgets/settings_widgets/font_size.dart';
import 'package:daily_diary/widgets/settings_widgets/save_path.dart';
import 'package:daily_diary/widgets/settings_widgets/spell_checking.dart';
import 'package:daily_diary/widgets/settings_widgets/theme.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'SettingsStorageMock.dart';

void main() {
  savePath = const SavePath.normal('');
  newSavePath = savePath;

  testWidgets('Theme setting', (WidgetTester tester) async {
    final themeProvider = await ThemeProvider.create(MockSettingsStorage());
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => themeProvider)],
      child: const TestApp(ThemeSetting()),
    ));
    // final provider =
    //     Provider.of<ThemeProvider>(tester.element(find.byType(ThemeSetting)));

    await tester.tap(find.text('Dark'));
    expect(themeProvider.theme, ThemeMode.dark);
    await tester.tap(find.text('System'));
    expect(themeProvider.theme, ThemeMode.system);
    await tester.tap(find.text('Light'));
    expect(themeProvider.theme, ThemeMode.light);
  });

  testWidgets('Font setting', (WidgetTester tester) async {
    final fontProvider = await FontSizeProvider.create(MockSettingsStorage());
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => fontProvider)],
      child: const TestApp(FontSetting()),
    ));

    await tester.enterText(find.byType(TextField), '30');
    expect(fontProvider.fontSize, 30);
    await tester.enterText(find.byType(TextField), '2');
    expect(fontProvider.fontSize, 2);
  });

  testWidgets('Spell check setting', (WidgetTester tester) async {
    final spellCheckingProvider =
        await SpellCheckingProvider.create(MockSettingsStorage());
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => spellCheckingProvider)],
      child: const TestApp(SpellCheckToggle()),
    ));

    expect(spellCheckingProvider.checkSpelling, true);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(spellCheckingProvider.checkSpelling, false);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(spellCheckingProvider.checkSpelling, true);
  });

  testWidgets('Settings reset button display', (WidgetTester tester) async {
    await tester.pumpWidget(await SettingsProvider.create(
      storage: MockSettingsStorage(),
      child: const TestApp(SettingsScreen()),
    ));

    await tester.drag(find.byType(ListView), const Offset(0.0, -300));
    await tester.pump();
    await tester.tap(find.text('Reset settings (individually selectable)'));
    await tester.pump();
    expect(find.byIcon(Icons.restore), findsWidgets);
    expect(
      find.text('Reset settings (individually selectable)'),
      findsNothing,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(
      find.text('Reset settings (individually selectable)'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('Change path dialogue', (WidgetTester tester) async {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(),
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    Future<bool> resultFuture =
        confirmChangingSavePath(navigatorKey.currentContext!);
    await tester.pump();
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
    expect(await resultFuture, false);

    resultFuture = confirmChangingSavePath(navigatorKey.currentContext!);
    await tester.pump();
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
    expect(await resultFuture, true);
  });
  //
  testWidgets('Date format Setting', (WidgetTester tester) async {
    final dateFormatProvider =
        await DateFormatProvider.create(MockSettingsStorage());
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => dateFormatProvider)],
      child: const TestApp(DateFormatSetting()),
    ));

    await tester.enterText(find.byType(TextFormField), '%Y-%D-%M-.md');
    await tester.pump();
    expect(find.text('Press enter to save'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.pump();
    expect(find.text('Cannot be empty'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '%Y-%M/-%D.txt');
    await tester.pump();
    expect(find.text('Invalid character: /'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '%Y-%D.txt');
    await tester.pump();
    expect(find.text('Must contain: %M'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '%Y-%M%D.txt');
    await tester.pump();
    expect(find.text('%M%D cannot be together'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '%Y%M%D.txt');
    await tester.pump();
    expect(find.text('%Y%M cannot be together'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '%Y-%M-%D.txt ');
    await tester.pump();
    expect(find.text('Cannot end in a space or a dot'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '%Y-%M-%D.txt.');
    await tester.pump();
    expect(find.text('Cannot end in a space or a dot'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField),
      DateFormatProvider.defaultValue,
    );
    await tester.pump();
    expect(find.text('Press enter to save'), findsNothing);
  });
}

class TestApp extends StatelessWidget {
  const TestApp(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
