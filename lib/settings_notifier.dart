import 'package:flutter/material.dart';

import 'main.dart';

class Settings {
  ThemeMode theme = ThemeMode.system;
  double fontSize = 16;
  Color colorScheme = const Color.fromARGB(255, 152, 85, 211);
  String? savePath;

  Settings() {
    _loadSettings();
  }

  _loadSettings() async {
    App.settingsNotifier.setFontSize(await App.settings.getFontSize());
    App.settingsNotifier.setSavePath(await App.settings.getSavePath());
  }
}

class SettingsNotifier extends ValueNotifier<Settings> {
  SettingsNotifier(Settings value) : super(value);

  void setTheme(ThemeMode? theme) {
    if (theme == null) {
      return;
    }
    value.theme = theme;
    notifyListeners();
  }

  void setFontSize(double? fontSize) {
    if (fontSize == null) {
      return;
    }
    value.fontSize = fontSize;
    notifyListeners();
  }

  void setColorScheme(Color? colorScheme) {
    if (colorScheme == null) {
      return;
    }
    value.colorScheme = colorScheme;
    notifyListeners();
  }

  void setSavePath(String? path) {
    if (path == null) {
      return;
    }
    value.savePath = path;
    notifyListeners();
  }
}
