import 'package:daily_diary/main.dart';
import 'package:daily_diary/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const spaceBetweenSettings = 12.0;

  final settings = SettingsStorage();
  final _fontSizeController = TextEditingController(
    text: _getFontSize().toString(),
  );

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
    settings.setTheme(App.settingsNotifier.value.theme);
  }

  static double _getFontSize() => App.settingsNotifier.value.fontSize;

  _setFontSize(String fontSizeString) {
    try {
      final fontSize = double.parse(fontSizeString);
      App.settingsNotifier.setFontSize(fontSize);
      settings.setFontSize(fontSize);
    } on FormatException {
      return;
    }
  }

  _setColourScheme(Color colorScheme) {
    settings.setColorScheme(colorScheme);
    App.settingsNotifier.setColorScheme(colorScheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Text(
              "Theme:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
            const SizedBox(height: spaceBetweenSettings),
            Text(
              "Font size:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                SizedBox(
                  width: 48,
                  child: TextField(
                    controller: _fontSizeController,
                    onChanged: _setFontSize,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: spaceBetweenSettings),
            Text(
              "App color scheme:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ColorPicker(
                pickerColor: App.settingsNotifier.value.colorScheme,
                onColorChanged: _setColourScheme,
                enableAlpha: false,
                colorPickerWidth: 250,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
