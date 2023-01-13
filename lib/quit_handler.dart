import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

class QuitHandler {
  static enable(BuildContext context) {
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Do you really want to quit?'),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes')),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No')),
                ]);
          });
    });
  }

  static disable() {
    FlutterWindowClose.setWindowShouldCloseHandler(() async => true);
  }
}
