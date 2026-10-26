import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:campus_quiz_flutter/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  final event = buildEvent(title: 'Robotics Night', capacity: 50);

  Widget buildScreen(
    FakeEventsRepository events, {
    RsvpStatus? initialMyStatus,
  }) {
    return MaterialApp(
      home: EventDetailScreen(
        eventId: event.id!,
        initialMyStatus: initialMyStatus,
        events: events,
      ),
    );
  }

  testWidgets('shows the event details', (tester) async {
    final events = FakeEventsRepository(
      summaries: [buildSummary(event, goingCount: 7, interestedCount: 1)],
    );

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    expect(find.text('Robotics Night'), findsOneWidget);
    expect(find.text('Tech'), findsOneWidget);
    expect(find.text('Tue, 27 Oct · 10:00–18:00'), findsOneWidget);
    expect(find.text('Engineering Hall, room 1'), findsOneWidget);
    expect(find.text('The Robotics Club'), findsOneWidget);
    expect(find.text('7 going · 1 interested · capacity 50'), findsOneWidget);
    expect(find.text('An evening with the robotics club.'), findsOneWidget);
  });

  testWidgets('saves a response when the student picks one', (tester) async {
    final events = FakeEventsRepository(summaries: [buildSummary(event)]);

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Going'));
    await tester.pumpAndSettle();

    expect(events.rsvpCalls, [event.id]);
    expect(find.text('Your response: Going'), findsOneWidget);
  });

  testWidgets('changes an existing response', (tester) async {
    final events = FakeEventsRepository(summaries: [buildSummary(event)]);

    await tester.pumpWidget(
      buildScreen(
        events,
        initialMyStatus: RsvpStatus.going,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Interested'));
    await tester.pumpAndSettle();

    expect(events.rsvpCalls, [event.id]);
    expect(find.text('Your response: Interested'), findsOneWidget);
  });

  testWidgets('cancels the response', (tester) async {
    final events = FakeEventsRepository(summaries: [buildSummary(event)]);

    await tester.pumpWidget(
      buildScreen(
        events,
        initialMyStatus: RsvpStatus.going,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cancel my response'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel my response'));
    await tester.pumpAndSettle();

    expect(events.cancelRsvpCalls, [event.id]);
    expect(find.text('Will you attend?'), findsOneWidget);
  });

  testWidgets('shows an error when the event cannot be loaded', (tester) async {
    final events = FakeEventsRepository()..error = Exception('offline');

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load this event. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('does not offer a response for an event that has ended', (
    tester,
  ) async {
    final ended = buildEvent(
      title: 'Past Event',
      startsAt: DateTime(2020, 1, 1, 10),
      endsAt: DateTime(2020, 1, 1, 12),
      id: '00000000-0000-4000-8000-000000000003',
    );
    final events = FakeEventsRepository(summaries: [buildSummary(ended)]);

    await tester.pumpWidget(
      MaterialApp(
        home: EventDetailScreen(eventId: ended.id!, events: events),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ended'), findsOneWidget);

    final button = tester.widget<SegmentedButton<RsvpStatus>>(
      find.byType(SegmentedButton<RsvpStatus>),
    );
    expect(button.onSelectionChanged, isNull);
  });
}
