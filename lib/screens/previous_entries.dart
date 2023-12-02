import 'package:daily_diary/backend_classes/path.dart';
import 'package:daily_diary/screens/home.dart';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/localization.dart';
import 'package:daily_diary/backend_classes/storage.dart';
import 'package:daily_diary/screens/view_only.dart';

class PreviousEntriesScreen extends StatelessWidget {
  PreviousEntriesScreen({super.key});

  final entries = PreviousEntriesStorage(savePath!);

  Widget _listBuilder(context, AsyncSnapshot<List<EntryFile>> snapshot) {
    List<EntryFile>? datesList = snapshot.data;
    if (datesList == null) {
      return const Scaffold();
    }
    if (datesList.isEmpty) {
      return const NoEntriesYet();
    }
    return ListView.builder(
      itemCount: datesList.length,
      itemBuilder: (_, index) => PreviousEntry(
        file: datesList[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(locale(context).previousEntries),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: entries.getFiles(),
          builder: _listBuilder,
        ),
      ),
    );
  }
}

class PreviousEntry extends StatelessWidget {
  const PreviousEntry({super.key, required this.file});

  final EntryFile file;

  @override
  Widget build(BuildContext context) {
    DateTime date = file.entryDate;
    if (date.isSameDate(DateTime.now())) {
      return Container();
    }
    final String humanDate = locale(context).entryDate(date);
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) {
              return ViewOnlyScreen(title: humanDate, entryFile: file);
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

class NoEntriesYet extends StatelessWidget {
  const NoEntriesYet({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Icon(Icons.sticky_note_2_outlined),
          Center(child: Text(locale(context).noEntriesYet)),
        ],
      ),
    );
  }
}
