import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/storage.dart';

void main() {
  Directory testDirectory = Directory('test_data/settings_storage_test');

  setUp(() async {
    await testDirectory.create(recursive: true);
  });

  test('Normal', () async {
    final storage = SettingsStorage(SavePath.normal(testDirectory.path));

    await storage.setTheme(ThemeMode.dark);
    await storage.setFontSize(42);
    await storage.setColorScheme(const Color.fromARGB(255, 139, 195, 74));
    await storage.setCheckSpelling(false);

    expect(await storage.getTheme(), ThemeMode.dark);
    expect(await storage.getFontSize(), 42);
    expect(
      await storage.getColorScheme(),
      const Color.fromARGB(255, 139, 195, 74),
    );
    expect(await storage.getCheckSpelling(), false);
  });

  tearDown(() async {
    await testDirectory.delete(recursive: true);
  });
}
