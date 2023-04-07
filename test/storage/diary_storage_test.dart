import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/storage.dart';

main() {
  Directory testDirectory = Directory('test_data/diary_storage_test/');

  setUp(() async {
    await testDirectory.create(recursive: true);
  });

  test('Normal', () async {
    final storage = DiaryStorage('test_data/');
    const testText = 'This is a test diary\n a newline here\nwow, another';
    await storage.writeFile(testText);
    String result = await storage.readFile();

    expect(result, testText);
  });

  test('Unicode', () async {
    final storage = DiaryStorage('test_data/');
    const testText = 'This is a اختبر diary\n a newline here\nа вот еще один';
    await storage.writeFile(testText);
    String result = await storage.readFile();

    expect(result, testText);
  });

  tearDown(() async {
    await testDirectory.delete(recursive: true);
  });
}
