import 'package:flutter/material.dart';
import 'main.dart';

class Settings {
  ThemeMode theme = ThemeMode.system;
  double fontSize = 16;
  Color colorScheme = const Color.fromARGB(255, 152, 85, 211);
  bool checkSpelling = true;
}

class SettingsNotifier extends ValueNotifier<Settings> {
  SettingsNotifier(Settings value) : super(value);

  setTheme(ThemeMode? theme) {
    if (theme == null) {
      return;
    }
    value.theme = theme;
    App.settings.setTheme(theme);
    notifyListeners();
  }

  setFontSize(double? fontSize) {
    if (fontSize == null) {
      return;
    }
    value.fontSize = fontSize;
    App.settings.setFontSize(fontSize);
    notifyListeners();
  }

  setColorScheme(Color? colorScheme) {
    if (colorScheme == null) {
      return;
    }
    value.colorScheme = colorScheme;
    App.settings.setColorScheme(colorScheme);
    notifyListeners();
  }

  setCheckSpelling(bool? checkSpelling) {
    if (checkSpelling == null) {
      return;
    }
    value.checkSpelling = checkSpelling;
    App.settings.setCheckSpelling(checkSpelling);
    notifyListeners();
  }
}
