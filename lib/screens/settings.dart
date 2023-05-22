import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/path.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_storage/shared_storage.dart' as saf;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Padding(
        padding: EdgeInsets.all(10.0),
        child: SettingsList(
          children: [
            ThemeSetting(),
            FontSetting(),
            SpellCheckToggle(),
            ColorSetting(),
            SavePathSetting(),
          ],
        ),
      ),
    );
  }
}

class SettingsList extends StatefulWidget {
  const SettingsList({super.key, required this.children});

  final List<SettingTile> children;

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  bool showResetOption = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> modifiedChildren = [
      ElevatedButton(
        onPressed: () => setState(() {
          showResetOption = !showResetOption;
        }),
        child: Text(showResetOption ? 'Cancel' : 'Select settings to reset'),
      ),
    ];
    modifiedChildren.addAll(widget.children.map(_modifyChild));

    return ListView(children: modifiedChildren);
  }

  Widget _modifyChild(SettingTile element) {
    return SettingsListElement(
      showResetOption: showResetOption,
      child: element,
    );
  }
}

class SettingsListElement extends StatefulWidget {
  const SettingsListElement({
    super.key,
    required this.showResetOption,
    required this.child,
  });

  final bool showResetOption;
  final SettingTile child;

  @override
  State<SettingsListElement> createState() => _SettingsListElementState();
}

class _SettingsListElementState extends State<SettingsListElement> {
  static const padding = EdgeInsets.only(bottom: 12);
  late SettingTile child = widget.child;

  @override
  Widget build(BuildContext context) {
    final double containerWidth = widget.showResetOption ? 40 : 0;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          AnimatedContainer(
            width: containerWidth,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () async {
                child = await child.newDefault();
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

abstract class SettingTile extends Widget {
  const SettingTile({super.key});

  Future<SettingTile> newDefault();
}

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

  _setFontSize(String fontSizeString) {
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

class SavePathSetting extends StatefulWidget implements SettingTile {
  const SavePathSetting({super.key});

  @override
  Future<SavePathSetting> newDefault() async {
    savePath = await resetPathToDefault();
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
      savePath = path;
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
        Visibility(
            visible: Platform.isAndroid,
            child: Text(
              'Changing this setting will only work properly if the device is rooted:',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            )),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: TextField(
            controller: TextEditingController(text: savePath!.string),
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
          visible: savePath != startupSavePath,
          child: const Text(
            'Restart app for changes to take effect',
            style: TextStyle(color: alertColor),
          ),
        ),
      ],
    );
  }
}
