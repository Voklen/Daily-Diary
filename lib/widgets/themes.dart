import 'package:flutter/material.dart';

class Themes {
  Themes(this.colorSeed);

  final Color colorSeed;

  ThemeData get lightTheme => ThemeData(
        colorSchemeSeed: colorSeed,
        brightness: Brightness.light,
      );

  ThemeData get darkTheme => ThemeData(
        colorSchemeSeed: colorSeed,
        brightness: Brightness.dark,
      );
}
