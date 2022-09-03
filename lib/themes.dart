import 'package:flutter/material.dart';

class Themes {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.amber,
    brightness: Brightness.light,
  );

  static final darkTheme =
      ThemeData(colorSchemeSeed: Colors.amber, brightness: Brightness.dark);
}
