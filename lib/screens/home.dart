import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/storage.dart';
import 'package:daily_diary/screens/settings.dart';
import 'package:daily_diary/screens/previous_entries.dart';
import 'package:daily_diary/settings_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.storage}) : super(key: key);

  final DiaryStorage storage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
    widget.storage.readFile().then((value) {
      setState(() {
        _textController.text = value;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _updateStorage();
    }
  }

  _loadSettings() async {
    App.settingsNotifier.setFontSize(await App.settings.getFontSize());
  }

  Future<File> _updateStorage() {
    return widget.storage.writeFile(_textController.text);
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openPreviousEntries() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PreviousEntriesScreen(),
      ),
    );
  }

  SpellCheckConfiguration? _getSpellChecker(Settings currentSettings) {
    if (Platform.isLinux) {
      return null;
    }
    if (!currentSettings.checkSpelling) {
      return null;
    }
    return const SpellCheckConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Settings>(
      valueListenable: App.settingsNotifier,
      builder: (_, Settings currentSettings, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Diary'),
            actions: <Widget>[
              IconButton(
                onPressed: _openPreviousEntries,
                icon: const Icon(
                  Icons.list_outlined,
                ),
              ),
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
            child: TextField(
              controller: _textController,
              expands: true,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              spellCheckConfiguration: _getSpellChecker(currentSettings),
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: currentSettings.fontSize),
              decoration:
                  const InputDecoration.collapsed(hintText: "Start typing…"),
            ),
          ),
        );
      },
    );
  }
}
