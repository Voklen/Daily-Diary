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
    final newDateFormat = DateFormatSetting._dateFormatController.text;
    if (_validator(newDateFormat) != null) return;

    final renameFiles = RenameFiles(newDateFormat);
    await renameFiles.rewriteExistingFiles();
    App.settingsNotifier.setDateFormat(newDateFormat);
    _checkIfAskToPressEnter(newDateFormat);
  }

  /// Returns null if okay, otherwise returns a string with a description of the error
  String? _validator(value) {
    if (value == null) {
      return 'Cannot be empty';
    }
    const invalidChars = ['/', '<', '>', ':', '"', '\\', '|', '?', '*'];
    for (int i = 0; i < invalidChars.length; i++) {
      if (value.contains(invalidChars[i])) {
        return 'Invalid character: ${invalidChars[i]}';
      }
    }
    const requiredStrings = ['%Y', '%M', '%D'];
    for (int i = 0; i < requiredStrings.length; i++) {
      if (!value.contains(requiredStrings[i])) {
        return 'Must contain: ${requiredStrings[i]}';
      }
    }
    if (value[value.length - 1] == ' ' || value[value.length - 1] == '.') {
      return 'Cannot end in a space or a dot';
    }
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

      title: Text(
        'File name format:',
        style: Theme.of(context).textTheme.titleMedium,
      ),
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
