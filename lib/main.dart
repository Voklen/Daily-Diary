import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/backend_classes/storage.dart';
import 'package:daily_diary/widgets/themes.dart';
import 'package:daily_diary/screens/home.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

SavePath? savePath;
SavePath? newSavePath;

void main() async {
  SavePath thisSavePath = await getPath();
  savePath = thisSavePath;
  newSavePath = thisSavePath;

  final storage = SettingsStorage(thisSavePath);
  runApp(
    await SettingsProvider.create(
      storage: storage,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  static final preferences = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    final theme = Themes(context.watch<ColorSchemeProvider>().colorScheme);
    return MaterialApp(
      title: 'Daily Diary',
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: context.watch<ThemeProvider>().theme,
      home: HomePage(
        child: EntryEditor(
          storage: DiaryStorage(
            savePath!,
            context.watch<DateFormatProvider>().dateFormat,
          ),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class SettingsProvider extends StatelessWidget {
  const SettingsProvider._create(
      {super.key,
      required this.theme,
      required this.fontSize,
      required this.colorScheme,
      required this.spellChecking,
      required this.dateFormat,
      required this.child});

  static Future<SettingsProvider> create({
    required SettingsStorage storage,
    required Widget child,
    Key? key,
  }) async {
    final theme = await ThemeProvider.create(storage);
    final fontSize = await FontSizeProvider.create(storage);
    final colorScheme = await ColorSchemeProvider.create(storage);
    final spellChecking = await SpellCheckingProvider.create(storage);
    final dateFormat = await DateFormatProvider.create(storage);
    return SettingsProvider._create(
      key: key,
      theme: theme,
      fontSize: fontSize,
      colorScheme: colorScheme,
      spellChecking: spellChecking,
      dateFormat: dateFormat,
      child: child,
    );
  }

  final ThemeProvider theme;
  final FontSizeProvider fontSize;
  final ColorSchemeProvider colorScheme;
  final SpellCheckingProvider spellChecking;
  final DateFormatProvider dateFormat;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final providers = [
      ChangeNotifierProvider(create: (_) => theme),
      ChangeNotifierProvider(create: (_) => fontSize),
      ChangeNotifierProvider(create: (_) => colorScheme),
      ChangeNotifierProvider(create: (_) => spellChecking),
      ChangeNotifierProvider(create: (_) => dateFormat),
    ];
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
}
