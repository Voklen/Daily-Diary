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

  Future<void> setThemeFromFile() async {
    await setTheme(await storage.getTheme());
  }

  Future<void> setFontSizeFromFile() async {
    await setFontSize(await storage.getFontSize());
  }

  Future<void> setColorSchemeFromFile() async {
    await setColorScheme(await storage.getColorScheme());
  }

  Future<void> setCheckSpellingFromFile() async {
    await setCheckSpelling(await storage.getCheckSpelling());
  }

  Future<void> setThemeToDefault() async {
    await setTheme(Settings().theme);
  }

  Future<void> setFontSizeToDefault() async {
    await setFontSize(Settings().fontSize);
  }

  Future<void> setColorSchemeToDefault() async {
    await setColorScheme(Settings().colorScheme);
  }

  Future<void> setCheckSpellingToDefault() async {
    await setCheckSpelling(Settings().checkSpelling);
  }

  Future<void> setTheme(ThemeMode? theme) async {
    if (theme == null) {
      return;
    }
    value.theme = theme;
    storage.setTheme(theme);
    notifyListeners();
  }

  Future<void> setFontSize(double? fontSize) async {
    if (fontSize == null) {
      return;
    }
    value.fontSize = fontSize;
    await storage.setFontSize(fontSize);
    notifyListeners();
  }

  Future<void> setColorScheme(Color? colorScheme) async {
    if (colorScheme == null) {
      return;
    }
    value.colorScheme = colorScheme;
    await storage.setColorScheme(colorScheme);
    notifyListeners();
  }

  Future<void> setCheckSpelling(bool? checkSpelling) async {
    if (checkSpelling == null) {
      return Future(() => null);
    }
    value.checkSpelling = checkSpelling;
    await storage.setCheckSpelling(checkSpelling);
    notifyListeners();
  }
}
