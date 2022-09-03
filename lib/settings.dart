import 'package:daily_diary/main.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  void _toggleMode() {
    MyApp.themeNotifier.value = MyApp.themeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: IconButton(
          onPressed: _toggleMode, icon: Icon(Icons.brightness_medium_outlined)),
    );
  }
}
