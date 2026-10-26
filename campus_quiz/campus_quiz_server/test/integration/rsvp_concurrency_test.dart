import 'package:campus_quiz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Runs [action] and returns the exception it threw, or null when it
/// succeeded. Used to collect the outcome of many parallel calls without
/// letting the first failure cancel the others.
Future<Object?> outcome<T>(Future<T> Function() action) async {
  try {
    await action();
    return null;
  } catch (error) {
    return error;
  }
}

void main() {
  // The default test setup puts every session of a test group into one
  // shared transaction that is rolled back after each test. That is what
  // keeps the other tests isolated, but it also means the calls below would
  // run one after another on a single connection and the race they are
  // meant to expose would never happen.
  //
  // Rolling back is therefore disabled for this group. The group gets its
  // own ephemeral database that is dropped when the group ends, so the rows
  // these tests commit do not leak into anything else.
  withServerpod(
    'Given concurrent RSVP requests',
    (sessionBuilder, endpoints) {
      late Session setupSession;

      setUp(() {
        setupSession = sessionBuilder.build();
      });

      tearDown(() async {
        // Remove the events of this test. The RSVPs are removed with them,
        // because the relation cascades on delete.
        await Event.db.deleteWhere(
          setupSession,
          where: (t) => Constant.bool(true),
        );
      });

      TestSessionBuilder signedInAs(String userIdentifier) {
        return sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            userIdentifier,
            {},
          ),
        );
      }

      Future<Event> insertEvent({
        required String title,
        int? capacity,
      }) async {
        final now = DateTime.now();
        return Event.db.insertRow(
          setupSession,
          Event(
            title: title,
            description: 'Description of $title',
            startsAt: now.add(const Duration(days: 1)),
            endsAt: now.add(const Duration(days: 1, hours: 2)),
            location: 'Main Hall',
            organizer: 'Test Club',
            capacity: capacity,
            category: EventCategory.community,
          ),
        );
      }

      group('capacity', () {
        test(
          'when more users than seats rsvp at the same time then only the '
          'number of seats is given out',
          () async {
            const capacity = 3;
            const contenders = 12;

            final event = await insertEvent(
              title: 'Small workshop',
              capacity: capacity,
            );

            // Every call is started before any of them is awaited, so they
            // all reach the database together.
            final results = await Future.wait([
              for (var i = 0; i < contenders; i++)
                outcome(
                  () => endpoints.events.rsvp(
                    signedInAs('user-$i'),
                    event.id!,
                    status: 'going',
                  ),
                ),
            ]);

            final failures = results.where((result) => result != null).toList();

            expect(failures, hasLength(contenders - capacity));
            for (final failure in failures) {
              expect(
                failure,
                isA<EventException>().having(
                  (e) => e.code,
                  'code',
                  'EVENT_CAPACITY_REACHED',
                ),
              );
            }

            final summary = await endpoints.events.getEvent(
              sessionBuilder,
              event.id!,
            );
            expect(summary.goingCount, capacity);
            expect(
              await Rsvp.db.count(
                setupSession,
                where: (t) => t.eventId.equals(event.id!),
              ),
              capacity,
            );
          },
        );

        test(
          'when a user who is already going rsvps again while the event is '
          'full then the rsvp succeeds',
          () async {
            const capacity = 1;
            final event = await insertEvent(
              title: 'Small workshop',
              capacity: capacity,
            );

            final first = await endpoints.events.rsvp(
              signedInAs('user-1'),
              event.id!,
              status: 'going',
            );

            final failure = await outcome(
              () => endpoints.events.rsvp(
                signedInAs('user-2'),
                event.id!,
                status: 'going',
              ),
            );
            expect(
              failure,
              isA<EventException>().having(
                (e) => e.code,
                'code',
                'EVENT_CAPACITY_REACHED',
              ),
            );

            // The user who holds the seat keeps it.
            final again = await endpoints.events.rsvp(
              signedInAs('user-1'),
              event.id!,
              status: 'going',
            );
            expect(again.id, first.id);
          },
        );

        test(
          'when a user who is only interested tries to switch to going while '
          'the event is full then the switch is rejected',
          () async {
            const capacity = 1;
            final event = await insertEvent(
              title: 'Small workshop',
              capacity: capacity,
            );

            // Interested attendees do not take up a seat.
            await endpoints.events.rsvp(
              signedInAs('user-1'),
              event.id!,
              status: 'interested',
            );
            await endpoints.events.rsvp(
              signedInAs('user-2'),
              event.id!,
              status: 'going',
            );

            final failure = await outcome(
              () => endpoints.events.rsvp(
                signedInAs('user-1'),
                event.id!,
                status: 'going',
              ),
            );
            expect(
              failure,
              isA<EventException>().having(
                (e) => e.code,
                'code',
                'EVENT_CAPACITY_REACHED',
              ),
            );

            final summary = await endpoints.events.getEvent(
              sessionBuilder,
              event.id!,
            );
            expect(summary.goingCount, 1);
            expect(summary.interestedCount, 1);
          },
        );

        test(
          'when a user cancels while others rsvp then the seat they free is '
          'given to one of them',
          () async {
            const capacity = 1;
            final event = await insertEvent(
              title: 'Small workshop',
              capacity: capacity,
            );

            await endpoints.events.rsvp(
              signedInAs('user-1'),
              event.id!,
              status: 'going',
            );

            final results = await Future.wait([
              outcome(
                () => endpoints.events.cancelRsvp(signedInAs('user-1'), event.id!),
              ),
              for (var i = 0; i < 4; i++)
                outcome(
                  () => endpoints.events.rsvp(
                    signedInAs('user-${i + 2}'),
                    event.id!,
                    status: 'going',
                  ),
                ),
            ]);

            // The cancel itself must not fail.
            expect(results.first, isNull);

            // Exactly one seat exists, so exactly one of the contenders can
            // hold it, no matter how the calls interleave.
            final summary = await endpoints.events.getEvent(
              sessionBuilder,
              event.id!,
            );
            expect(summary.goingCount, 1);
          },
        );
      });

      group('duplicate requests', () {
        test(
          'when the same user rsvps many times at the same time then only one '
          'rsvp is stored',
          () async {
            const attempts = 12;

            final event = await insertEvent(title: 'Opening ceremony');

            final results = await Future.wait([
              for (var i = 0; i < attempts; i++)
                outcome(
                  () => endpoints.events.rsvp(
                    signedInAs('user-1'),
                    event.id!,
                    status: 'going',
                  ),
                ),
            ]);

            expect(results, everyElement(isNull));

            final rsvps = await Rsvp.db.find(
              setupSession,
              where: (t) => t.eventId.equals(event.id),
            );
            expect(rsvps, hasLength(1));
            expect(rsvps.single.authUserId, 'user-1');
            expect(rsvps.single.status, RsvpStatus.going);
          },
        );

        test(
          'when the same user changes their status many times at the same '
          'time then only one rsvp is stored',
          () async {
            const attempts = 12;

            final event = await insertEvent(title: 'Opening ceremony');

            final results = await Future.wait([
              for (var i = 0; i < attempts; i++)
                outcome(
                  () => endpoints.events.rsvp(
                    signedInAs('user-1'),
                    event.id!,
                    status: i.isEven ? 'going' : 'interested',
                  ),
                ),
            ]);

            expect(results, everyElement(isNull));

            final rsvps = await Rsvp.db.find(
              setupSession,
              where: (t) => t.eventId.equals(event.id),
            );
            expect(rsvps, hasLength(1));

            // The stored status is one of the two that were asked for, and
            // the counts agree with it.
            final summary = await endpoints.events.getEvent(
              sessionBuilder,
              event.id!,
            );
            expect(summary.goingCount + summary.interestedCount, 1);
          },
        );

        test(
          'when a user rsvps and cancels at the same time then the calls do '
          'not fail',
          () async {
            const attempts = 12;

            final event = await insertEvent(title: 'Opening ceremony');

            final results = await Future.wait([
              for (var i = 0; i < attempts; i++)
                outcome(
                  () => endpoints.events.rsvp(
                    signedInAs('user-1'),
                    event.id!,
                    status: 'going',
                  ),
                ),
              for (var i = 0; i < attempts; i++)
                outcome(
                  () => endpoints.events.cancelRsvp(signedInAs('user-1'), event.id!),
                ),
            ]);

            expect(results, everyElement(isNull));

            // Whatever the interleaving was, the database holds a single
            // consistent row and the counts match it.
            final rsvps = await Rsvp.db.find(
              setupSession,
              where: (t) => t.eventId.equals(event.id),
            );
            expect(rsvps.length, lessThanOrEqualTo(1));

            final summary = await endpoints.events.getEvent(
              sessionBuilder,
              event.id!,
            );
            expect(summary.goingCount, rsvps.length);
          },
        );
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
    configOverride: (config) {
      // Every parallel call holds a connection for the length of its
      // transaction, so the pool needs more than the default ten.
      final database = config.database;
      if (database is! PostgresDatabaseConfig) return config;

      return config.copyWith(
        database: PostgresDatabaseConfig(
          host: database.host,
          port: database.port,
          user: database.user,
          password: database.password,
          name: database.name,
          requireSsl: database.requireSsl,
          isUnixSocket: database.isUnixSocket,
          searchPaths: database.searchPaths,
          maxConnectionCount: 30,
          dataPath: database.dataPath,
        ),
      );
    },
  );
}
