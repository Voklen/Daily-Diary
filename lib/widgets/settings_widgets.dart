import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/filenames.dart';
import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_storage/shared_storage.dart' as saf;

const alertColor = Color.fromARGB(255, 240, 88, 50);

class ThemeSetting extends StatefulWidget implements SettingTile {
  const ThemeSetting({super.key});

  @override
  Future<ThemeSetting> newDefault() async {
    await App.settingsNotifier.setThemeToDefault();
    return ThemeSetting(
      key: UniqueKey(),
    );
  }

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  List<bool> _selections = _getTheme();

  static List<bool> _getTheme() {
    switch (App.settingsNotifier.value.theme) {
      case ThemeMode.light:
        return [true, false, false];
      case ThemeMode.system:
        return [false, true, false];
      case ThemeMode.dark:
        return [false, false, true];
    }
  }

  _setTheme(int index) {
    switch (index) {
      case 0:
        App.settingsNotifier.setTheme(ThemeMode.light);
        break;
      case 1:
        App.settingsNotifier.setTheme(ThemeMode.system);
        break;
      case 2:
        App.settingsNotifier.setTheme(ThemeMode.dark);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _selections = _getTheme();
    return Row(
      children: [
        Text(
          "Theme:",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 5),
        ToggleButtons(
          isSelected: _selections,
          onPressed: (int index) {
            _selections = [false, false, false];
            setState(() {
              _selections[index] = true;
            });
            _setTheme(index);
          },
          renderBorder: false,
          borderRadius: BorderRadius.circular(8),
          children: const [
            Text('Light'),
            Text('System'),
            Text('Dark'),
          ],
        ),
      ],
    );
  }
}

class SpellCheckToggle extends StatefulWidget implements SettingTile {
  const SpellCheckToggle({super.key});

  @override
  Future<SpellCheckToggle> newDefault() async {
    await App.settingsNotifier.setCheckSpellingToDefault();
    return SpellCheckToggle(
      key: UniqueKey(),
    );
  }

  @override
  State<SpellCheckToggle> createState() => _SpellCheckToggleState();
}

class _SpellCheckToggleState extends State<SpellCheckToggle> {
  _onChanged(bool checked) {
    setState(() {
      App.settingsNotifier.setCheckSpelling(checked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Check spelling:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 5),
            Switch(
              value: App.settingsNotifier.value.checkSpelling,
              onChanged: _onChanged,
            )
          ],
        ),
        Visibility(
          visible:
              startupCheckSpelling != App.settingsNotifier.value.checkSpelling,
          child: const Text(
            'Restart app for changes to take effect',
            style: TextStyle(color: alertColor),
          ),
        ),
      ],
    );
  }
}

class FontSetting extends StatelessWidget implements SettingTile {
  const FontSetting({super.key});

  @override
  Future<FontSetting> newDefault() async {
    await App.settingsNotifier.setFontSizeToDefault();
    return FontSetting(
      key: UniqueKey(),
    );
  }

  static final _fontSizeController = TextEditingController(
    text: App.settingsNotifier.value.fontSize.toString(),
  );

  void _setFontSize(String fontSizeString) {
    try {
      final fontSize = double.parse(fontSizeString);
      App.settingsNotifier.setFontSize(fontSize);
    } on FormatException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    _fontSizeController.text = App.settingsNotifier.value.fontSize.toString();
    return Row(
      children: [
        Text(
          "Font size:",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 48,
          height: 24,
          child: TextField(
            controller: _fontSizeController,
            onChanged: _setFontSize,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}

class ColorSetting extends StatelessWidget implements SettingTile {
  const ColorSetting({super.key});

  @override
  Future<ColorSetting> newDefault() async {
    await App.settingsNotifier.setColorSchemeToDefault();
    return const ColorSetting();
  }

  _setColorScheme(Color colorScheme) {
    App.settingsNotifier.setColorScheme(colorScheme);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "App color scheme:",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ColorPicker(
            pickerColor: App.settingsNotifier.value.colorScheme,
            onColorChanged: _setColorScheme,
            enableAlpha: false,
            colorPickerWidth: 250,
          ),
        ),
      ],
    );
  }
}

class DateFormatSetting extends StatefulWidget implements SettingTile {
  const DateFormatSetting({super.key});

  @override
  Future<DateFormatSetting> newDefault() async {
    await App.settingsNotifier.setDateFormatToDefault();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File name format:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
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
      ],
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

class SavePathSetting extends StatefulWidget implements SettingTile {
  const SavePathSetting({super.key});

  @override
  Future<SavePathSetting> newDefault() async {
    newSavePath = await resetPathToDefault();
    return const SavePathSetting();
  }

  @override
  State<SavePathSetting> createState() => _SavePathSettingState();
}

class _SavePathSettingState extends State<SavePathSetting> {
  void _selectNewPath() async {
    final path = await _askForPath();
    if (path == null) {
      // The user aborted the dialog or the folder path couldn't be resolved.
      return;
    }

    setState(() {
      newSavePath = path;
    });
  }

  Future<SavePath?> _askForPath() async {
    if (Platform.isAndroid) {
      return _askForPathAndroid();
    }
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path == null) {
      return null;
    }

    final preferences = await App.preferences;
    preferences.setString('save_path', path);
    preferences.setBool('is_android_scoped', false);
    return SavePath.normal(path);
  }

  Future<SavePath?> _askForPathAndroid() async {
    _removePreviousPermissions();

    // Ask user for path and permissions
    Uri? uri;
    while (uri == null) {
      uri = await saf.openDocumentTree();
    }

    // Only null before Android API 21, but this project is API 21+
    final asDocumentFile = await uri.toDocumentFile();
    Map asMap = asDocumentFile!.toMap();
    String asString = json.encode(asMap);
    final preferences = await App.preferences;
    preferences.setString('save_path', asString);
    preferences.setBool('is_android_scoped', true);
    return SavePath.android(uri);
  }

  Future<void> _removePreviousPermissions() async {
    SavePath? path = savePath;
    if (path == null) return;

    Uri? previousPath = path.uri;
    if (previousPath == null) return;

    await saf.releasePersistableUriPermission(previousPath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Save Location:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: TextField(
            controller: TextEditingController(text: newSavePath!.string),
            enabled: false,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(
          width: 125,
          child: ElevatedButton(
            onPressed: _selectNewPath,
            child: const Text('Change folder'),
          ),
        ),
        Visibility(
          visible: savePath!.string != newSavePath!.string,
          child: const Text(
            'Restart app for changes to take effect',
            style: TextStyle(color: alertColor),
          ),
        ),
      ],
    );
  }
}
