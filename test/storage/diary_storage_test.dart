import 'dart:io';

import 'package:daily_diary/path.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/storage.dart';

main() {
  Directory testDirectory = Directory('test_data/diary_storage_test/');

  setUp(() async {
    await testDirectory.create(recursive: true);
  });

  test('Normal', () async {
    final storage = DiaryStorage(const SavePath.normal('test_data/'));
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
