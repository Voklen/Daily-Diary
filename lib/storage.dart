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
    final path = await _localPath;
    return File('$path/counter.txt');
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
