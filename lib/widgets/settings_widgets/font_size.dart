import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/localization.dart';
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
    return ListTile(
      title: Text(locale(context).fontSize),
      trailing: SizedBox(
        width: 48,
        child: TextField(
          controller: _fontSizeController,
          onChanged: _setFontSize,
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }
}
