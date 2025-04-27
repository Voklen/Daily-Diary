import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/backend_classes/settings_notifier.dart';
import 'package:daily_diary/backend_classes/storage.dart';
import 'package:daily_diary/widgets/quit_handler.dart';
import 'package:daily_diary/screens/settings.dart';
import 'package:daily_diary/screens/previous_entries.dart';

import 'package:flutter_window_close/flutter_window_close.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.child});

  final EntryEditor child;

  @override
  Widget build(BuildContext context) {
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
      body: child,
    );
  }

  void _openPreviousEntries(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PreviousEntriesScreen(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}

/// The main diary entry editing field, made for editing today's entry
class EntryEditor extends StatefulWidget {
  const EntryEditor({
    super.key,
    required this.storage,
    required this.settings,
  });

  final DiaryStorage storage;
  final Settings settings;

  @override
  State<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<EntryEditor> with WidgetsBindingObserver {
  final _textController = TextEditingController();
  bool loaded = false;

  @override
  initState() {
    super.initState();

    UnsavedChangesAlert.disable();
    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
    widget.storage.readFile().then((value) {
      setState(() {
        _textController.text = value;
        loaded = true;
      });
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      _updateStorage();
    }
    resetIfNewDay();
  }

  void _loadSettings() {
    App.settingsNotifier.setFontSizeFromFile();
  }

  void _updateStorage() {
    if (!loaded) return;
    UnsavedChangesAlert.disable();
    widget.storage.writeFile(_textController.text);
  }

  void _textChanged(_) async {
    QuitHandler.enable(context, _saveAndQuit);
  }

  void _saveAndQuit() {
    _updateStorage();
    Navigator.of(context).pop(true);
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

  void keyPressed(KeyEvent key) {
    if (key.logicalKey == LogicalKeyboardKey.keyS &&
        HardwareKeyboard.instance.isControlPressed) {
      _updateStorage();
    }
    if (key.logicalKey == LogicalKeyboardKey.keyQ &&
        HardwareKeyboard.instance.isControlPressed) {
      FlutterWindowClose.closeWindow();
    }
  }

  void resetIfNewDay() {
    DateTime startWriting = widget.storage.date;
    DateTime now = DateTime.now();
    if (startWriting.isSameDate(now)) return;

    widget.storage.recalculateDate();
    widget.storage.readFile().then((value) {
      setState(() {
        _textController.text = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: keyPressed,
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
          decoration: InputDecoration.collapsed(
            hintText: locale(context).startTyping,
          ),
        ),
      ),
    );
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
