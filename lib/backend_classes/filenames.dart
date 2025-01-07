import 'package:daily_diary/main.dart';

class Filename {
  static String dateToFilename(DateTime date, {String? dateFormat}) {
    final format = dateFormat ?? App.settingsNotifier.value.dateFormat;
    return format
        .replaceAll('%Y', _twoDigits(date.year)) 
        .replaceAll('%M', _twoDigits(date.month)) 
        .replaceAll('%D', _twoDigits(date.day)); 
  }

 
  static String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  static DateTime? filenameToDate(String filename) {
    final dateFormat = App.settingsNotifier.value.dateFormat;
    final order = _Order.fromFormat(dateFormat);

    final regexPattern = dateFormat
        .replaceAll('%Y', r'(\d{4})') 
        .replaceAll('%M', r'(\d{2})') 
        .replaceAll('%D', r'(\d{2})'); 
    final regex = RegExp(regexPattern);
    final match = regex.firstMatch(filename); 

    if (match == null) return null; 

    try {
      // Parse the matched groups into a DateTime object
      return DateTime(
        int.parse(match.group(order.year)!), // Year group
        int.parse(match.group(order.month)!), // Month group
        int.parse(match.group(order.day)!), // Day group
      );
    } catch (_) {
      return null; // Return null for invalid dates
    }
  }
}

class _Order {
  final int year; 
  final int month; 
  final int day; 

  _Order._(this.year, this.month, this.day);

  factory _Order.fromFormat(String format) {
    final positions = {
      '%Y': format.indexOf('%Y'),
      '%M': format.indexOf('%M'),
      '%D': format.indexOf('%D'),
    };

    final sorted = positions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return _Order._(
      sorted.indexWhere((e) => e.key == '%Y') + 1,
      sorted.indexWhere((e) => e.key == '%M') + 1,
      sorted.indexWhere((e) => e.key == '%D') + 1,
    );
  }
}
