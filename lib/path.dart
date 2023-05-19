import 'dart:convert';
import 'dart:io';
import 'package:daily_diary/main.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_storage/saf.dart';

Future<SavePath> getPath() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  String? path = preferences.getString('save_path');
  bool? isAndroidScoped = preferences.getBool('is_android_scoped');
  if (path != null) {
    if (isAndroidScoped == true) {
      DocumentFile document = DocumentFile.fromMap(json.decode(path));
      return SavePath.android(document.uri);
    }
    return SavePath.normal(path);
  } else {
    SavePath path = await defaultPath;
    preferences.setString('save_path', path.path!);
    preferences.setBool('is_android_scoped', false);
    return path;
  }
}

Future<SavePath> get defaultPath async {
  final directory = await _directory;
  return SavePath.normal(directory.path);
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
