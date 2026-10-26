import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_quiz_flutter/screens/assignments_screen.dart';
import 'package:campus_quiz_flutter/screens/attendance_screen.dart';
import 'package:campus_quiz_flutter/screens/chat_screen.dart';
import 'package:campus_quiz_flutter/screens/clubs_screen.dart';
import 'package:campus_quiz_flutter/screens/events_screen.dart';
import 'package:campus_quiz_flutter/screens/landing_screen.dart';
import 'package:campus_quiz_flutter/screens/notice_board_screen.dart';
import 'package:campus_quiz_flutter/screens/profile_screen.dart';

void main() {
  setUpAll(() async {
    // Widget tests default to the Ahem font (one em per glyph), which makes
    // every text block far wider than the real typeface. Load the bundled
    // variable fonts so layout assertions measure realistically.
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

  testWidgets('landing screen builds without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingScreen()));
    await tester.pump();
    // Advance past the entrance animations (their delayed starts hold timers).
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat screen builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChatScreen())),
    );
    await tester.pump();
    // Advance past the entrance animations (their delayed starts hold timers).
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile screen builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileScreen())),
    );
    await tester.pump();
    // Advance past the entrance animations (their delayed starts hold timers).
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('notice board builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NoticeBoardScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('attendance builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AttendanceScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('events screen builds without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EventsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('assignments screen builds without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AssignmentsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('clubs screen builds without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ClubsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
  });
}
