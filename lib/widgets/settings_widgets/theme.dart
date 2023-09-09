import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/screens/settings.dart';

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
    return ListTile(
      title: const Text("Theme"),
      trailing: ToggleButtons(
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
    );
  }
}
