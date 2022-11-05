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
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            List<String> fileList = snapshot.data ?? [];
            return ListView.builder(
              itemCount: fileList.length,
              itemBuilder: (context, index) {
                String filename = fileList[index];
                final format = Theme.of(context).textTheme.bodyMedium;
                return ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.background),
                  child: Text(
                    filename,
                    style: format,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
