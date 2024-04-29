import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/screens/settings.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:provider/provider.dart';

class ColorSetting extends StatefulWidget implements SettingTile {
  const ColorSetting({super.key});

  @override
  Future<ColorSetting> newDefault(BuildContext context) async {
    await context.read<ColorSchemeProvider>().setToDefault();
    return ColorSetting(
      key: UniqueKey(),
    );
  }

  @override
  State<ColorSetting> createState() => _ColorSettingState();
}

class _ColorSettingState extends State<ColorSetting> {
  void _setColorScheme(Color colorScheme) async {
    await context.read<ColorSchemeProvider>().setColorScheme(colorScheme);
    setState(() {});
  }

  void _showColorPicker() {
    ColorPicker(
        color: context.read<ColorSchemeProvider>().colorScheme,
        onColorChanged: _setColorScheme,
        enableOpacity: false,
        pickersEnabled: const {
          ColorPickerType.primary: true,
          ColorPickerType.accent: false,
          ColorPickerType.wheel: true,
        }).showPickerDialog(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(locale(context).colorScheme),
      trailing: ColorIndicator(
        context.watch<ColorSchemeProvider>().colorScheme,
        key: UniqueKey(),
      ),
      onTap: _showColorPicker,
    );
  }
}

/// Simple round color indicator.
class ColorIndicator extends StatelessWidget {
  const ColorIndicator(
    this.color, {
    super.key,
    this.width = 50.0,
    this.height = 50.0,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(1000.0)),
        border: Border.all(color: const Color(0xffdddddd)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(1000.0)),
        child: ColoredBox(color: color),
      ),
    );
  }
}
