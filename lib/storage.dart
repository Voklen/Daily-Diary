import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/path.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_storage/saf.dart';
import 'package:toml/toml.dart';

class DiaryStorage {
  DiaryStorage(this.path);

  final SavePath path;
  DateTime date = DateTime.now();

  String get filename => dateToFilename(date);

  static String dateToFilename(DateTime date) {
    String filename = App.settingsNotifier.value.dateFormat;
    filename = filename.replaceAll('%Y', _twoDigits(date.year));
    filename = filename.replaceAll('%M', _twoDigits(date.month));
    filename = filename.replaceAll('%D', _twoDigits(date.day));
    return filename;
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  File get file {
    return File('${path.path}/$filename');
  }

  Future<String> readFile() async {
    try {
      if (path.isScopedStorage) {
        return path.getScopedFile(filename);
      }
      return await file.readAsString();
    } catch (error) {
      return '';
    }
  }

  void writeFile(String text) async {
    if (path.isScopedStorage) {
      if (text.isNotEmpty) {
        path.writeScopedFile(filename, text);
        return;
      }
      if (await path.scopedExists(filename)) {
        path.deleteScoped(filename);
        return;
      }
      return;
    }

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

  Future<String?> getDateFormat() async {
    final dateFormat = await _getFromFile('date_format');
    return dateFormat is String ? dateFormat : null;
  }

  Future<void> setDateFormat(String dateFormat) async {
    await _writeToFile('date_format', dateFormat);
  }

  Future<void> _writeToFile(key, value) async {
    var map = await settingsMap;
    map[key] = value;
    settingsMap = Future(() => map);

    //TODO
    String asToml = TomlDocument.fromMap(map).toString();

    if (path.isScopedStorage) {
      DocumentFile file = await path.getChildFile('config.toml');
      await file.writeToFileAsString(content: asToml);
    } else {
      await File(_file).writeAsString(asToml);
    }
  }
}

class PreviousEntriesStorage {
  const PreviousEntriesStorage(this.path);

  final SavePath path;

  Future<List<DateTime>> getFiles() async {
    if (path.isScopedStorage) {
      return _getFilesScopedStorage(path.uri!);
    }

    final directory = Directory(path.path!);
    final files = directory.list();
    final filesAsDateTime = files.map(toFilenameFromFileEntity);
    final filesWithoutNull =
        filesAsDateTime.where((s) => s != null).cast<DateTime>();
    final list = await filesWithoutNull.toList();
    return list.reversed.toList();
  }

  Future<List<DateTime>> _getFilesScopedStorage(Uri uri) async {
    if (await canRead(uri) == true) {
      //TODO handle lack of permissions
    }
    final files = listFiles(uri, columns: [DocumentFileColumn.displayName]);
    final filesAsDateTime = files.map(toFilenameFromDocumentFile);
    final filesWithoutNull =
        filesAsDateTime.where((s) => s != null).cast<DateTime>();
    return filesWithoutNull.toList();
  }

  DateTime? toFilenameFromFileEntity(FileSystemEntity file) {
    return toFilename(file.path);
  }

  DateTime? toFilenameFromDocumentFile(DocumentFile file) {
    return toFilename(file.name!);
  }

  DateTime? toFilename(String path) {
    int filenameStart = path.lastIndexOf('/') + 1;
    String isoDate = path.substring(filenameStart);
    try {
      return parseFilename(isoDate);
    } on FormatException {
      // Empty strings will be filtered after this map
      return null;
    }
  }

  DateTime? parseFilename(String filename) {
    final RegExp regex = RegExp(r'(\d+)-(\d+)-(\d+).txt');

    // Find all matches of the pattern in the expression
    final RegExpMatch? matches = regex.firstMatch(filename);
    if (matches == null) return null;

    // The groups cannot be null because the regex has 3 groups and so all must exist
    int year = int.parse(matches.group(1)!);
    int month = int.parse(matches.group(2)!);
    int day = int.parse(matches.group(3)!);
    return DateTime(year, month, day);
  }
}

class PreviousEntryStorage {
  const PreviousEntryStorage(this.filename, this.path);

  final String filename;
  final SavePath path;

  Future<String> readFile() async {
    try {
      if (path.isScopedStorage) {
        return await _readFileAndroid();
      }
      final file = File('${path.path}/$filename');
      final contents = await file.readAsString();
      return contents;
    } catch (error) {
      return "";
    }
  }

  Future<String> _readFileAndroid() async {
    DocumentFile? child = await path.getChildFile(filename);
    String? contents = await child.getContentAsString();
    return contents!;
  }
}
