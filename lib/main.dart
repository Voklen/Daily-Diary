import 'package:flutter/material.dart';

import 'package:daily_diary/screens/home.dart';
import 'package:daily_diary/storage.dart';
import 'package:daily_diary/settings_notifier.dart';
import 'package:daily_diary/themes.dart';

// This will be removed when widgets can react to spell check changes
bool spellCheckHasChanged = false;

main() async {
  // Color and theme are loaded before the app starts
  // This is to make it not jarringly switch theme/color while loading
  // Other settings are loaded it the initState of the home page
  App.settingsNotifier.setTheme(await App.settings.getTheme());
  App.settingsNotifier.setColorScheme(await App.settings.getColorScheme());
  // This will be moved to _loadSettings when spellCheckHasChanged is removed
  App.settingsNotifier.setCheckSpelling(await App.settings.getCheckSpelling());
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static final settings = SettingsStorage();
  static final SettingsNotifier settingsNotifier = SettingsNotifier(Settings());

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Settings>(
      valueListenable: settingsNotifier,
      builder: (_, Settings currentSettings, __) {
        final theme = Themes(currentSettings.colorScheme);
        return MaterialApp(
          title: 'Daily Diary',
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: currentSettings.theme,
          home: const HomePage(
            storage: DiaryStorage(),
          ),
        );
      },
    );
  }
}
