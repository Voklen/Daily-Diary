import 'package:flutter/material.dart';
import 'package:daily_diary/generated_localizations/app_localizations.dart';

/// Gets the `AppLocalizations` of the context, must only be called within a
/// app with `localizationsDelegates` or will crash. This is used for obtaining
/// a string that is in the language of the current context.
///
/// Example:
/// ```dart
/// Text(locale(context).helloWorld)
/// ```
AppLocalizations locale(BuildContext context) {
  return AppLocalizations.of(context)!;
}
