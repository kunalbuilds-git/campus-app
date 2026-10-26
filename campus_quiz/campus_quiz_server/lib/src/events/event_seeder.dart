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

    /// A time later today, rounded up to the next half hour.
    DateTime laterToday(double hours) {
      final raw = now.add(Duration(minutes: (hours * 60).round()));
      final rounded = raw.minute <= 30 ? 30 : 60;
      return DateTime(raw.year, raw.month, raw.day, raw.hour, rounded);
    }

    /// Keeps a same-day event on today, inside a sensible evening window:
    /// anything later than nine o'clock is pulled back to nine, and once nine
    /// has passed the event slips to tomorrow morning rather than landing at
    /// two in the morning.
    DateTime sameDay(DateTime when, int fallbackHour) {
      if (when.day != now.day) return at(1, fallbackHour);
      final limit = DateTime(now.year, now.month, now.day, 21);
      if (when.isAfter(limit)) {
        return limit.isAfter(now) ? limit : at(1, fallbackHour);
      }
      return when;
    }

    return [
      Event(
        title: 'Design Studio Open Hours',
        description:
            'The design block opens its doors for anyone who wants to print, '
            'draw or prototype. Supervisors are around to help.',
        startsAt: sameDay(laterToday(2), 10),
        endsAt: sameDay(laterToday(3), 11),
        location: 'Studio 2, Design Block',
        organizer: 'Design Collective',
        capacity: 40,
        category: EventCategory.workshop,
      ),
      Event(
        title: 'Fireside Chat: Your First App',
        description:
            'Two alumni talk about what they shipped first, the mistakes that '
            'cost them, and what they would build again.',
        startsAt: sameDay(laterToday(5), 16),
        endsAt: sameDay(laterToday(6), 17),
        location: 'Cafeteria Lawn',
        organizer: 'Entrepreneurship Cell',
        capacity: 120,
        category: EventCategory.tech,
      ),
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
        title: 'Blood Donation Drive',
        description:
            'The college health unit is hosting a donation camp with the city '
            'blood bank. Donors get a certificate and a full breakfast.',
        startsAt: at(7, 10),
        endsAt: at(7, 14),
        location: 'Health Centre, Block C',
        organizer: 'NSS Unit',
        capacity: 70,
        category: EventCategory.community,
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
        title: 'Breakfast Run and Coffee',
        description:
            'A five-kilometre loop around the campus track, finishing with '
            'filter coffee at the canteen. All paces welcome.',
        startsAt: at(1, 7, 30),
        endsAt: at(1, 8, 30),
        location: 'Track, Behind Block D',
        organizer: 'Athletics Club',
        category: EventCategory.sports,
      ),
      Event(
        title: 'Library Study Sprint',
        description:
            'Three focused hours in the reading room with the lights low and '
            'phones away. Everyone works on their own thing.',
        startsAt: at(2, 13),
        endsAt: at(2, 16),
        location: 'Central Library, Floor 2',
        organizer: 'Library Committee',
        capacity: 80,
        category: EventCategory.academic,
      ),
      Event(
        title: 'Robotics Lab Open House',
        description:
            'The robotics lab opens its workbenches: line-following bots, a '
            'drone you can fly, and the students who built them.',
        startsAt: at(3, 11),
        endsAt: at(3, 13),
        location: 'Robotics Lab, Block E',
        organizer: 'Robotics Society',
        capacity: 50,
        category: EventCategory.tech,
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
        title: 'Football Trials — Open Selection',
        description:
            'Open trials for the university side. Bring boots and a dark top; '
            'the coaches will take anyone who turns up.',
        startsAt: at(4, 16),
        endsAt: at(4, 18),
        location: 'University Stadium',
        organizer: 'Sports Council',
        capacity: 60,
        category: EventCategory.sports,
      ),
      Event(
        title: 'General Aptitude Quiz',
        description:
            'A timed departmental quiz on quant, reasoning and reading. First '
            'year scores go on the notice board on Friday.',
        startsAt: at(5, 13),
        endsAt: at(5, 15),
        location: 'Exam Hall 2',
        organizer: 'Academic Committee',
        capacity: 150,
        category: EventCategory.academic,
      ),
      Event(
        title: 'Short Film Screening',
        description:
            'Eight student-made short films, one of them a winner at the '
            'regional festival. Introductions by the directors.',
        startsAt: at(6, 19),
        endsAt: at(6, 21),
        location: 'Auditorium, Block A',
        organizer: 'Film Society',
        capacity: 180,
        category: EventCategory.cultural,
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
