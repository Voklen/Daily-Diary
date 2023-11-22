import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/filenames.dart';
import 'package:daily_diary/backend_classes/path.dart';

import 'package:toml/toml.dart';

class DiaryStorage {
  DiaryStorage(this.path);

  final SavePath path;
  DateTime date = DateTime.now();

  String get filename => Filename.dateToFilename(date);

  Future<MyFile> get storageFile => path.getChild(filename);

  Future<String> readFile() async {
    return (await storageFile).readAsString();
  }

  Future<void> writeFile(String text) async {
    return (await storageFile).writeFile(text);
  }

  void recalculateDate() {
    date = DateTime.now();
  }
}

class SettingsStorage {
  SettingsStorage(this.path);

  final SavePath path;
  late var settingsMap = _getMap();

  Future<Map<String, dynamic>> _getMap() async {
    try {
      TomlDocument file = await _document;
      return file.toMap();
    } on FileSystemException {
      return {};
    }
  }

  String get _file {
    return '${path.path}/config.toml';
  }

  Future<TomlDocument> get _document async {
    if (path.isScopedStorage) {
      String content = await path.getScopedFile('config.toml');
      return TomlDocument.parse(content);
    }
    return TomlDocument.load(_file);
  }

  Future<dynamic> _getFromFile(String key) async {
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
    final dynamic hex = await _getFromFile('color_scheme');
    if (hex is! String) return null;
    return HexColor.fromHex(hex);
  }

  Future<void> setColorScheme(Color color) async {
    String hex = color.toHex();
    await _writeToFile('color_scheme', hex);
  }

  Future<bool?> getCheckSpelling() async {
    final checkSpelling = await _getFromFile('check_spelling');
    return checkSpelling is bool ? checkSpelling : null;
  }

  Future<void> setCheckSpelling(bool checkSpelling) async {
    await _writeToFile('check_spelling', checkSpelling);
  }

  Future<String?> getDateFormat() async {
    final dateFormat = await _getFromFile('date_format');
    return dateFormat is String ? dateFormat : null;
  }

  Future<void> setDateFormat(String dateFormat) async {
    await _writeToFile('date_format', dateFormat);
  }

  Future<void> _writeToFile(String key, dynamic value) async {
    var map = await settingsMap;
    map[key] = value;
    settingsMap = Future(() => map);

    //TODO
    String asToml = TomlDocument.fromMap(map).toString();

    if (path.isScopedStorage) {
      await path.writeScopedFile('config.toml', asToml);
    } else {
      await File(_file).writeAsString(asToml);
    }
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  /// Returns null if bad string format
  static Color? fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));

    int? asInt = int.tryParse(buffer.toString(), radix: 16);
    if (asInt == null) return null;
    return Color(asInt);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class PreviousEntriesStorage {
  const PreviousEntriesStorage(this.path);

  final SavePath path;

  Future<List<EntryFile>> getFiles() async {
    Stream<MyFile> files = await path.list();
    Stream<EntryFile?> asEntryFiles = files.map(EntryFile.create);
    Stream<EntryFile> withoutNull = asEntryFiles.where((s) => s != null).cast();
    List<EntryFile> asList = await withoutNull.toList();
    asList.sort((b, a) => a.compareTo(b));
    return asList;
  }
}
