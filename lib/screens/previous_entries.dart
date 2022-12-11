import 'package:daily_diary/storage.dart';
import 'package:daily_diary/screens/view_only.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class PreviousEntriesScreen extends StatelessWidget {
  const PreviousEntriesScreen({super.key});

  final entries = const PreviousEntriesStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previous Entries')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: entries.getFiles(),
          builder: (context, AsyncSnapshot<List<DateTime>> snapshot) {
            List<DateTime> datesList = snapshot.data ?? [];
            return ListView.builder(
              itemCount: datesList.length,
              itemBuilder: (context, index) {
                DateTime date = datesList[index];
                String humanDate = DateFormat.yMMMd().format(date);
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          String filename =
                              date.toIso8601String().substring(0, 10);
                          final storage = PreviousEntryStorage(filename);
                          return ViewOnlyScreen(
                              title: humanDate, storage: storage);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.background,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      humanDate,
                      style: Theme.of(context).textTheme.bodyMedium,
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
