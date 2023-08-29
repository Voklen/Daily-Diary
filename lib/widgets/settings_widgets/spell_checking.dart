import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/screens/settings.dart';

const alertColor = Color.fromARGB(255, 240, 88, 50);

class SpellCheckToggle extends StatefulWidget implements SettingTile {
  const SpellCheckToggle({super.key});

  @override
  Future<SpellCheckToggle> newDefault() async {
    await App.settingsNotifier.setCheckSpellingToDefault();
    return SpellCheckToggle(
      key: UniqueKey(),
    );
  }

  @override
  State<SpellCheckToggle> createState() => _SpellCheckToggleState();
}

class _SpellCheckToggleState extends State<SpellCheckToggle> {
  _onChanged(bool checked) {
    setState(() {
      App.settingsNotifier.setCheckSpelling(checked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Check spelling:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 5),
            Switch(
              value: App.settingsNotifier.value.checkSpelling,
              onChanged: _onChanged,
            )
          ],
        ),
        Visibility(
          visible:
              startupCheckSpelling != App.settingsNotifier.value.checkSpelling,
          child: const Text(
            'Restart app for changes to take effect',
            style: TextStyle(color: alertColor),
          ),
        ),
      ],
    );
  }
}
