import 'package:flutter/material.dart';

import 'package:daily_diary/storage.dart';

class Settings {
  ThemeMode theme = ThemeMode.system;
  double fontSize = 16;
  Color colorScheme = const Color.fromARGB(255, 152, 85, 211);
  bool checkSpelling = true;
}

class SettingsNotifier extends ValueNotifier<Settings> {
  SettingsNotifier(String savePath)
      : storage = SettingsStorage(savePath),
        super(Settings());

  final SettingsStorage storage;

  setThemeFromFile() async => setTheme(await storage.getTheme());
  setFontSizeFromFile() async => setFontSize(await storage.getFontSize());
  setColorSchemeFromFile() async =>
      setColorScheme(await storage.getColorScheme());
  setCheckSpellingFromFile() async =>
      setCheckSpelling(await storage.getCheckSpelling());

  setTheme(ThemeMode? theme) {
    if (theme == null) {
      return;
    }
    value.theme = theme;
    storage.setTheme(theme);
    notifyListeners();
  }

  setFontSize(double? fontSize) {
    if (fontSize == null) {
      return;
    }
    value.fontSize = fontSize;
    storage.setFontSize(fontSize);
    notifyListeners();
  }

  setColorScheme(Color? colorScheme) {
    if (colorScheme == null) {
      return;
    }
    value.colorScheme = colorScheme;
    storage.setColorScheme(colorScheme);
    notifyListeners();
  }

  setCheckSpelling(bool? checkSpelling) {
    if (checkSpelling == null) {
      return;
    }
    value.checkSpelling = checkSpelling;
    storage.setCheckSpelling(checkSpelling);
    notifyListeners();
  }
}
