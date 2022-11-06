import 'package:daily_diary/storage.dart';
import 'package:flutter/material.dart';

class PreviousEntriesScreen extends StatelessWidget {
  const PreviousEntriesScreen({super.key});

  final entries = const PreviousEntriesStorage();

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
              reverse: true,
              itemBuilder: (context, index) {
                String filename = fileList[index];
                final format = Theme.of(context).textTheme.bodyMedium;
                return ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.background,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      filename,
                      style: format,
                      textAlign: TextAlign.start,
                    ),
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