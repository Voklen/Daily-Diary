import 'package:daily_diary/main.dart';
import 'package:daily_diary/storage.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = SettingsStorage();
  final _fontSizeController = TextEditingController(
    text: _getFontSize().toString(),
  );

  List<bool> _selections = _getTheme();

  static List<bool> _getTheme() {
    switch (App.themeNotifier.value) {
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
        App.themeNotifier.value = ThemeMode.light;
        break;
      case 1:
        App.themeNotifier.value = ThemeMode.system;
        break;
      case 2:
        App.themeNotifier.value = ThemeMode.dark;
        break;
    }
    settings.setTheme(App.themeNotifier.value);
  }

  static double _getFontSize() => App.fontSizeNotifier.value;

  _setFontSize(String sizeString) {
    try {
      final sizeDouble = double.parse(sizeString);
      App.fontSizeNotifier.value = sizeDouble;
      settings.setFontSize(sizeDouble);
    } on FormatException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              borderRadius: BorderRadius.circular(30),
              children: const [
                Text('Light'),
                Text('System'),
                Text('Dark'),
              ],
            ),
            Text(
              "Font size:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextField(
              controller: _fontSizeController,
              onChanged: _setFontSize,
              keyboardType: TextInputType.number,
            )
          ],
        ),
      ),
    );
  }
}
