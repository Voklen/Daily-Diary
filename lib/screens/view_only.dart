import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/settings_notifier.dart';
import 'package:daily_diary/storage.dart';
import 'package:daily_diary/screens/settings.dart';

class ViewOnlyScreen extends StatefulWidget {
  const ViewOnlyScreen({Key? key, required this.title, required this.storage})
      : super(key: key);

  final String title;
  final PreviousEntryStorage storage;

  @override
  State<ViewOnlyScreen> createState() => _ViewOnlyScreenState();
}

class _ViewOnlyScreenState extends State<ViewOnlyScreen> {
  _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
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
              future: widget.storage.readFile(),
              builder: ((context, AsyncSnapshot<String> file) {
                return Text(
                  file.data ?? "",
                  style: TextStyle(fontSize: currentSettings.fontSize),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
