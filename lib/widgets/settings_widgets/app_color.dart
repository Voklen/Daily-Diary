import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
