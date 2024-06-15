import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSettingsStorage extends SettingsStorage {
  MockSettingsStorage() : super(const SavePath.normal(''));

  Map<String, dynamic> map = {};

  @override
  Future<ThemeMode?> getTheme() async {
    switch (map['theme']) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null;
    }
  }

  @override
  Future<void> setTheme(ThemeMode theme) async {
    switch (theme) {
      case ThemeMode.light:
        map['theme'] = 'light';
      case ThemeMode.system:
        map['theme'] = 'system';
      case ThemeMode.dark:
        map['theme'] = 'dark';
    }
  }

  @override
  Future<double?> getFontSize() async {
    final fontSize = map['font_size'];
    return fontSize is double ? fontSize : null;
  }

  @override
  Future<void> setFontSize(double size) async {
    map['font_size'] = size;
  }

  @override
  Future<Color?> getColorScheme() async {
    final dynamic hex = map['color_scheme'];
    if (hex is! String) return null;
    return HexColor.fromHex(hex);
  }

  @override
  Future<void> setColorScheme(Color color) async {
    String hex = color.toHex();
    map['color_scheme'] = hex;
  }

  @override
  Future<bool?> getCheckSpelling() async {
    final checkSpelling = map['check_spelling'];
    return checkSpelling is bool ? checkSpelling : null;
  }

  @override
  Future<void> setCheckSpelling(bool checkSpelling) async {
    map['check_spelling'] = checkSpelling;
  }

  @override
  Future<String?> getDateFormat() async {
    final dateFormat = map['date_format'];
    return dateFormat is String ? dateFormat : null;
  }

  @override
  Future<void> setDateFormat(String dateFormat) async {
    map['date_format'] = dateFormat;
  }
}
