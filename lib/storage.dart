import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toml/toml.dart';

class DiaryStorage extends Storage {
  const DiaryStorage();

  Future<File> get _localFile async {
    String path = await _localPath;
    DateTime date = DateTime.now();
    String isoDate = date.toIso8601String().substring(0, 10);
    return File('$path/$isoDate.txt');
  }

  Future<String> readFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (error) {
      return "";
    }
  }

  Future<File> writeFile(String counter) async {
    final file = await _localFile;
    return file.writeAsString(counter);
  }
}

class SettingsStorage extends Storage {
  SettingsStorage();

  late var settingsMap = _getMap();

  Future<Map<String, dynamic>> _getMap() async {
    try {
      final file = await _localFile;
      return file.toMap();
    } on FileSystemException {
      return {};
    }
  }

  Future<ThemeMode> getTheme() async {
    switch (await _getFromFile('theme')) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  setTheme(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        _writeToFile('theme', 'light');
        break;
      case ThemeMode.system:
        _writeToFile('theme', 'system');
        break;
      case ThemeMode.dark:
        _writeToFile('theme', 'dark');
        break;
    }
  }

  Future<double> getFontSize() async {
    final fontSize = await _getFromFile('font_size');
    return fontSize is double ? fontSize : 16;
  }

  setFontSize(double size) {
    _writeToFile('font_size', size);
  }

  Future<String> get _fileName async {
    String path = await _localPath;
    return '$path/config.toml';
  }

  Future<TomlDocument> get _localFile async {
    final file = await _fileName;
    return TomlDocument.load(file);
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

  _writeToFile(key, value) async {
    var map = await settingsMap;
    map[key] = value;
    settingsMap = Future(() => map);

    final file = await _fileName;
    TomlDocument asToml = TomlDocument.fromMap(map);
    File(file).writeAsString(asToml.toString());
  }
}

class PreviousEntriesStorage extends Storage {
  Future<List<String>> getFiles() async {
    final directory = await _directory;
    final stream = directory.list();
    final streamAsStrings = stream.map((file) => file.toString());
    final list = await streamAsStrings.toList();
    return list;
  }
}

class Storage {
  const Storage();

  Future<String> get _localPath async {
    final directory = await _directory;
    return directory.path;
  }

  Future<Directory> get _directory async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }
}
