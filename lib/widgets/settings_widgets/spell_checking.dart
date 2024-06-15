import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:provider/provider.dart';

const alertColor = Color.fromARGB(255, 240, 88, 50);

class SpellCheckToggle extends StatefulWidget implements SettingTile {
  const SpellCheckToggle({super.key});

  @override
  Future<SpellCheckToggle> newDefault(BuildContext context) async {
    await context.read<SpellCheckingProvider>().setToDefault();
    return SpellCheckToggle(
      key: UniqueKey(),
    );
  }

  @override
  State<SpellCheckToggle> createState() => _SpellCheckToggleState();
}

class _SpellCheckToggleState extends State<SpellCheckToggle> {
  void _onChanged(bool? checked) {
    if (checked == null) {
      // This shouldn't be possible because it's not a tristate checkbox
      return;
    }
    setState(() {
      context.read<SpellCheckingProvider>().setCheckSpelling(checked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpellCheckingProvider>();
    return Column(
      children: [
        ListTile(
          title: Text(locale(context).checkSpelling),
          trailing: Checkbox(
            value: provider.checkSpelling,
            onChanged: _onChanged,
          ),
        ),
        Visibility(
          visible: provider.originalValue != provider.checkSpelling,
          child: const Text(
            'Restart app for changes to take effect',
            style: TextStyle(color: alertColor),
          ),
        ),
      ],
    );
  }
}
