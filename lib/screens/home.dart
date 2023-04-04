import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/settings_notifier.dart';
import 'package:daily_diary/storage.dart';
import 'package:daily_diary/quit_handler.dart';
import 'package:daily_diary/screens/settings.dart';
import 'package:daily_diary/screens/previous_entries.dart';

import 'package:flutter_window_close/flutter_window_close.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.storage});

  final DiaryStorage storage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Settings>(
      valueListenable: App.settingsNotifier,
      builder: (_, Settings currentSettings, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Diary'),
            actions: [
              IconButton(
                onPressed: () => _openPreviousEntries(context),
                icon: const Icon(
                  Icons.list_outlined,
                ),
              ),
              IconButton(
                onPressed: () => _openSettings(context),
                icon: const Icon(
                  Icons.settings,
                ),
              ),
            ],
          ),
          body: EntryEditor(
            storage: storage,
            settings: currentSettings,
          ),
        );
      },
    );
  }

  _openPreviousEntries(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviousEntriesScreen(),
      ),
    );
  }

  _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}

class EntryEditor extends StatefulWidget {
  const EntryEditor({Key? key, required this.storage, required this.settings})
      : super(key: key);

  final DiaryStorage storage;
  final Settings settings;

  @override
  State<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<EntryEditor> with WidgetsBindingObserver {
  final _textController = TextEditingController();
  bool exiting = false;

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
    if (exiting) {
      return;
    }
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

  SpellCheckConfiguration? _getSpellChecker(Settings currentSettings) {
    if (Platform.isLinux) {
      return null;
    }
    if (!currentSettings.checkSpelling) {
      return null;
    }
    return SpellCheckConfiguration(
      spellCheckService: DefaultSpellCheckService(),
    );
  }

  keyPressed(RawKeyEvent key) {
    if (key.isKeyPressed(LogicalKeyboardKey.keyS) && key.isControlPressed) {
      _updateStorage();
    }
    if (key.isKeyPressed(LogicalKeyboardKey.keyQ) && key.isControlPressed) {
      FlutterWindowClose.closeWindow();
    }
  }

  Future<bool> saveBeforeExit() async {
    exiting = true;
    if (Platform.isAndroid || Platform.isIOS) {
      await _updateStorage();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: saveBeforeExit,
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: keyPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _textController,
            onChanged: _textChanged,
            expands: true,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            spellCheckConfiguration: _getSpellChecker(widget.settings),
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: widget.settings.fontSize),
            decoration:
                const InputDecoration.collapsed(hintText: "Start typing…"),
          ),
        ),
      ),
    );
  }
}
