import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

/// Handles what happens when the user attempts to close the desktop window
/// On mobile using this class will have no effect
class QuitHandler {
  static enable(BuildContext context, void Function() saveAndQuit) {
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('You have unsaved changes'),
                actions: [
                  ElevatedButton(
                    onPressed: saveAndQuit,
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () => _quit(context),
                    child: const Text('Don’t save'),
                  ),
                  ElevatedButton(
                    onPressed: () => _cancel(context),
                    child: const Text('Cancel'),
                  ),
                ]);
          });
    });
  }

  static disable() {
    FlutterWindowClose.setWindowShouldCloseHandler(() async => true);
  }

  static _quit(BuildContext context) {
    Navigator.of(context).pop(true);
  }

  static _cancel(BuildContext context) {
    Navigator.of(context).pop(false);
  }
}
