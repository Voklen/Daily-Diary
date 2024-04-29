import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/storage.dart';

abstract class MyProvider extends ChangeNotifier {
  Future<void> setFromFile();

  Future<void> setToDefault();
}

class ThemeProvider extends MyProvider {
  ThemeProvider._create(this.storage, this.theme);

  static Future<ThemeProvider> create(SettingsStorage storage) async {
    final theme = await storage.getTheme() ?? defaultValue;
    return ThemeProvider._create(storage, theme);
  }

  final SettingsStorage storage;
  ThemeMode theme;
  static const defaultValue = ThemeMode.system;

  @override
  Future<void> setFromFile() async {
    await setTheme(await storage.getTheme());
  }

  @override
  Future<void> setToDefault() async {
    await setTheme(defaultValue);
  }

  Future<void> setTheme(ThemeMode? theme) async {
    if (theme == null) return;
    this.theme = theme;
    await storage.setTheme(theme);
    notifyListeners();
  }
}

class FontSizeProvider extends MyProvider {
  FontSizeProvider._create(this.storage, this.fontSize);

  static Future<FontSizeProvider> create(SettingsStorage storage) async {
    final fontSize = await storage.getFontSize() ?? defaultValue;
    return FontSizeProvider._create(storage, fontSize);
  }

  final SettingsStorage storage;
  double fontSize;
  static const double defaultValue = 16;

  @override
  Future<void> setFromFile() async {
    await setFontSize(await storage.getFontSize());
  }

  @override
  Future<void> setToDefault() async {
    await setFontSize(defaultValue);
  }

  Future<void> setFontSize(double? fontSize) async {
    if (fontSize == null) return;
    this.fontSize = fontSize;
    await storage.setFontSize(fontSize);
    notifyListeners();
  }
}

class ColorSchemeProvider extends MyProvider {
  ColorSchemeProvider._create(this.storage, this.colorScheme);

  static Future<ColorSchemeProvider> create(SettingsStorage storage) async {
    final colorScheme = await storage.getColorScheme() ?? defaultValue;
    return ColorSchemeProvider._create(storage, colorScheme);
  }

  final SettingsStorage storage;
  Color colorScheme;
  static const defaultValue = Color.fromARGB(255, 152, 85, 211);

  @override
  Future<void> setFromFile() async {
    await setColorScheme(await storage.getColorScheme());
  }

  @override
  Future<void> setToDefault() async {
    await setColorScheme(defaultValue);
  }

  Future<void> setColorScheme(Color? colorScheme) async {
    if (colorScheme == null) return;
    this.colorScheme = colorScheme;
    await storage.setColorScheme(colorScheme);
    notifyListeners();
  }
}

class SpellCheckingProvider extends MyProvider {
  SpellCheckingProvider._create(this.storage, this.originalValue)
      : checkSpelling = originalValue;

  static Future<SpellCheckingProvider> create(SettingsStorage storage) async {
    final checkSpelling = await storage.getCheckSpelling() ?? defaultValue;
    return SpellCheckingProvider._create(storage, checkSpelling);
  }

  final SettingsStorage storage;
  final bool originalValue;
  bool checkSpelling;
  static const defaultValue = true;

  @override
  Future<void> setFromFile() async {
    await setCheckSpelling(await storage.getCheckSpelling());
  }

  @override
  Future<void> setToDefault() async {
    await setCheckSpelling(defaultValue);
  }

  Future<void> setCheckSpelling(bool? checkSpelling) async {
    if (checkSpelling == null) return;
    this.checkSpelling = checkSpelling;
    await storage.setCheckSpelling(checkSpelling);
    notifyListeners();
  }
}

class DateFormatProvider extends MyProvider {
  DateFormatProvider._create(this.storage, this.dateFormat);

  static Future<DateFormatProvider> create(SettingsStorage storage) async {
    final dateFormat = await storage.getDateFormat() ?? defaultValue;
    return DateFormatProvider._create(storage, dateFormat);
  }

  final SettingsStorage storage;
  String dateFormat;
  static const defaultValue = '%Y-%M-%D.txt';

  @override
  Future<void> setFromFile() async {
    await setDateFormat(await storage.getDateFormat());
  }

  @override
  Future<void> setToDefault() async {
    await setDateFormat(defaultValue);
  }

  Future<void> setDateFormat(String? dateFormat) async {
    if (dateFormat == null) return;
    this.dateFormat = dateFormat;
    await storage.setDateFormat(dateFormat);
  }
}
