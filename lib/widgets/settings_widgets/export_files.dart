import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:daily_diary/main.dart';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_storage/shared_storage.dart';

class ExportData extends StatelessWidget {
  const ExportData({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _exportEntries,
      title: const Text('Export entries'),
      leading: const Icon(Icons.unarchive),
    );
  }

  void _exportEntries() async {
    String? outputDir = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Export file location');
    if (outputDir == null) return;
    final outputPath = '$outputDir/Daily-Diary-export.zip';

    if (savePath!.isScopedStorage) {
      final archive = await createArchiveFromDirectory(savePath!.uri!);
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) return;
      File(outputPath).writeAsBytes(zipBytes);
    } else {
      ZipFileEncoder()
          .zipDirectory(Directory(savePath!.path!), filename: outputPath);
    }
  }

  Future<Archive> createArchiveFromDirectory(Uri uri) async {
    Stream<DocumentFile> files = listFiles(uri, columns: [
      DocumentFileColumn.displayName,
      DocumentFileColumn.size,
    ]);

    final archive = Archive();

    await for (DocumentFile file in files) {
      if (file.isDirectory == true) continue;
      Uint8List? content = await file.getContent();
      if (content == null) continue;

      final archivedFile = ArchiveFile(file.name!, file.size!, content);
      archive.addFile(archivedFile);
    }

    return archive;
  }
}
