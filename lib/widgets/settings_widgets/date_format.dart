import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/filenames.dart';
import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/screens/settings.dart';
import 'package:provider/provider.dart';

class DateFormatSetting extends StatefulWidget implements SettingTile {
  const DateFormatSetting({super.key});

  @override
  Future<DateFormatSetting> newDefault(BuildContext context) async {
    String defaultDateFormat = DateFormatProvider.defaultValue;
    final dateFormatProvider = context.read<DateFormatProvider>();
    final renameFiles = RenameFiles(
        oldDateFormat: dateFormatProvider.dateFormat,
        newDateFormat: defaultDateFormat);
    final rewriteFilesFuture = renameFiles.rewriteExistingFiles();

    await dateFormatProvider.setToDefault();
    await rewriteFilesFuture;
    return DateFormatSetting(
      key: UniqueKey(),
    );
  }

  @override
  State<DateFormatSetting> createState() => _DateFormatSettingState();
}

class _DateFormatSettingState extends State<DateFormatSetting> {
  bool _askToPressEnter = false;

  final _dateFormatController = TextEditingController(text: '');

  @override
  void initState() {
    _dateFormatController.text = context.read<DateFormatProvider>().dateFormat;
    super.initState();
  }

  void _setDateFormat() async {
    final String newDateFormat = _dateFormatController.text;
    if (_validator(newDateFormat) != null) return;

    final dateFormatProvider = context.read<DateFormatProvider>();
    final renameFiles = RenameFiles(
      oldDateFormat: dateFormatProvider.dateFormat,
      newDateFormat: newDateFormat,
    );
    await renameFiles.rewriteExistingFiles();
    dateFormatProvider.setDateFormat(newDateFormat);
    _checkIfAskToPressEnter(newDateFormat);
  }

  /// Returns null if okay, otherwise returns a string with a description of the error
  String? _validator(String? value) {
    if (value == null || value.isEmpty) return 'Cannot be empty';

    const invalidChars = ['/', '<', '>', ':', '"', '\\', '|', '?', '*'];
    for (String invalidChar in invalidChars) {
      if (value.contains(invalidChar)) return 'Invalid character: $invalidChar';
    }

    // Conversion specification is the term used in `man 3 strftime`
    const conversionSpecifications = ['%Y', '%M', '%D'];
    for (String i in conversionSpecifications) {
      if (!value.contains(i)) return 'Must contain: $i';
    }

    for (String first in conversionSpecifications) {
      for (String second in conversionSpecifications) {
        final String combined = first + second;
        if (value.contains(combined)) return '$combined cannot be together';
      }
    }

    final String lastChar = value[value.length - 1];
    if (lastChar == ' ' || lastChar == '.') {
      return 'Cannot end in a space or a dot';
    }

    // Only if all checks are passed do we return null
    return null;
  }

  void _checkIfAskToPressEnter(String value) {
    if (value == context.read<DateFormatProvider>().dateFormat) {
      setState(() {
        _askToPressEnter = false;
      });
    } else {
      setState(() {
        _askToPressEnter = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // crossAxisAlignment: CrossAxisAlignment.start,

      title: Text(locale(context).filenameFormat),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.always,
          validator: _validator,
          onChanged: _checkIfAskToPressEnter,
          controller: _dateFormatController,
          onEditingComplete: _setDateFormat,
          decoration: InputDecoration(
            helperText: _askToPressEnter ? 'Press enter to save' : null,
            helperStyle: const TextStyle(color: Colors.green),
            errorMaxLines: 3,
          ),
        ),
      ),
    );
  }
}

class RenameFiles {
  const RenameFiles({required this.oldDateFormat, required this.newDateFormat});

  final String newDateFormat;
  final String oldDateFormat;

  static final SavePath path = savePath!;

  Future<void> rewriteExistingFiles() async {
    Stream<MyFile> files = await path.list();
    await files.forEach(_renameFile);
  }

  void _renameFile(MyFile file) {
    var oldFilename = file.name;
    String? newFilename = _getNewFilename(oldFilename);
    if (newFilename != null) {
      file.rename(newFilename);
    }
  }

  String? _getNewFilename(String oldFilename) {
    DateTime? date = Filename.filenameToDate(oldFilename, oldDateFormat);
    if (date == null) return null;

    String newFilename = Filename.dateToFilename(date, newDateFormat);
    if (newFilename == oldFilename) return null;
    return newFilename;
  }
}
