import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toml/toml.dart';

abstract class Storage {
  const Storage();

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

  Future<String> get _path async {
    final directory = await _directory;
    return directory.path;
  }
}

class DiaryStorage extends Storage {
  const DiaryStorage();

  Future<File> get _localFile async {
    String path = await _path;
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

  Future<double?> getFontSize() async {
    final fontSize = await _getFromFile('font_size');
    return fontSize is double ? fontSize : null;
  }

  setFontSize(double size) {
    _writeToFile('font_size', size);
  }

  Future<Color?> getColorScheme() async {
    String hex = await _getFromFile('color_scheme') ?? "";
    return colorFromHex(hex);
  }

  setColorScheme(Color color) async {
    String hex = colorToHex(color, includeHashSign: true, enableAlpha: false);
    _writeToFile('color_scheme', hex);
  }

  Future<String?> getSavePath() async {
    final path = await _getDynamicSavePath();
    return path is String ? path : null;
  }

  Future<dynamic> _getDynamicSavePath() async {
    if (Platform.isLinux) {
      return _getFromFile('linux_save_location');
    } else if (Platform.isWindows) {
      return _getFromFile('windows_save_location');
    } else if (Platform.isMacOS) {
      return _getFromFile('macos_save_location');
    }
  }

  Future<String> get _fileName async {
    String path = await _path;
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
  const PreviousEntriesStorage();

  Future<List<DateTime>> getFiles() async {
    final directory = await _directory;
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

class PreviousEntryStorage extends Storage {
  const PreviousEntryStorage(this.filename);

  final String filename;

  Future<String> readFile() async {
    try {
      String path = await _path;
      final file = File('$path/$filename.txt');
      final contents = await file.readAsString();
      return contents;
    } catch (error) {
      return "";
    }
  }
}
