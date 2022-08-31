import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CounterStorage {
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
