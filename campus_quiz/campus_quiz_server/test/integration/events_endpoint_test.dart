import 'package:campus_quiz_server/src/events/event_seeder.dart';
import 'package:campus_quiz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the events endpoint', (sessionBuilder, endpoints) {
    late Session session;

    setUp(() {
      session = sessionBuilder.build();
    });

    Future<Event> insertEvent({
      required String title,
      EventCategory category = EventCategory.community,
      int? capacity,
      DateTime? startsAt,
      DateTime? endsAt,
    }) async {
      final now = DateTime.now();
      return Event.db.insertRow(
        session,
        Event(
          title: title,
          description: 'Description of $title',
          startsAt: startsAt ?? now.add(const Duration(days: 1)),
          endsAt: endsAt ?? now.add(const Duration(days: 1, hours: 2)),
          location: 'Main Hall',
          organizer: 'Test Club',
          capacity: capacity,
          category: category,
        ),
      );
    }

    TestSessionBuilder signedInAs(String userIdentifier) {
      return sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          userIdentifier,
          {},
        ),
      );
    }

    group('listing events', () {
      test(
        'when listing without options then upcoming events are returned by '
        'default',
        () async {
          await insertEvent(title: 'Upcoming event');
          await insertEvent(
            title: 'Past event',
            startsAt: DateTime.now().subtract(const Duration(days: 2)),
            endsAt: DateTime.now().subtract(const Duration(days: 1)),
          );

          final events = await endpoints.events.listEvents(sessionBuilder);

          expect(events, hasLength(1));
          expect(events.single.event.title, 'Upcoming event');
        },
      );

      test(
        'when listing events then only upcoming events are returned',
        () async {
          await insertEvent(title: 'Upcoming event');
          await insertEvent(
            title: 'Past event',
            startsAt: DateTime.now().subtract(const Duration(days: 2)),
            endsAt: DateTime.now().subtract(const Duration(days: 1)),
          );

          final events = await endpoints.events.listEvents(
            sessionBuilder,
            upcomingOnly: true,
            limit: 50,
          );

          expect(events, hasLength(1));
          expect(events.single.event.title, 'Upcoming event');
          expect(events.single.goingCount, 0);
          expect(events.single.interestedCount, 0);
        },
      );

      test('when listing past events then ended events are included', () async {
        await insertEvent(
          title: 'Past event',
          startsAt: DateTime.now().subtract(const Duration(days: 2)),
          endsAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final events = await endpoints.events.listEvents(
          sessionBuilder,
          upcomingOnly: false,
          limit: 50,
        );

        expect(events, hasLength(1));
        expect(events.single.event.title, 'Past event');
      });

      test(
        'when listing with a category then only that category is returned',
        () async {
          await insertEvent(title: 'Tech event', category: EventCategory.tech);
          await insertEvent(
            title: 'Sports event',
            category: EventCategory.sports,
          );

          final events = await endpoints.events.listEvents(
            sessionBuilder,
            category: 'tech',
            upcomingOnly: true,
            limit: 50,
          );

          expect(events, hasLength(1));
          expect(events.single.event.title, 'Tech event');
        },
      );

      test('when listing with an unknown category then an invalid category '
          'error is thrown', () async {
        await insertEvent(title: 'Tech event', category: EventCategory.tech);

        expect(
          () => endpoints.events.listEvents(
            sessionBuilder,
            category: 'not-a-category',
            upcomingOnly: true,
            limit: 50,
          ),
          throwsA(
            isA<EventException>().having(
              (e) => e.code,
              'code',
              'EVENT_INVALID_CATEGORY',
            ),
          ),
        );
      });

      test('when listing with a limit then at most that many events are '
          'returned', () async {
        await insertEvent(title: 'First event');
        await insertEvent(title: 'Second event');
        await insertEvent(title: 'Third event');

        final events = await endpoints.events.listEvents(
          sessionBuilder,
          upcomingOnly: true,
          limit: 2,
        );

        expect(events, hasLength(2));
      });
    });

    group('reading a single event', () {
      test(
        'when the event exists then it is returned with its counts',
        () async {
          final event = await insertEvent(title: 'Opening ceremony');

          final summary = await endpoints.events.getEvent(
            sessionBuilder,
            event.id!,
          );

          expect(summary.event.title, 'Opening ceremony');
          expect(summary.goingCount, 0);
          expect(summary.interestedCount, 0);
        },
      );

      test(
        'when the event does not exist then a not found error is thrown',
        () async {
          final missingId = Uuid().v4obj();

          expect(
            () => endpoints.events.getEvent(sessionBuilder, missingId),
            throwsA(
              isA<EventException>().having(
                (e) => e.code,
                'code',
                'EVENT_NOT_FOUND',
              ),
            ),
          );
        },
      );
    });

    group('rsvping', () {
      test('when the user is not signed in then an unauthenticated error is '
          'thrown', () async {
        final event = await insertEvent(title: 'Opening ceremony');

        expect(
          () =>
              endpoints.events.rsvp(sessionBuilder, event.id!, status: 'going'),
          throwsA(
            isA<EventException>().having(
              (e) => e.code,
              'code',
              'UNAUTHENTICATED',
            ),
          ),
        );
      });

      test('when a signed-in user rsvps without a status then it defaults to '
          'going', () async {
        final event = await insertEvent(title: 'Opening ceremony');

        final rsvp = await endpoints.events.rsvp(
          signedInAs('user-1'),
          event.id!,
        );

        expect(rsvp.status, RsvpStatus.going);
      });

      test('when a signed-in user rsvps then the RSVP is created', () async {
        final event = await insertEvent(title: 'Opening ceremony');
        final user = signedInAs('user-1');

        final rsvp = await endpoints.events.rsvp(
          user,
          event.id!,
          status: 'going',
        );

        expect(rsvp.authUserId, 'user-1');
        expect(rsvp.status, RsvpStatus.going);

        final summary = await endpoints.events.getEvent(
          sessionBuilder,
          event.id!,
        );
        expect(summary.goingCount, 1);
      });

      test(
        'when a signed-in user rsvps twice then only one RSVP exists',
        () async {
          final event = await insertEvent(title: 'Opening ceremony');
          final user = signedInAs('user-1');

          final first = await endpoints.events.rsvp(
            user,
            event.id!,
            status: 'going',
          );
          final second = await endpoints.events.rsvp(
            user,
            event.id!,
            status: 'going',
          );

          expect(second.id, first.id);

          final summary = await endpoints.events.getEvent(
            sessionBuilder,
            event.id!,
          );
          expect(summary.goingCount, 1);
        },
      );

      test('when a signed-in user changes their status then the RSVP is '
          'updated', () async {
        final event = await insertEvent(title: 'Opening ceremony');
        final user = signedInAs('user-1');

        await endpoints.events.rsvp(user, event.id!, status: 'going');
        final updated = await endpoints.events.rsvp(
          user,
          event.id!,
          status: 'interested',
        );

        expect(updated.status, RsvpStatus.interested);

        final summary = await endpoints.events.getEvent(
          sessionBuilder,
          event.id!,
        );
        expect(summary.goingCount, 0);
        expect(summary.interestedCount, 1);
      });

      test(
        'when the status is unknown then an invalid status error is thrown',
        () async {
          final event = await insertEvent(title: 'Opening ceremony');
          final user = signedInAs('user-1');

          expect(
            () => endpoints.events.rsvp(user, event.id!, status: 'maybe'),
            throwsA(
              isA<EventException>().having(
                (e) => e.code,
                'code',
                'RSVP_INVALID_STATUS',
              ),
            ),
          );
        },
      );

      test('when the event has ended then rsvping is rejected', () async {
        final event = await insertEvent(
          title: 'Past event',
          startsAt: DateTime.now().subtract(const Duration(days: 2)),
          endsAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        final user = signedInAs('user-1');

        expect(
          () => endpoints.events.rsvp(user, event.id!, status: 'going'),
          throwsA(
            isA<EventException>().having((e) => e.code, 'code', 'EVENT_ENDED'),
          ),
        );
      });

      test('when the event is full then rsvping is rejected', () async {
        final event = await insertEvent(title: 'Small workshop', capacity: 1);

        await endpoints.events.rsvp(
          signedInAs('user-1'),
          event.id!,
          status: 'going',
        );

        expect(
          () => endpoints.events.rsvp(
            signedInAs('user-2'),
            event.id!,
            status: 'going',
          ),
          throwsA(
            isA<EventException>().having(
              (e) => e.code,
              'code',
              'EVENT_CAPACITY_REACHED',
            ),
          ),
        );
      });

      test(
        'when the event is full then an interested rsvp is still allowed',
        () async {
          final event = await insertEvent(title: 'Small workshop', capacity: 1);

          await endpoints.events.rsvp(
            signedInAs('user-1'),
            event.id!,
            status: 'going',
          );
          final rsvp = await endpoints.events.rsvp(
            signedInAs('user-2'),
            event.id!,
            status: 'interested',
          );

          expect(rsvp.status, RsvpStatus.interested);
        },
      );

      test('when a user cancels then the RSVP is removed', () async {
        final event = await insertEvent(title: 'Opening ceremony');
        final user = signedInAs('user-1');

        await endpoints.events.rsvp(user, event.id!, status: 'going');
        await endpoints.events.cancelRsvp(user, event.id!);

        final summary = await endpoints.events.getEvent(
          sessionBuilder,
          event.id!,
        );
        expect(summary.goingCount, 0);
      });

      test('when a user cancels without an RSVP then nothing fails', () async {
        final event = await insertEvent(title: 'Opening ceremony');

        await expectLater(
          endpoints.events.cancelRsvp(signedInAs('user-1'), event.id!),
          completes,
        );
      });
    });

    group('listing my rsvps', () {
      test('when the user is not signed in then an unauthenticated error is '
          'thrown', () async {
        expect(
          () => endpoints.events.myRsvps(sessionBuilder),
          throwsA(
            isA<EventException>().having(
              (e) => e.code,
              'code',
              'UNAUTHENTICATED',
            ),
          ),
        );
      });

      test('when the user has rsvped then the rsvps are returned with the '
          'event', () async {
        final event = await insertEvent(title: 'Opening ceremony');
        final user = signedInAs('user-1');

        await endpoints.events.rsvp(user, event.id!, status: 'going');
        final rsvps = await endpoints.events.myRsvps(user);

        expect(rsvps, hasLength(1));
        expect(rsvps.single.eventId, event.id);
        expect(rsvps.single.event?.title, 'Opening ceremony');
      });

      test(
        'when another user has rsvped then their rsvps are not returned',
        () async {
          final event = await insertEvent(title: 'Opening ceremony');

          await endpoints.events.rsvp(
            signedInAs('user-2'),
            event.id!,
            status: 'going',
          );
          final rsvps = await endpoints.events.myRsvps(signedInAs('user-1'));

          expect(rsvps, isEmpty);
        },
      );
    });

    group('seeding', () {
      test(
        'when the event table is empty then the sample events are inserted',
        () async {
          final inserted = await EventSeeder.seedIfEmptyInSession(session);

          expect(inserted, greaterThan(0));
          expect(await Event.db.count(session), inserted);
        },
      );

      test('when events already exist then nothing is inserted', () async {
        await insertEvent(title: 'Existing event');

        final inserted = await EventSeeder.seedIfEmptyInSession(session);

        expect(inserted, 0);
        expect(await Event.db.count(session), 1);
      });
    });
  });
}
