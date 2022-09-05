import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toml/toml.dart';

class DiaryStorage extends Storage {
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

  Future<TomlDocument> get _localFile async {
    WidgetsFlutterBinding.ensureInitialized();
    String path = await _localPath;
    return TomlDocument.load('$path/config.toml');
  }

  Future<dynamic> _getFromFile(key) async {
    try {
      final file = await _localFile;
      final config = file.toMap();
      return config[key];
    } catch (error) {
      print('ERROR: $error');
    }
  }

  Future<void> _writeToFile(key, value) async {
    String path = await _localPath;
    var document = TomlDocument.fromMap({key: value});
    File('$path/config.toml').writeAsString(document.toString());
  }
}

class Storage {
  Future<String> get _localPath async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory.path;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
