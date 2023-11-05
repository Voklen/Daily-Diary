import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  void _setTheme(int index) {
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
      title: Text(AppLocalizations.of(context)!.theme),
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
          AppLocalizations.of(context)!.lightTheme,
          AppLocalizations.of(context)!.systemTheme,
          AppLocalizations.of(context)!.darkTheme,
        ].map(_toTextWidget).toList(),
      ),
    );
  }
}
