import 'package:flutter/material.dart';

class Settings {
  ThemeMode theme = ThemeMode.system;
  double fontSize = 16;
  Color colorScheme = const Color.fromARGB(255, 152, 85, 211);
  bool checkSpelling = true;
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

  void setCheckSpelling(bool? checkSpelling) {
    if (checkSpelling == null) {
      return;
    }
    value.checkSpelling = checkSpelling;
    notifyListeners();
  }
}
