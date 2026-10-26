import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// The signed-in student's attendance records.
class AttendanceEndpoint extends Endpoint {
  /// The caller's per-subject attendance rows, newest subject first.
  ///
  /// Unauthenticated callers receive an empty list — the client falls back
  /// to its bundled sample data so the section always renders.
  Future<List<AttendanceEntry>> myAttendance(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) return const [];

    return AttendanceEntry.db.find(
      session,
      where: (t) => t.authUserId.equals(authInfo.userIdentifier),
      orderBy: (t) => t.subjectCode,
    );
  }

  /// Upserts one subject's attendance for the signed-in student.
  Future<AttendanceEntry> upsert(
    Session session, {
    required String subjectCode,
    required String subjectName,
    required int attended,
    required int total,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw AttendanceException(
        code: 'UNAUTHENTICATED',
        message: 'Attendance requires a signed-in user.',
      );
    }

    // The counters are self-reported, but they still have to be counters:
    // you cannot attend more classes than were held, and neither number can
    // be negative. Without this the dashboard could show nonsense.
    if (attended < 0 || total < 0 || attended > total) {
      throw AttendanceException(
        code: 'INVALID_COUNTERS',
        message:
            'Attended must be between zero and the number of classes held.',
      );
    }

    final userId = authInfo.userIdentifier;
    final existing = await AttendanceEntry.db.findFirstRow(
      session,
      where: (t) =>
          t.authUserId.equals(userId) & t.subjectCode.equals(subjectCode),
    );

    if (existing != null) {
      return AttendanceEntry.db.updateRow(
        session,
        existing
          ..attended = attended
          ..total = total,
      );
    }
    return AttendanceEntry.db.insertRow(
      session,
      AttendanceEntry(
        authUserId: userId,
        subjectCode: subjectCode,
        subjectName: subjectName,
        attended: attended,
        total: total,
      ),
    );
  }
}
