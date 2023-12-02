import 'package:daily_diary/backend_classes/path.dart';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/screens/settings.dart';

class ViewOnlyScreen extends StatefulWidget {
  const ViewOnlyScreen({
    super.key,
    required this.title,
    required this.entryFile,
  });

  final String title;
  final EntryFile entryFile;

  @override
  State<ViewOnlyScreen> createState() => _ViewOnlyScreenState();
}

class _ViewOnlyScreenState extends State<ViewOnlyScreen> {
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Settings>(
      valueListenable: App.settingsNotifier,
      builder: (_, Settings currentSettings, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: <Widget>[
              IconButton(
                onPressed: _openSettings,
                icon: const Icon(
                  Icons.settings,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder(
              future: widget.entryFile.file.readAsString(),
              builder: ((context, AsyncSnapshot<String> file) {
                return FractionallySizedBox(
                  widthFactor: 1.0,
                  child: SingleChildScrollView(
                    child: Text(
                      file.data ?? '',
                      style: TextStyle(fontSize: currentSettings.fontSize),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
