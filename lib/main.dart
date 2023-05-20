import 'package:flutter/material.dart';

import 'package:daily_diary/path.dart';
import 'package:daily_diary/settings_notifier.dart';
import 'package:daily_diary/storage.dart';
import 'package:daily_diary/themes.dart';
import 'package:daily_diary/screens/home.dart';

import 'package:shared_storage/saf.dart';

// This will be removed when widgets can react to spell check changes
bool? startupCheckSpelling;

SavePath? savePath;
SavePath? startupSavePath;

main() async {
  savePath = await getPath();
  startupSavePath = savePath;
  // Color and theme are loaded before the app starts
  // This is to make it not jarringly switch theme/color while loading
  // Other settings are loaded it the initState of the home page
  App.settingsNotifier.setColorSchemeFromFile();
  App.settingsNotifier.setThemeFromFile();
  // This will be moved to _loadSettings when spellCheckHasChanged is removed
  await App.settingsNotifier.setCheckSpellingFromFile();
  startupCheckSpelling = App.settingsNotifier.value.checkSpelling;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static final SettingsNotifier settingsNotifier = SettingsNotifier(savePath!);

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
          home: HomePage(
            storage: DiaryStorage(savePath!),
          ),
        );
      },
    );
  }
}
