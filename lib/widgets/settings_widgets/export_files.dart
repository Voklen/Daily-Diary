import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/localization.dart';

import 'package:file_picker/file_picker.dart';

class ExportData extends StatelessWidget {
  const ExportData({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _exportEntries,
      title: Text(locale(context).exportEntries),
      leading: const Icon(Icons.unarchive),
    );
  }

  void _exportEntries() async {
    String? outputDir = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Export file location');
    if (outputDir == null) return;
    final outputPath = '$outputDir/Daily-Diary-export.zip';
    savePath!.zipTo(outputPath);
  }
}
