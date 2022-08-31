import 'dart:io';

import 'package:flutter/material.dart';
import 'package:daily_diary/storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Diary',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(
        storage: CounterStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.storage}) : super(key: key);

  final CounterStorage storage;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Diary'),
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
