import 'package:daily_diary/main.dart';

class Filename {
  static String dateToFilename(DateTime date) {
    String filename = App.settingsNotifier.value.dateFormat;
    filename = filename.replaceAll('%Y', _twoDigits(date.year));
    filename = filename.replaceAll('%M', _twoDigits(date.month));
    filename = filename.replaceAll('%D', _twoDigits(date.day));
    return filename;
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  static DateTime? filenameToDate(String filename) {
    String dateFormat = App.settingsNotifier.value.dateFormat;
    _Order order = _Order(dateFormat);

    String regexString = dateFormat
        .replaceFirst('%Y', r'(\d+)')
        .replaceFirst('%M', r'(\d+)')
        .replaceFirst('%D', r'(\d+)');
    RegExp regex = RegExp(regexString);

    // Find all matches of the pattern in the expression
    final RegExpMatch? matches = regex.firstMatch(filename);
    if (matches == null) return null;

    // The groups cannot be null because the regex has 3 groups and so all must exist
    int year = int.parse(matches.group(order.year)!);
    int month = int.parse(matches.group(order.month)!);
    int day = int.parse(matches.group(order.day)!);
    return DateTime(year, month, day);
  }
}

class _Order {
  late int year;
  late int month;
  late int day;

  _Order(String dateFormat) {
    int yearLocation = dateFormat.indexOf('%Y');
    int monthLocation = dateFormat.indexOf('%M');
    int dayLocation = dateFormat.indexOf('%D');

    if (yearLocation < monthLocation && monthLocation < dayLocation) {
      year = 1;
      month = 2;
      day = 3;
      return;
    }
    if (yearLocation < dayLocation && dayLocation < monthLocation) {
      year = 1;
      day = 2;
      month = 3;
      return;
    }
    if (monthLocation < yearLocation && yearLocation < dayLocation) {
      month = 1;
      year = 2;
      day = 3;
      return;
    }
    if (monthLocation < dayLocation && dayLocation < yearLocation) {
      month = 1;
      day = 2;
      year = 3;
      return;
    }
    if (dayLocation < yearLocation && yearLocation < monthLocation) {
      day = 1;
      year = 2;
      month = 3;
      return;
    }
    if (dayLocation < monthLocation && monthLocation < yearLocation) {
      day = 1;
      month = 2;
      year = 3;
      return;
    }
  }
}