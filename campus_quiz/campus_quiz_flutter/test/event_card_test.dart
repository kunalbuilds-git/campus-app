import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:campus_quiz_flutter/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  Widget buildCard(
    EventSummary summary, {
    RsvpStatus? myStatus,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: EventCard(
          summary: summary,
          myStatus: myStatus,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  testWidgets('shows the title, category, time, place and counts', (
    tester,
  ) async {
    final summary = buildSummary(
      buildEvent(title: 'Robotics Night'),
      goingCount: 3,
      interestedCount: 2,
    );

    await tester.pumpWidget(buildCard(summary));

    expect(find.text('Robotics Night'), findsOneWidget);
    expect(find.text('Tech'), findsOneWidget);
    expect(find.text('Tue, 27 Oct · 10:00–18:00'), findsOneWidget);
    expect(
      find.text('Engineering Hall, room 1 · The Robotics Club'),
      findsOneWidget,
    );
    expect(find.text('3 going · 2 interested'), findsOneWidget);
  });

  testWidgets('shows the student response when there is one', (tester) async {
    final summary = buildSummary(buildEvent(title: 'Robotics Night'));

    await tester.pumpWidget(buildCard(summary, myStatus: RsvpStatus.going));

    expect(find.text('Going'), findsOneWidget);
  });

  testWidgets('hides the response badge when the student has none', (
    tester,
  ) async {
    final summary = buildSummary(buildEvent(title: 'Robotics Night'));

    await tester.pumpWidget(buildCard(summary));

    expect(find.text('Going'), findsNothing);
    expect(find.text('Interested'), findsNothing);
  });

  testWidgets('calls onTap when the card is tapped', (tester) async {
    var tapped = false;
    final summary = buildSummary(buildEvent(title: 'Robotics Night'));

    await tester.pumpWidget(
      buildCard(
        summary,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Robotics Night'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
