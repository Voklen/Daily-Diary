import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/storage.dart';

void main() {
  //TODO Use something other than global variables in main.dart for savePath
  // so hacks like this are not needed
  savePath = const SavePath.normal('test_data/diary_storage_test/');
  Directory testDirectory = Directory('test_data/diary_storage_test/');

  setUp(() async {
    await testDirectory.create(recursive: true);
  });

  test('Normal', () async {
    final storage = DiaryStorage(savePath!);
    const testText = 'This is a test diary\n a newline here\nwow, another';
    storage.writeFile(testText);
    String result = await storage.readFile();

    expect(result, testText);
  });

  test('Unicode', () async {
    final storage = DiaryStorage(const SavePath.normal('test_data/'));
    const testText = 'This is a اختبر diary\n a newline here\nа вот еще один';
    storage.writeFile(testText);
    String result = await storage.readFile();

    expect(result, testText);
  });

  tearDown(() async {
    await testDirectory.delete(recursive: true);
  });
}
