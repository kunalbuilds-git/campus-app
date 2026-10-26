import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:campus_quiz_flutter/screens/events_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  final event = buildEvent(title: 'Robotics Night');
  final otherEvent = buildEvent(
    title: 'Campus Football',
    category: EventCategory.sports,
    id: '00000000-0000-4000-8000-000000000002',
  );

  Widget buildScreen(FakeEventsRepository events) {
    return MaterialApp(home: EventsHomeScreen(events: events));
  }

  testWidgets('lists the upcoming events', (tester) async {
    final events = FakeEventsRepository(
      summaries: [
        buildSummary(event, goingCount: 4),
        buildSummary(otherEvent),
      ],
    );

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    expect(find.text('Robotics Night'), findsOneWidget);
    expect(find.text('Campus Football'), findsOneWidget);
    expect(find.text('4 going · 0 interested'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no events', (tester) async {
    final events = FakeEventsRepository();

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No upcoming events here yet.\n'
        'Check another category or come back later.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an error with a retry button', (tester) async {
    final events = FakeEventsRepository()..error = Exception('offline');

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load events. Please try again.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('asks the backend for the selected category', (tester) async {
    final events = FakeEventsRepository(
      summaries: [
        buildSummary(event),
        buildSummary(otherEvent),
      ],
    );

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Sports'));
    await tester.pumpAndSettle();

    expect(events.listEventsCalls, [null, 'sports']);
    expect(find.text('Campus Football'), findsOneWidget);
    expect(find.text('Robotics Night'), findsNothing);
  });

  testWidgets('opens the detail screen of the tapped event', (tester) async {
    final events = FakeEventsRepository(summaries: [buildSummary(event)]);

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Robotics Night'));
    await tester.pumpAndSettle();

    expect(find.text('Event details'), findsOneWidget);
    expect(find.text('An evening with the robotics club.'), findsOneWidget);
  });

  testWidgets('lists the events the student responded to', (tester) async {
    final events = FakeEventsRepository(
      summaries: [buildSummary(event)],
      rsvps: [
        buildRsvp(
          eventId: event.id!,
          status: RsvpStatus.interested,
          event: event,
        ),
      ],
    );

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Events'));
    await tester.pumpAndSettle();

    expect(find.text('Robotics Night'), findsOneWidget);
    expect(find.text('Interested'), findsOneWidget);
  });

  testWidgets('cancels a response from the My Events tab', (tester) async {
    final events = FakeEventsRepository(
      summaries: [buildSummary(event)],
      rsvps: [buildRsvp(eventId: event.id!, event: event)],
    );

    await tester.pumpWidget(buildScreen(events));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Events'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(events.cancelRsvpCalls, [event.id]);
  });
}
