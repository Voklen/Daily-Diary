import 'dart:io';
import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/localization.dart';

import 'package:flutter_window_close/flutter_window_close.dart';

/// Handles what happens when the user attempts to close the desktop window
/// On mobile using this class will have no effect
class QuitHandler {
  static void enable(BuildContext context, void Function() saveAndQuit) {
    if (Platform.isAndroid || Platform.isIOS) return;
    FlutterWindowClose.setWindowShouldCloseHandler(
      () => _show(context, saveAndQuit),
    );
  }

  static Future<bool> _show(
    BuildContext context,
    void Function() saveAndQuit,
  ) async {
    final bool? result = await showDialog(
      context: context,
      builder: (_) => UnsavedChangesAlert(saveAndQuit),
    );
    // Cannot be null because when we close the dialog in [UnsavedChangesAlert]
    // we always pass a bool to [Navigator.pop]
    return result!;
  }
}

class UnsavedChangesAlert extends StatelessWidget {
  const UnsavedChangesAlert(this.saveAndQuit, {super.key});

  final void Function() saveAndQuit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(locale(context).unsavedChanges),
      actions: [
        ElevatedButton(
          onPressed: saveAndQuit,
          child: Text(locale(context).save),
        ),
        ElevatedButton(
          onPressed: () => _quit(context),
          child: Text(locale(context).discardChanges),
        ),
        ElevatedButton(
          onPressed: () => _cancel(context),
          child: Text(locale(context).cancel),
        ),
      ],
    );
  }

  static void disable() {
    if (Platform.isAndroid || Platform.isIOS) return;
    FlutterWindowClose.setWindowShouldCloseHandler(() async => true);
  }

  static void _quit(BuildContext context) {
    Navigator.of(context).pop(true);
  }

  static void _cancel(BuildContext context) {
    Navigator.of(context).pop(false);
  }
}
