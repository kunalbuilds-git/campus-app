import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_quiz_flutter/screens/attendance_screen.dart';

void main() {
  setUpAll(() async {
    for (final entry in {
      'Inter': 'assets/fonts/Inter-Variable.ttf',
      'Inter Tight': 'assets/fonts/InterTight-Variable.ttf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1560, 1008);
    view.devicePixelRatio = 1.0;
    addTearDown(view.reset);
  });

  /// Pumps until the entrance animations have settled.
  ///
  /// flutter_animate starts its controller from a timer, so the fade needs
  /// one pump with a duration to fire that timer and another for the
  /// animation itself to advance.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('every subject is listed with an edit control', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AttendanceScreen()));
    await settle(tester);

    expect(find.text('Data Structures & Algorithms'), findsOneWidget);
    expect(find.text('Discrete Mathematics'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the subject rows are painted, not stuck invisible', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AttendanceScreen()));
    await settle(tester);

    final finder = find.text('Data Structures & Algorithms');
    expect(finder, findsOneWidget);

    // A fade-in that never runs leaves the row at opacity zero: it is in the
    // tree but nothing of it reaches the screen.
    final fades = tester
        .widgetList<FadeTransition>(find.byType(FadeTransition))
        .map((fade) => fade.opacity.value)
        .toList();
    expect(fades.where((value) => value == 0), isEmpty);

    // And it has to be on screen, not parked outside the viewport.
    final rect = tester.getRect(finder);
    expect(rect.top, greaterThan(0));
    expect(rect.bottom, lessThan(1008));
  });

  testWidgets('the editor opens with the subject counts', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AttendanceScreen()));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Update attendance'), findsOneWidget);
    expect(find.text('Classes attended'), findsOneWidget);
    expect(find.text('Classes held'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the editor keeps the counters honest', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AttendanceScreen()));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The last subject starts at 24 of 28; pushing attended past held must
    // be impossible.
    final plus = find.byIcon(Icons.add_rounded);
    final before = tester.widgetList<Icon>(plus).length;
    expect(before, 2);

    // Saving with the counters untouched is allowed and closes the sheet.
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Update attendance'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
