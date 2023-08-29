import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/screens/settings.dart';

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

  void _setFontSize(String fontSizeString) {
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