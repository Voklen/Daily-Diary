import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/storage.dart';
import 'package:daily_diary/settings.dart';
import 'package:daily_diary/previous_entries_screen.dart';
import 'package:daily_diary/themes.dart';

void main() async {
  final settings = SettingsStorage();
  App.settingsNotifier.setTheme(await settings.getTheme());
  App.settingsNotifier.setFontSize(await settings.getFontSize());
  App.settingsNotifier.setColorScheme(await settings.getColorScheme());
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  static final SettingsNotifier settingsNotifier = SettingsNotifier(Settings());
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Settings>(
      valueListenable: settingsNotifier,
      builder: (_, Settings currentSettings, __) {
        final theme = Themes(currentSettings.colorScheme);
        return MaterialApp(
          title: 'Daily Diary',
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: currentSettings.theme,
          home: const HomePage(
            storage: DiaryStorage(),
          ),
        );
      },
    );
  }
}

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
              spellCheckConfiguration:
                  Platform.isLinux ? null : const SpellCheckConfiguration(),
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
