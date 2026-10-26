import 'package:campus_quiz_flutter/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  final event = buildEvent(title: 'Robotics Night');

  /// Opens the account screen on top of another route, so that it can be
  /// popped again.
  Future<void> openAccountScreen(
    WidgetTester tester, {
    required FakeEventsRepository events,
    required FakeAccountRepository accounts,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AccountScreen(
                    events: events,
                    accounts: accounts,
                  ),
                ),
              ),
              child: const Text('Open account'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open account'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the guest state and how many responses there are', (
    tester,
  ) async {
    final events = FakeEventsRepository(
      rsvps: [buildRsvp(eventId: event.id!, event: event)],
    );
    final accounts = FakeAccountRepository();

    await openAccountScreen(tester, events: events, accounts: accounts);

    expect(find.text('Browsing as a guest'), findsOneWidget);
    expect(
      find.textContaining('Your 1 response is saved to this device.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, 'Create an account with email'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Sign in with email'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Sign out'), findsNothing);
  });

  testWidgets('shows the email state and offers to sign out', (tester) async {
    final events = FakeEventsRepository();
    final accounts = FakeAccountRepository(hasEmail: true);

    await openAccountScreen(tester, events: events, accounts: accounts);

    expect(find.text('Signed in with your email address'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Sign out'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Create an account with email'),
      findsNothing,
    );
  });

  testWidgets('signs the student out and closes the screen', (tester) async {
    final events = FakeEventsRepository();
    final accounts = FakeAccountRepository(hasEmail: true);

    await openAccountScreen(tester, events: events, accounts: accounts);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(accounts.signedOut, isTrue);
    expect(find.text('Browsing as a guest'), findsNothing);
    expect(find.text('Open account'), findsOneWidget);
  });

  testWidgets('shows an error when the account cannot be loaded', (
    tester,
  ) async {
    final events = FakeEventsRepository()..error = Exception('offline');
    final accounts = FakeAccountRepository();

    await openAccountScreen(tester, events: events, accounts: accounts);

    expect(
      find.text('Could not load your account. Please try again.'),
      findsOneWidget,
    );
  });
}
