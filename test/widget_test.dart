import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_diary/main.dart';
import 'package:daily_diary/backend_classes/path.dart';

import 'SettingsStorageMock.dart';

void main() {
  savePath = const SavePath.normal('');
  newSavePath = savePath;

  testWidgets('Navigation', (WidgetTester tester) async {
    await tester.pumpWidget(await SettingsProvider.create(
      storage: MockSettingsStorage(),
      child: const App(),
    ));

    expect(find.text('Daily Diary'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    expect(find.text('Daily Diary'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.list_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Previous Entries'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    expect(find.text('Daily Diary'), findsOneWidget);
  });
}
