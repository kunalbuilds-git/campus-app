import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Provides the sample campus events used by the development database.
///
/// Content is seeded on the server instead of managed through an admin UI,
/// so the hackathon demo always has events to show without extra tooling.
abstract final class EventSeeder {
  /// Inserts the sample events when the event table is empty.
  ///
  /// Safe to call on every server start: an existing dataset is never
  /// modified. Returns the number of inserted events.
  static Future<int> seedIfEmpty(Serverpod pod) async {
    return pod.withSession(
      (session) => seedIfEmptyInSession(session),
      enableLogging: false,
    );
  }

  /// Session based variant of [seedIfEmpty], used by the server on start and
  /// by the tests. Returns the number of inserted events.
  static Future<int> seedIfEmptyInSession(Session session) async {
    final existing = await Event.db.find(session, limit: 1);
    if (existing.isNotEmpty) return 0;

    final events = _sampleEvents(DateTime.now());
    await Event.db.insert(session, events);
    session.log('Seeded ${events.length} sample campus events.');
    return events.length;
  }

  /// The sample events, dated relative to [now] so the feed always has a
  /// mix of upcoming and past events.
  static List<Event> _sampleEvents(DateTime now) {
    DateTime at(int daysFromNow, int hour, [int minute = 0]) {
      return DateTime(
        now.year,
        now.month,
        now.day + daysFromNow,
        hour,
        minute,
      );
    }

    return [
      Event(
        title: 'Campus Hackathon 2026',
        description:
            'Twenty-four hours to build something useful. Teams of up to four '
            'people, mentors on site, and a demo session to wrap it up.',
        startsAt: at(2, 10),
        endsAt: at(3, 18),
        location: 'Main Auditorium',
        organizer: 'Coding Club',
        capacity: 200,
        category: EventCategory.tech,
      ),
      Event(
        title: 'Inter-college Football Final',
        description:
            'The annual sports final between the host university and three '
            'visiting colleges. Spectators welcome from the north stand.',
        startsAt: at(5, 16),
        endsAt: at(5, 19),
        location: 'University Stadium',
        organizer: 'Sports Council',
        capacity: 500,
        category: EventCategory.sports,
      ),
      Event(
        title: 'Intro to Machine Learning',
        description:
            'A hands-on introduction to building and training small models. '
            'Bring a laptop; no prior machine learning experience needed.',
        startsAt: at(3, 14),
        endsAt: at(3, 16),
        location: 'Lab 2, Computing Block',
        organizer: 'AI Collective',
        capacity: 60,
        category: EventCategory.workshop,
      ),
      Event(
        title: 'Cultural Night',
        description:
            'Music, dance and food from every cultural society on campus. '
            'Open to all students and staff.',
        startsAt: at(7, 18),
        endsAt: at(7, 22),
        location: 'Central Plaza',
        organizer: 'Cultural Society',
        capacity: 800,
        category: EventCategory.cultural,
      ),
      Event(
        title: 'Undergraduate Research Symposium',
        description:
            'Final-year and masters students present their research posters '
            'to faculty and fellow students.',
        startsAt: at(10, 9),
        endsAt: at(10, 15),
        location: 'Research Wing, Block C',
        organizer: 'Graduate Council',
        capacity: 150,
        category: EventCategory.academic,
      ),
      Event(
        title: 'Startup Pitch Night',
        description:
            'Five early-stage teams pitch to a panel of alumni investors. '
            'Doors open at seven, pitches start at half past.',
        startsAt: at(12, 19),
        endsAt: at(12, 22),
        location: 'Innovation Hub',
        organizer: 'Entrepreneurship Cell',
        capacity: 100,
        category: EventCategory.tech,
      ),
      Event(
        title: 'Sunrise Yoga on the Quad',
        description:
            'A gentle hour of yoga on the central lawn, led by the campus '
            'wellness club. Mats provided.',
        startsAt: at(1, 6, 30),
        endsAt: at(1, 7, 30),
        location: 'Central Quad',
        organizer: 'Wellness Club',
        capacity: 40,
        category: EventCategory.sports,
      ),
      Event(
        title: 'Photography Walk: Old Town',
        description:
            'A guided walk through the old town for anyone interested in '
            'street photography. Cameras optional.',
        startsAt: at(4, 7),
        endsAt: at(4, 9),
        location: 'Meet at the Main Gate',
        organizer: 'Photography Club',
        category: EventCategory.community,
      ),
      Event(
        title: 'Placement Preparation Seminar',
        description:
            'Recruiters walk through the selection process, common interview '
            'questions and how to prepare your CV.',
        startsAt: at(6, 11),
        endsAt: at(6, 13),
        location: 'Seminar Hall 3',
        organizer: 'Placement Cell',
        capacity: 120,
        category: EventCategory.academic,
      ),
      Event(
        title: 'Open Mic Night',
        description:
            'Ten minutes per act. Poetry, stand-up, instruments and anything '
            'in between. Sign-ups close at eight.',
        startsAt: at(8, 17),
        endsAt: at(8, 20),
        location: 'Student Centre Basement',
        organizer: 'Dramatic Society',
        capacity: 90,
        category: EventCategory.cultural,
      ),
      Event(
        title: 'Freshers Welcome Fair',
        description:
            'Clubs, societies and departments set up stalls to welcome new '
            'students to the campus.',
        startsAt: at(-5, 10),
        endsAt: at(-5, 13),
        location: 'Central Plaza',
        organizer: 'Students Union',
        category: EventCategory.community,
      ),
      Event(
        title: 'Termly Coding Contest',
        description:
            'A two-hour competitive programming contest for all skill levels.',
        startsAt: at(-2, 15),
        endsAt: at(-2, 17),
        location: 'Computing Block',
        organizer: 'Coding Club',
        category: EventCategory.tech,
      ),
    ];
  }
}
