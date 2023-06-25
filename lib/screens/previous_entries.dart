import 'package:daily_diary/screens/home.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/storage.dart';
import 'package:daily_diary/screens/view_only.dart';

class PreviousEntriesScreen extends StatelessWidget {
  PreviousEntriesScreen({super.key});

  final entries = PreviousEntriesStorage(savePath!);

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
            datesList.sort((b, a) => a.compareTo(b));
            return ListView.builder(
              itemCount: datesList.length,
              itemBuilder: (_, index) => PreviousEntry(
                date: datesList[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PreviousEntry extends StatelessWidget {
  const PreviousEntry({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    if (date.isSameDate(DateTime.now())) {
      return Container();
    }
    final String humanDate = DateFormat.yMMMd().format(date);
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              String filename = DiaryStorage.dateToFilename(date);
              final storage = PreviousEntryStorage(filename, savePath!);
              return ViewOnlyScreen(title: humanDate, storage: storage);
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
  }
}
