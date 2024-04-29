import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:provider/provider.dart';

class ThemeSetting extends StatefulWidget implements SettingTile {
  const ThemeSetting({super.key});

  @override
  Future<ThemeSetting> newDefault(BuildContext context) async {
    await context.read<ThemeProvider>().setToDefault();
    return ThemeSetting(
      key: UniqueKey(),
    );
  }

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  late List<bool> _selections = _getTheme();

  List<bool> _getTheme() {
    switch (context.read<ThemeProvider>().theme) {
      case ThemeMode.light:
        return [true, false, false];
      case ThemeMode.system:
        return [false, true, false];
      case ThemeMode.dark:
        return [false, false, true];
    }
  }

  void _setTheme(int index) {
    final readProvider = context.read<ThemeProvider>();
    switch (index) {
      case 0:
        readProvider.setTheme(ThemeMode.light);
      case 1:
        readProvider.setTheme(ThemeMode.system);
      case 2:
        readProvider.setTheme(ThemeMode.dark);
    }
  }

  Widget _toTextWidget(String string) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        string,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(locale(context).theme),
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
        children: [
          locale(context).lightTheme,
          locale(context).systemTheme,
          locale(context).darkTheme,
        ].map(_toTextWidget).toList(),
      ),
    );
  }
}
