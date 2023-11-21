import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';

import 'package:path_provider/path_provider.dart' as path_prov;
import 'package:shared_storage/shared_storage.dart';

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

  Future<Stream<MyFile>> list() async {
    if (isScopedStorage) return _listScoped();
    return _listNormal();
  }

  Future<Stream<MyFile>> _listScoped() async {
    if (await canRead(uri!) == true) {
      //TODO handle lack of permissions
    }
    final files = listFiles(uri!, columns: [DocumentFileColumn.displayName]);
    return files.map(MyFile.android);
  }

  Future<Stream<MyFile>> _listNormal() async {
    final dir = Directory(path!);
    final files = dir.list();
    // Can cast Stream<File?> to Stream<File> because we've just filtered all the null values
    final filtered = files.map(_entityToFile).where(_isNotNull) as Stream<File>;
    return filtered.map(MyFile.normal);
  }

  bool _isNotNull(dynamic value) => value != null;

  File? _entityToFile(FileSystemEntity entity) {
    if (entity is File) return entity;
    return null;
  }

  // Old methods

  Future<String> getScopedFile(String filename) async {
    final file = await getChildFile(filename); // This is where it pauses
    final content = await file.getContent();
    return utf8.decode(content!);
  }

  Future<void> writeScopedFile(String filename, String content) async {
    final file = await getChildFile(filename);
    final bytes = Uint8List.fromList(utf8.encode(content));
    await file.writeToFileAsBytes(bytes: bytes);
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

/// The .android() DocumentFile must have [DocumentFileColumn.displayName]
class MyFile {
  // Due to the constructors only one can ever be null at any time
  const MyFile.normal(File this._file) : _docFile = null;

  const MyFile.android(DocumentFile this._docFile) : _file = null;

  final File? _file;
  final DocumentFile? _docFile;

  bool get isScopedStorage => _file == null;

  String get name {
    if (isScopedStorage) {
      // Name is only null if the file is obtained without [DocumentFileColumn.displayName]
      return _docFile!.name!;
    }
    String path = _file!.path;
    int filenameStart = path.lastIndexOf(Platform.pathSeparator) + 1;
    return path.substring(filenameStart);
  }

  Future<void> rename(String filename) async {
    if (isScopedStorage) {
      await _docFile!.renameTo(filename);
    } else {
      await _renameNormal(filename);
    }
  }

  Future<File> _renameNormal(String newFilename) {
    var path = _file!.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFilename;
    return _file!.rename(newPath);
  }
}

Future<SavePath> getPath() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await App.preferences;
  String? path = preferences.getString('save_path');
  bool? isAndroidScoped = preferences.getBool('is_android_scoped');
  if (path != null) {
    if (isAndroidScoped == true) {
      final map = json.decode(path) as Map<String, dynamic>;
      DocumentFile document = DocumentFile.fromMap(map);
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
    final directory = await path_prov.getExternalStorageDirectory();
    if (directory != null) {
      return directory;
    }
  }

  final directory = await path_prov.getApplicationDocumentsDirectory();
  return directory;
}
