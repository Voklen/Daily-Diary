import 'dart:io';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getPath() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  String? path = preferences.getString('save_path');
  if (path != null) {
    return path;
  } else {
    path = await defaultPath;
    preferences.setString('save_path', path);
    return path;
  }
}

Future<String> get defaultPath async {
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
