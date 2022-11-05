import 'package:daily_diary/storage.dart';
import 'package:flutter/material.dart';

class PreviousEntriesScreen extends StatelessWidget {
  PreviousEntriesScreen({super.key});

  final entries = PreviousEntriesStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: entries.getFiles(),
          builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
            List<Widget> fileList = snapshot.data ?? [];
            return ListView(
              children: fileList,
            );
          },
        ),
      ),
    );
  }
}
