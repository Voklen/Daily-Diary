import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/backend_classes/storage.dart';

void main() {
  group('fromHex', fromHexTests);
  group('toHex', toHexTests);
}

void fromHexTests() {
  test('White uppercase', () async {
    Color? white = HexColor.fromHex('#FFFFFF');
    expect(white, isNotNull);
    white!;
    expect(white.r, closeTo(1, 0.001));
    expect(white.g, closeTo(1, 0.001));
    expect(white.b, closeTo(1, 0.001));
  });

  test('White lowercase', () async {
    Color? white = HexColor.fromHex('#ffffff');
    expect(white, isNotNull);
    white!;
    expect(white.r, closeTo(1, 0.001));
    expect(white.g, closeTo(1, 0.001));
    expect(white.b, closeTo(1, 0.001));
  });

  test('Black', () async {
    Color? black = HexColor.fromHex('#000000');
    expect(black, isNotNull);
    black!;
    expect(black.r, closeTo(0, 0.001));
    expect(black.g, closeTo(0, 0.001));
    expect(black.b, closeTo(0, 0.001));
  });

  test('Purple', () async {
    Color? purple = HexColor.fromHex('#9855d3');
    expect(purple, isNotNull);
    purple!;
    expect(purple.r, closeTo(0.596, 0.001));
    expect(purple.g, closeTo(0.333, 0.001));
    expect(purple.b, closeTo(0.827, 0.001));
  });

  test('Invalid string', () async {
    Color? nothing = HexColor.fromHex('zzz');
    expect(nothing, isNull);
  });
}

void toHexTests() {
  test('White', () async {
    const white = Color.fromARGB(255, 255, 255, 255);
    expect(white.toHex(), '#ffffff');
  });

  test('Black', () async {
    const black = Color.fromARGB(255, 0, 0, 0);
    expect(black.toHex(), '#000000');
  });

  test('Purple', () async {
    const purple = Color.fromARGB(255, 152, 85, 211);
    expect(purple.toHex(), '#9855d3');
  });
}
