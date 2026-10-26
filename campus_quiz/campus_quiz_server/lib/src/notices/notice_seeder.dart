import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Provides the sample notices used by the development database.
abstract final class NoticeSeeder {
  /// Inserts the sample notices when the notice table is empty. Safe to call
  /// on every server start.
  static Future<int> seedIfEmpty(Serverpod pod) {
    return pod.withSession((session) async {
      final existing = await Notice.db.find(session, limit: 1);
      if (existing.isNotEmpty) return 0;

      final notices = [
        Notice(
          title: 'Mid-semester examination schedule published',
          body:
              'The timetable for the odd-semester mid-semester examinations '
              'is now on the portal. Hall tickets unlock 48 hours before your '
              'first paper.',
          category: 'Exams',
          office: 'Examination Cell',
          pinned: true,
        ),
        Notice(
          title: 'Infosys on-campus drive — register by Thursday',
          body:
              'Eligibility: 7.0 CGPA and above, all branches. '
              'Pre-placement talk on Wednesday at 10 am in Seminar Hall 3. '
              'Carry a printed resume.',
          category: 'Placement',
          office: 'Placement Cell',
          pinned: true,
        ),
        Notice(
          title: 'Library extends hours for exam week',
          body:
              'The reading halls will stay open until 2 am from Monday. '
              'The discussion rooms move to first-come booking after 6 pm.',
          category: 'Admin',
          office: 'Central Library',
        ),
        Notice(
          title: 'Hackathon team registrations are open',
          body:
              'Teams of up to four, mentors on site, demo session on Sunday '
              'evening. Register through the coding club desk in the '
              'Computing Block.',
          category: 'Clubs',
          office: 'Coding Club',
        ),
        Notice(
          title: 'Bus route 4 timing change from Monday',
          body:
              'Route 4 departs the main gate 15 minutes earlier at 8:05 am '
              'for the rest of the term. Evening drops are unchanged.',
          category: 'Admin',
          office: 'Transport Office',
        ),
        Notice(
          title: 'Hostel mess menu for November is out',
          body:
              'The updated monthly menu is pinned in every block and on the '
              'mess noticeboard. Special diet requests go to the warden by '
              'Friday.',
          category: 'General',
          office: 'Hostel Office',
        ),
        Notice(
          title: 'Photography walk: old town, this Saturday',
          body:
              'Meet at the main gate at 7 am. Cameras optional; the club '
              'has six spares. Registrations close Friday evening.',
          category: 'Clubs',
          office: 'Photography Club',
        ),
        Notice(
          title: 'Revaluation window closes on Friday',
          body:
              'Applications for odd-semester answer-sheet revaluation close '
              'at 4 pm Friday. Forms are accepted only through the portal.',
          category: 'Exams',
          office: 'Examination Cell',
        ),
      ];

      await Notice.db.insert(session, notices);
      session.log('Seeded ${notices.length} sample campus notices.');
      return notices.length;
    });
  }
}
