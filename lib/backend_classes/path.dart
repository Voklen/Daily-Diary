import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/saf.dart';

class SavePath {
  // Due to the constructors only one can ever be null at any time
  const SavePath.normal(String this.path) : uri = null;
  const SavePath.android(Uri this.uri) : path = null;

  final String? path;
  final Uri? uri;

  bool get isScopedStorage => path == null;

  String get string {
    if (isScopedStorage) {
      String fullString = Uri.decodeFull(uri!.path);
      return fullString.split(':').last;
    } else {
      return path!.replaceFirst('/storage/emulated/0/', '');
    }
  }

  Future<String> getScopedFile(String filename) async {
    final file = await getChildFile(filename);
    final content = await file.getContentAsString();
    return content!;
  }

  void writeScopedFile(String filename, String content) async {
    final file = await getChildFile(filename);
    file.writeToFileAsString(content: content);
  }

  Future<bool> scopedExists(String filename) async {
    final scopedStorageFile = await getChildFile(filename);
    final exists = await scopedStorageFile.exists();
    return exists!;
  }

  void deleteScoped(String filename) async {
    final file = await getChildFile(filename);
    file.delete();
  }

  Future<DocumentFile> getChildFile(String filename) async {
    final file = await findFile(uri!, filename);
    if (file != null) {
      return file;
    }
    DocumentFile? createdFile =
        await createFile(uri!, mimeType: '', displayName: filename);
    return createdFile!;
  }
}

Future<SavePath> getPath() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await App.preferences;
  String? path = preferences.getString('save_path');
  bool? isAndroidScoped = preferences.getBool('is_android_scoped');
  if (path != null) {
    if (isAndroidScoped == true) {
      DocumentFile document = DocumentFile.fromMap(json.decode(path));
      return SavePath.android(document.uri);
    }
    return SavePath.normal(path);
  } else {
    return resetPathToDefault();
  }
}

/// Resets the savePath to default in `SharedPreferences` and returns the
/// `SavePath` it was set to. It does NOT set the global `savePath`.
///
/// To set `savePath` do:
/// ```
/// savePath = await resetPathToDefault();
/// ```
Future<SavePath> resetPathToDefault() async {
  final preferences = await App.preferences;
  String path = await _defaultPath;
  preferences.setString('save_path', path);
  preferences.setBool('is_android_scoped', false);
  return SavePath.normal(path);
}

Future<String> get _defaultPath async {
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
