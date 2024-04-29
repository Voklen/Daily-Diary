import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:provider/provider.dart';

class FontSetting extends StatelessWidget implements SettingTile {
  const FontSetting({super.key});

  @override
  Future<FontSetting> newDefault(BuildContext context) async {
    await context.read<FontSizeProvider>().setToDefault();
    return FontSetting(
      key: UniqueKey(),
    );
  }

  static final _fontSizeController = TextEditingController(
    text: '',
  );

  void _setFontSize(String fontSizeString, BuildContext context) {
    try {
      final fontSize = double.parse(fontSizeString);
      context.read<FontSizeProvider>().setFontSize(fontSize);
    } on FormatException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = context.read<FontSizeProvider>().fontSize;
    _fontSizeController.text = fontSize.toString();
    return ListTile(
      title: Text(locale(context).fontSize),
      trailing: SizedBox(
        width: 48,
        child: TextField(
          controller: _fontSizeController,
          onChanged: (s) => _setFontSize(s, context),
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }
}
