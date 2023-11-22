import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/filenames.dart';

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
    Stream<File> filtered = files.map(_entityToFile).where(_isNotNull).cast();
    return filtered.map(MyFile.normal);
  }

  bool _isNotNull(dynamic value) => value != null;

  File? _entityToFile(FileSystemEntity entity) {
    if (entity is File) return entity;
    return null;
  }

  Future<MyFile> getChild(String filename) async {
    if (isScopedStorage) {
      DocumentFile docFile = await _getChildScoped(filename);
      return MyFile.android(docFile);
    }
    File file = File('$path/$filename');
    return MyFile.normal(file);
  }

  Future<DocumentFile> _getChildScoped(String filename) async {
    final file = await child(uri!, filename);
    if (file != null) {
      return file;
    }
    DocumentFile? createdFile = await createFile(
      uri!,
      mimeType: '',
      displayName: filename,
    );
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

  bool get _isScopedStorage => _file == null;

  String get name {
    if (_isScopedStorage) {
      // Name is only null if the file is obtained without [DocumentFileColumn.displayName]
      return _docFile!.name!;
    }
    String path = _file!.path;
    int filenameStart = path.lastIndexOf(Platform.pathSeparator) + 1;
    return path.substring(filenameStart);
  }

  Future<void> rename(String filename) async {
    if (_isScopedStorage) {
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

  Future<String> readAsString() async {
    try {
      if (_isScopedStorage) {
        final content = await _docFile!.getContent();
        return utf8.decode(content!);
      }
      return _file!.readAsString();
    } catch (error) {
      return '';
    }
  }

  Future<void> writeFile(String text) async {
    if (_isScopedStorage) {
      await _writeScopedFile(text);
    } else {
      await _writeNormalFile(text);
    }
  }

  Future<void> _writeScopedFile(String text) async {
    if (text.isNotEmpty) {
      final bytes = Uint8List.fromList(utf8.encode(text));
      await _docFile!.writeToFileAsBytes(bytes: bytes);
      return;
    }
    // If the text to be written is empty, we want to delete the file to not
    // have empty entry files everywhere
    if (await _docFile!.exists() == true) {
      await _docFile!.delete();
    }
  }

  Future<void> _writeNormalFile(String text) async {
    if (text.isNotEmpty) {
      _file!.writeAsStringSync(text);
      return;
    }
    // If the text to be written is empty, we want to delete the file to not
    // have empty entry files everywhere
    if (_file!.existsSync()) {
      _file!.deleteSync();
    }
  }
}

class EntryFile {
  EntryFile._internal(this.file, this.entryDate);

  final MyFile file;
  final DateTime entryDate;

  static EntryFile? create(MyFile newFile) {
    DateTime? date = Filename.filenameToDate(newFile.name);
    if (date == null) return null;
    return EntryFile._internal(newFile, date);
  }

  int compareTo(EntryFile b) {
    return entryDate.compareTo(b.entryDate);
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
