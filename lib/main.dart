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

class SavePath {
  // Due to the constructors only one can ever be null at any time
  const SavePath.normal(String this.path) : uri = null;
  const SavePath.android(Uri this.uri) : path = null;

  final String? path;
  final Uri? uri;

  bool get isScopedStorage => path == null;

  String get string => isScopedStorage ? uri!.toString() : path!;

  Future<String> getScopedFile(String filename) async {
    final file = await getChildFile(filename);
    final content = await file.getContentAsString();
    return content!;
  }

  void writeScopedFile(String filename, String content) async {
    final file = await getChildFile(filename);
    file.writeToFileAsString(content: content);
  }

  Future<bool> scopedExists(String filename) async {
    final scopedStorageFile = await getChildFile(filename);
    final exists = await scopedStorageFile.exists();
    return exists!;
  }

  void deleteScoped(String filename) async {
    final file = await getChildFile(filename);
    file.delete();
  }

  Future<DocumentFile> getChildFile(String filename) async {
    final file = await findFile(uri!, filename);
    if (file != null) {
      return file;
    }
    DocumentFile? createdFile =
        await createFile(uri!, mimeType: 'text/plain', displayName: filename);
    return createdFile!;
  }
}

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
