import 'dart:io';
import 'package:daily_diary/quit_handler.dart';
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
  initState() {
    super.initState();

    QuitHandler.disable();
    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
    widget.storage.readFile().then((value) {
      setState(() {
        _textController.text = value;
      });
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _updateStorage();
    }
  }

  _loadSettings() {
    App.settingsNotifier.setFontSizeFromFile();
  }

  Future<File> _updateStorage() {
    QuitHandler.disable();
    return widget.storage.writeFile(_textController.text);
  }

  _textChanged(_) async {
    QuitHandler.enable(context, _saveAndQuit);
  }

  _saveAndQuit() {
    _updateStorage().then((_) {
      Navigator.of(context).pop(true);
    });
  }

  _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  _openPreviousEntries() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviousEntriesScreen(),
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
              onChanged: _textChanged,
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
