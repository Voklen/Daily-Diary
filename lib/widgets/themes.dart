import 'package:flutter/material.dart';

class Themes {
  Themes(this.colorSeed);

  final Color colorSeed;

  ThemeData get _baseLightTheme => ThemeData(
        colorSchemeSeed: colorSeed,
        brightness: Brightness.light,
      );

  ThemeData get _baseDarkTheme => ThemeData(
        colorSchemeSeed: colorSeed,
        brightness: Brightness.dark,
      );

  ThemeData get lightTheme => ThemeData(
        colorSchemeSeed: colorSeed,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: _baseLightTheme.colorScheme.inversePrimary,
        ),
      );

  ThemeData get darkTheme => ThemeData(
        colorSchemeSeed: colorSeed,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: _baseDarkTheme.colorScheme.inversePrimary,
        ),
      );
}
