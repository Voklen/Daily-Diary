import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/filenames.dart';
import 'package:daily_diary/backend_classes/path.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_storage/saf.dart';
import 'package:toml/toml.dart';

class DiaryStorage {
  DiaryStorage(this.path);

  final SavePath path;
  DateTime date = DateTime.now();

  String get filename => Filename.dateToFilename(date);

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
    Stream<DateTime> datesStream;
    if (path.isScopedStorage) {
      datesStream = await _getFilesScopedStorage();
    } else {
      datesStream = _getFilesNormal();
    }
    List<DateTime> datesList = await datesStream.toList();
    datesList.sort((b, a) => a.compareTo(b));
    return datesList;
  }

  Stream<DateTime> _getFilesNormal() {
    final directory = Directory(path.path!);
    final files = directory.list();
    final filesAsDateTime = files.map(toFilenameFromFileEntity);
    final filesWithoutNull = filesAsDateTime.where((s) => s != null);
    return filesWithoutNull.cast<DateTime>();
  }

  Future<Stream<DateTime>> _getFilesScopedStorage() async {
    Uri uri = path.uri!;
    if (await canRead(uri) == true) {
      //TODO handle lack of permissions
    }
    final files = listFiles(uri, columns: [DocumentFileColumn.displayName]);
    final filesAsDateTime = files.map(toFilenameFromDocumentFile);
    final filesWithoutNull = filesAsDateTime.where((s) => s != null);
    return filesWithoutNull.cast<DateTime>();
  }

  DateTime? toFilenameFromFileEntity(FileSystemEntity file) {
    return toFilename(file.path);
  }

  DateTime? toFilenameFromDocumentFile(DocumentFile file) {
    return toFilename(file.name!);
  }

  DateTime? toFilename(String path) {
    int filenameStart = path.lastIndexOf('/') + 1;
    String filename = path.substring(filenameStart);
    try {
      return Filename.filenameToDate(filename);
    } on FormatException {
      // Empty strings will be filtered after this map
      return null;
    }
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
