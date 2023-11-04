import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/filenames.dart';
import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:shared_storage/shared_storage.dart' as saf;

class DateFormatSetting extends StatefulWidget implements SettingTile {
  const DateFormatSetting({super.key});

  @override
  Future<DateFormatSetting> newDefault() async {
    String defaultDateFormat = Settings().dateFormat;
    final renameFiles = RenameFiles(defaultDateFormat);
    await renameFiles.rewriteExistingFiles();

    await App.settingsNotifier.setDateFormatToDefault();
    _dateFormatController.text = App.settingsNotifier.value.dateFormat;
    return DateFormatSetting(
      key: UniqueKey(),
    );
  }

  static final _dateFormatController = TextEditingController(
    text: App.settingsNotifier.value.dateFormat,
  );

  @override
  State<DateFormatSetting> createState() => _DateFormatSettingState();
}

class _DateFormatSettingState extends State<DateFormatSetting> {
  bool _askToPressEnter = false;

  void _setDateFormat() async {
    final String newDateFormat = DateFormatSetting._dateFormatController.text;
    if (_validator(newDateFormat) != null) return;

    final renameFiles = RenameFiles(newDateFormat);
    await renameFiles.rewriteExistingFiles();
    App.settingsNotifier.setDateFormat(newDateFormat);
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
    if (value == App.settingsNotifier.value.dateFormat) {
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

      title: const Text('File name format'),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.always,
          validator: _validator,
          onChanged: _checkIfAskToPressEnter,
          controller: DateFormatSetting._dateFormatController,
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
  const RenameFiles(this.newDateFormat);

  final String newDateFormat;

  static final SavePath path = savePath!;

  Future<void> rewriteExistingFiles() async {
    if (path.isScopedStorage) {
      await _getFilesScopedStorage();
    } else {
      await _getFilesNormal();
    }
  }

  Future<void> _getFilesNormal() async {
    final directory = Directory(path.path!);
    final files = directory.list();
    await files.forEach(renameFileEntity);
  }

  Future<void> _getFilesScopedStorage() async {
    Uri uri = path.uri!;
    if (await saf.canRead(uri) == true) {
      //TODO handle lack of permissions
    }
    final files =
        saf.listFiles(uri, columns: [saf.DocumentFileColumn.displayName]);
    await files.forEach(renameDocumentFile);
  }

  void renameFileEntity(FileSystemEntity file) {
    var oldFilename = file.path;
    String? newFilename = getNewFilename(oldFilename);
    if (newFilename != null) {
      String newPath = changeFilenameInPath(file.path, newFilename);
      file.rename(newPath);
    }
  }

  void renameDocumentFile(saf.DocumentFile file) {
    String oldFilename = file.name!;
    String? newFilename = getNewFilename(oldFilename);
    if (newFilename != null) {
      file.renameTo(newFilename);
    }
  }

  String changeFilenameInPath(String path, String replacement) {
    int filenameStart = path.lastIndexOf('/') + 1;
    return path.replaceRange(filenameStart, null, replacement);
  }

  String? getNewFilename(String oldFilename) {
    DateTime? date = dateFromFilename(oldFilename);
    if (date == null) {
      return null;
    }
    String newFilename =
        Filename.dateToFilename(date, dateFormat: newDateFormat);
    if (newFilename == oldFilename) {
      return null;
    }
    return newFilename;
  }

  DateTime? dateFromFilename(String path) {
    int filenameStart = path.lastIndexOf('/') + 1;
    String filename = path.substring(filenameStart);
    try {
      return Filename.filenameToDate(filename);
    } on FormatException {
      // Invalid files will be ignored
      return null;
    }
  }
}
