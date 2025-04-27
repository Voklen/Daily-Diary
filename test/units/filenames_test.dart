import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/backend_classes/filenames.dart';

void main() {
  group('dateToFilename', dateToFilenameTests);
  group('filenameToDate', filenameToDateTests);
}

void dateToFilenameTests() {
  test('ISO', () async {
    DateTime date = DateTime(2025, 01, 27);
    String filename = Filename.dateToFilename(date, dateFormat: '%Y-%M-%D');
    expect(filename, '2025-01-27');
  });
  test('ISO at 23:59:59', () async {
    DateTime date = DateTime(2025, 01, 27, 23, 59, 59);
    String filename = Filename.dateToFilename(date, dateFormat: '%Y-%M-%D');
    expect(filename, '2025-01-27');
  });
  test('UK', () async {
    DateTime date = DateTime(2025, 01, 27);
    String filename = Filename.dateToFilename(date, dateFormat: '%D.%M.%Y');
    expect(filename, '27.01.2025');
  });
  test('US', () async {
    DateTime date = DateTime(2025, 01, 27);
    String filename = Filename.dateToFilename(date, dateFormat: '%M/%D/%Y');
    expect(filename, '01/27/2025');
  });
}

void filenameToDateTests() {
  test('ISO', () async {
    String filename = '2025-01-27';
    DateTime? date = Filename.filenameToDate(filename, dateFormat: '%Y-%M-%D');
    expect(date, DateTime(2025, 01, 27));
  });
  test('UK', () async {
    String filename = '27.01.2025';
    DateTime? date = Filename.filenameToDate(filename, dateFormat: '%D.%M.%Y');
    expect(date, DateTime(2025, 01, 27));
  });
  test('US', () async {
    String filename = '01/27/2025';
    DateTime? date = Filename.filenameToDate(filename, dateFormat: '%M/%D/%Y');
    expect(date, DateTime(2025, 01, 27));
  });
  test('Empty string', () async {
    String filename = '';
    DateTime? date = Filename.filenameToDate(filename, dateFormat: '%Y-%M-%D');
    expect(date, null);
  });
  test('Extra char', () async {
    String filename = '2025-01--27';
    DateTime? date = Filename.filenameToDate(filename, dateFormat: '%Y-%M-%D');
    expect(date, null);
  });
  test('Extra char at end', () async {
    // This does still work, but I'm considering making sure it does not
    String filename = '2025-01-27-';
    DateTime? date = Filename.filenameToDate(filename, dateFormat: '%Y-%M-%D');
    expect(date, DateTime(2025, 01, 27));
  });
}
