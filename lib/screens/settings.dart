import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/widgets/settings_widgets/app_color.dart';
import 'package:daily_diary/widgets/settings_widgets/date_format.dart';
import 'package:daily_diary/widgets/settings_widgets/export_files.dart';
import 'package:daily_diary/widgets/settings_widgets/font_size.dart';
import 'package:daily_diary/widgets/settings_widgets/links.dart';
import 'package:daily_diary/widgets/settings_widgets/save_path.dart';
import 'package:daily_diary/widgets/settings_widgets/spell_checking.dart';
import 'package:daily_diary/widgets/settings_widgets/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(locale(context).settings)),
      body: const Padding(
        padding: EdgeInsets.all(10.0),
        child: SettingsList(
          children: [
            ThemeSetting(),
            FontSetting(),
            SpellCheckToggle(),
            ColorSetting(),
            DateFormatSetting(),
            SavePathSetting(),
          ],
        ),
      ),
    );
  }
}

class SettingsList extends StatefulWidget {
  const SettingsList({super.key, required this.children});

  final List<SettingTile> children;

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  bool showResetButtons = false;

  @override
  Widget build(BuildContext context) {
    // Then all the children are wrapped in `SettingsListElement`
    // which allows a reset button to appear beside them
    List<Widget> children = widget.children.map(_modifyChild).toList();

    // Buttons that are not settings (cannot be reset) are appended here
    children.addAll([
      buttonToShowResetButtons(),
      const ExportData(),
      const RepoLink(),
    ]);
    return ListView(children: children);
  }

  Widget buttonToShowResetButtons() {
    return ListTile(
      onTap: toggleResetButtons,
      title: Text(
        showResetButtons
            ? locale(context).cancel
            : locale(context).resetSettings,
      ),
      leading: Icon(showResetButtons ? Icons.cancel : Icons.restore),
    );
  }

  void toggleResetButtons() {
    setState(() {
      showResetButtons = !showResetButtons;
    });
  }

  Widget _modifyChild(SettingTile element) {
    return SettingsListElement(
      showResetOption: showResetButtons,
      child: element,
    );
  }
}

class SettingsListElement extends StatefulWidget {
  const SettingsListElement({
    super.key,
    required this.showResetOption,
    required this.child,
  });

  final bool showResetOption;
  final SettingTile child;

  @override
  State<SettingsListElement> createState() => _SettingsListElementState();
}

class _SettingsListElementState extends State<SettingsListElement> {
  static const padding = EdgeInsets.only(bottom: 12);
  late SettingTile child = widget.child;

  @override
  Widget build(BuildContext context) {
    final double containerWidth = widget.showResetOption ? 40 : 0;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          AnimatedContainer(
            width: containerWidth,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () async {
                child = await child.newDefault();
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

abstract class SettingTile extends Widget {
  const SettingTile({super.key});

  Future<SettingTile> newDefault();
}
