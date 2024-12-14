import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/backend_classes/storage.dart';
import 'package:daily_diary/widgets/themes.dart';
import 'package:daily_diary/screens/home.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This will be removed when widgets can react to spell check changes
bool? startupCheckSpelling;

SavePath? savePath;
SavePath? newSavePath;

void main() async {
  await loadSettings();
  runApp(const App());
}

Future<void> loadSettings() async {
  savePath = await getPath();
  newSavePath = savePath;
  // Date format must be set so on first load it reads the correct filename
  App.settingsNotifier.setDateFormatFromFile();
  // Color and theme are loaded before the app starts
  // This is to make it not jarringly switch theme/color while loading
  // Other settings are loaded it the initState of the home page
  App.settingsNotifier.setColorSchemeFromFile();
  App.settingsNotifier.setThemeFromFile();
  // This will be moved to _loadSettings when spellCheckHasChanged is removed
  await App.settingsNotifier.setCheckSpellingFromFile();
  startupCheckSpelling = App.settingsNotifier.value.checkSpelling;
}

class App extends StatelessWidget {
  const App({super.key});

  static final settingsNotifier = SettingsNotifier(savePath!);
  static final preferences = SharedPreferences.getInstance();

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
            child: EntryEditor(
              storage: DiaryStorage(savePath!),
              settings: currentSettings,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
