import 'package:daily_diary/main.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<bool> _selections = [false, true, false];

  void _setTheme(int index) {
    switch (index) {
      case 0:
        MyApp.themeNotifier.value = ThemeMode.light;
        break;
      case 1:
        MyApp.themeNotifier.value = ThemeMode.system;
        break;
      case 2:
        MyApp.themeNotifier.value = ThemeMode.dark;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ToggleButtons(
            isSelected: _selections,
            onPressed: (int index) {
              _selections = [false, false, false];
              _selections[index] = true;
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
        ));
  }
}
