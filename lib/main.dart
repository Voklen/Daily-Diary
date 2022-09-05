import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/storage.dart';
import 'package:daily_diary/settings.dart';
import 'package:daily_diary/themes.dart';

void main() async {
  final settings = SettingsStorage();
  MyApp.themeNotifier.value = await settings.getTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            title: 'Daily Diary',
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            themeMode: currentMode,
            home: MyHomePage(
              storage: DiaryStorage(),
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.storage}) : super(key: key);

  final DiaryStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((value) {
      setState(() {
        _textController.text = value;
      });
    });
  }

  Future<File> _updateStorage() {
    return widget.storage.writeFile(_textController.text);
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Diary'),
        actions: <Widget>[
          IconButton(
              onPressed: _openSettings,
              icon: const Icon(
                Icons.settings,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: _textController,
          expands: true,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration:
              const InputDecoration.collapsed(hintText: "Start typing…"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateStorage,
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ),
    );
  }
}
