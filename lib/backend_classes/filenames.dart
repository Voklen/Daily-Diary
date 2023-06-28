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
    final RegExp regex = RegExp(r'(\d+)-(\d+)-(\d+).txt');

    // Find all matches of the pattern in the expression
    final RegExpMatch? matches = regex.firstMatch(filename);
    if (matches == null) return null;

    // The groups cannot be null because the regex has 3 groups and so all must exist
    int year = int.parse(matches.group(1)!);
    int month = int.parse(matches.group(2)!);
    int day = int.parse(matches.group(3)!);
    return DateTime(year, month, day);
  }
}
