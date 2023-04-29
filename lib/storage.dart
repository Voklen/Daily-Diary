import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:toml/toml.dart';

class DiaryStorage {
  DiaryStorage(this.path);

  final String path;
  DateTime date = DateTime.now();

  File get file {
    String isoDate = date.toIso8601String().substring(0, 10);
    return File('$path/$isoDate.txt');
  }

  Future<String> readFile() async {
    try {
      return await file.readAsString();
    } catch (error) {
      return '';
    }
  }

  void writeFile(String text) {
    if (text.isNotEmpty) {
      file.writeAsStringSync(text);
      return;
    }
    if (file.existsSync()) {
      file.deleteSync();
      return;
    }
  }

  void recalculateDate() {
    date = DateTime.now();
  }
}

class SettingsStorage {
  SettingsStorage(this.path);

  final String path;
  late var settingsMap = _getMap();

  Future<Map<String, dynamic>> _getMap() async {
    try {
      final file = await _document;
      return file.toMap();
    } on FileSystemException {
      return {};
    }
  }

  String get _file {
    return '$path/config.toml';
  }

  Future<TomlDocument> get _document async {
    return TomlDocument.load(_file);
  }

  Future<dynamic> _getFromFile(key) async {
    try {
      final map = await settingsMap;
      return map[key];
    } catch (error) {
      // Ignoring error because:
      // If the file/key has not been made, we just want the default
      // If the file/key is corrupt, settings can be easily set again
    }
  }

  Future<ThemeMode?> getTheme() async {
    switch (await _getFromFile('theme')) {
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

  Future<void> setTheme(ThemeMode theme) async {
    switch (theme) {
      case ThemeMode.light:
        await _writeToFile('theme', 'light');
        break;
      case ThemeMode.system:
        await _writeToFile('theme', 'system');
        break;
      case ThemeMode.dark:
        await _writeToFile('theme', 'dark');
        break;
    }
  }

  Future<double?> getFontSize() async {
    final fontSize = await _getFromFile('font_size');
    return fontSize is double ? fontSize : null;
  }

  Future<void> setFontSize(double size) async {
    await _writeToFile('font_size', size);
  }

  Future<Color?> getColorScheme() async {
    String hex = await _getFromFile('color_scheme') ?? "";
    return colorFromHex(hex);
  }

  Future<void> setColorScheme(Color color) async {
    String hex = colorToHex(color, includeHashSign: true, enableAlpha: false);
    await _writeToFile('color_scheme', hex);
  }

  Future<bool?> getCheckSpelling() async {
    final checkSpelling = await _getFromFile('check_spelling');
    return checkSpelling is bool ? checkSpelling : null;
  }

  Future<void> setCheckSpelling(bool checkSpelling) async {
    await _writeToFile('check_spelling', checkSpelling);
  }

  Future<void> _writeToFile(key, value) async {
    var map = await settingsMap;
    map[key] = value;
    settingsMap = Future(() => map);

    TomlDocument asToml = TomlDocument.fromMap(map);
    await File(_file).writeAsString(asToml.toString());
  }
}

class PreviousEntriesStorage {
  const PreviousEntriesStorage(this.path);

  final String path;

  Future<List<DateTime>> getFiles() async {
    final directory = Directory(path);
    final files = directory.list();
    final filesAsDateTime = files.map(toFilename);
    final filesWithoutNull =
        filesAsDateTime.where((s) => s != null).cast<DateTime>();
    final list = await filesWithoutNull.toList();
    return list.reversed.toList();
  }

  DateTime? toFilename(FileSystemEntity file) {
    String path = file.path;
    int filenameStart = path.lastIndexOf('/') + 1;
    int filenameEnd = path.length - 4;
    String isoDate = path.substring(filenameStart, filenameEnd);
    try {
      return DateTime.parse(isoDate);
    } on FormatException {
      // Empty strings will be filtered after this map
      return null;
    }
  }
}

class PreviousEntryStorage {
  const PreviousEntryStorage(this.filename, this.path);

  final String filename;
  final String path;

  Future<String> readFile() async {
    try {
      final file = File('$path/$filename.txt');
      final contents = await file.readAsString();
      return contents;
    } catch (error) {
      return "";
    }
  }
}
