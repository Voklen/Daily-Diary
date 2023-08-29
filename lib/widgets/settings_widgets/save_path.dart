import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:file_picker/file_picker.dart';
import 'package:shared_storage/shared_storage.dart' as saf;

const alertColor = Color.fromARGB(255, 240, 88, 50);

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
    if (!await confirmChangingSavePath(context)) {
      return;
    }
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

Future<bool> confirmChangingSavePath(BuildContext context) async {
  bool? shouldContinue = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Changing save location'),
      content: const Text(
        'If you change the save location your old entries will not be copied over so it may appear as they are gone but they will still be safely in the old save location. To see them again either reset this setting back to the default or copy the files over manually to the new location.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
  return shouldContinue ?? false;
}
