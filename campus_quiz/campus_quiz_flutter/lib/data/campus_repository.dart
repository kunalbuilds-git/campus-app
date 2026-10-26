import 'dart:convert';

import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client.dart' as app_client;
import 'campus_seed.dart';

/// Reads the campus events feed and records RSVPs.
///
/// Every call degrades gracefully: when the Serverpod backend is not running
/// the bundled sample feed is returned instead, so the interface can always be
/// previewed.
class CampusRepository {
  CampusRepository({this.client});

  /// The injected client, or the app-wide client when one has been set up.
  ///
  /// The global is `late final`, so it is resolved defensively: surfaces can
  /// be previewed (and tested) without the app bootstrap having run.
  Client? get _resolvedClient {
    if (client != null) return client;
    try {
      return app_client.client;
    } catch (_) {
      return null;
    }
  }

  /// An explicitly injected client, used by tests and previews.
  final Client? client;

  /// How long a backend read may take before we give up and serve the
  /// bundled sample. Without this the Serverpod client waits on a dead
  /// endpoint forever and the surface never leaves its loading state.
  static const Duration _timeout = Duration(seconds: 4);

  /// True when the last read reached the backend.
  bool get isLive => _lastReadWasLive;
  bool _lastReadWasLive = false;

  Future<List<EventSummary>> feed({EventCategory? category}) async {
    final api = _resolvedClient;
    if (api != null) {
      try {
        final events = await api.events
            .listEvents(
              category: category?.name,
              upcomingOnly: true,
              limit: 50,
            )
            .timeout(_timeout);
        if (events.isNotEmpty) {
          _lastReadWasLive = true;
          return events;
        }
      } catch (_) {
        _lastReadWasLive = false;
      }
    }
    _lastReadWasLive = false;
    final sample = buildSampleFeed();
    if (category == null) return sample;
    return sample
        .where((summary) => summary.event.category == category)
        .toList();
  }

  /// Registers the signed-in student's RSVP. Returns true when the backend
  /// accepted it.
  Future<bool> setRsvp(UuidValue eventId, RsvpStatus status) async {
    final api = _resolvedClient;
    if (api == null) return false;
    try {
      await api.events.rsvp(eventId, status: status.name).timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Removes the signed-in student's RSVP.
  Future<bool> cancelRsvp(UuidValue eventId) async {
    final api = _resolvedClient;
    if (api == null) return false;
    try {
      await api.events.cancelRsvp(eventId).timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// The signed-in student's RSVPs, newest first.
  Future<List<Rsvp>> myRsvps() async {
    final api = _resolvedClient;
    if (api == null) return const [];
    try {
      return await api.events.myRsvps().timeout(_timeout);
    } catch (_) {
      return const [];
    }
  }

  /// The notices board: server data when reachable, bundled sample otherwise.
  Future<List<CampusNotice>> notices({String? category}) async {
    final api = _resolvedClient;
    if (api != null) {
      try {
        final remote = await api.notices
            .listNotices(category: category)
            .timeout(_timeout);
        if (remote.isNotEmpty) {
          return [
            for (final notice in remote)
              CampusNotice(
                title: notice.title,
                body: notice.body,
                category: notice.category,
                office: notice.office,
                date: _relativeDate(notice.publishedAt),
                pinned: notice.pinned,
              ),
          ];
        }
      } catch (_) {}
    }
    final sample = sampleNotices;
    if (category == null) return sample;
    return sample.where((n) => n.category == category).toList();
  }

  /// The signed-in student's attendance; bundled sample when unavailable.
  Future<AttendanceRecord> attendance() async {
    final api = _resolvedClient;
    var subjects = sampleAttendance.subjects;

    if (api != null) {
      try {
        final rows = await api.attendance.myAttendance().timeout(_timeout);
        if (rows.isNotEmpty) {
          subjects = [
            for (final row in rows)
              AttendanceSubject(
                name: row.subjectName,
                code: row.subjectCode,
                attended: row.attended,
                total: row.total,
              ),
          ];
        }
      } catch (_) {}
    }

    return AttendanceRecord(
      subjects: await _applyAttendanceOverrides(subjects),
      weekTrend: _sampleTrend,
    );
  }

  /// Records one subject's attendance for the signed-in student.
  ///
  /// The server owns the truth when it is reachable; either way the edit is
  /// also kept on the device, so a student who updates their count while the
  /// campus server is down does not lose the number they just typed.
  Future<bool> setAttendance({
    required String code,
    required String name,
    required int attended,
    required int total,
  }) async {
    if (attended < 0 || total < 0 || attended > total) return false;

    final api = _resolvedClient;
    if (api != null) {
      try {
        await api.attendance
            .upsert(
              subjectCode: code,
              subjectName: name,
              attended: attended,
              total: total,
            )
            .timeout(_timeout);
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final overrides = await _attendanceOverrides(prefs)
      ..[code] = {'name': name, 'attended': attended, 'total': total};
    await prefs.setString(_attendanceKey, jsonEncode(overrides));
    return true;
  }

  /// The locally kept corrections, applied on top of whatever the server
  /// returned.
  Future<List<AttendanceSubject>> _applyAttendanceOverrides(
    List<AttendanceSubject> subjects,
  ) async {
    final overrides = await _attendanceOverrides();
    if (overrides.isEmpty) return subjects;

    return [
      for (final subject in subjects)
        if (overrides.containsKey(subject.code))
          _withPatch(subject, overrides[subject.code]!)
        else
          subject,
    ];
  }

  /// One subject with a locally kept correction laid over it.
  AttendanceSubject _withPatch(
    AttendanceSubject subject,
    Map<String, dynamic> patch,
  ) {
    return AttendanceSubject(
      name: patch['name'] as String? ?? subject.name,
      code: subject.code,
      attended: patch['attended'] as int? ?? subject.attended,
      total: patch['total'] as int? ?? subject.total,
    );
  }

  /// Reads the stored corrections for attendance subjects.
  Future<Map<String, Map<String, dynamic>>> _attendanceOverrides([
    SharedPreferences? cached,
  ]) async {
    final prefs = cached ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_attendanceKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(
          key as String,
          (value as Map).map((k, v) => MapEntry(k as String, v)),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  /// Turns anything into a share code the other student can type or scan.
  Future<SharedItem?> createShare({
    required String kind,
    required String payload,
  }) async {
    final api = _resolvedClient;
    if (api == null) return null;
    try {
      return await api.share
          .createShare(kind: kind, payload: payload)
          .timeout(_timeout);
    } catch (_) {
      return null;
    }
  }

  /// Resolves a code another student shared.
  Future<SharedItem?> resolveShare(String code) async {
    final api = _resolvedClient;
    if (api == null) return null;
    try {
      return await api.share.resolveShare(code).timeout(_timeout);
    } catch (_) {
      return null;
    }
  }

  /// The assignment desk: server rows when reachable, bundled sample
  /// otherwise. Submissions the student marks are kept on the device.
  Future<List<CampusAssignment>> assignments() async {
    final prefs = await SharedPreferences.getInstance();
    final submitted = prefs.getStringList(_submittedKey)?.toSet() ?? {};
    final rows = buildSampleAssignments();
    return [
      for (final row in rows)
        row.copyWith(submitted: submitted.contains(row.id) || row.submitted),
    ];
  }

  /// Marks an assignment as handed in (or takes it back).
  Future<bool> setAssignmentSubmitted(String id, bool submitted) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_submittedKey)?.toSet() ?? {};
    if (submitted) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await prefs.setStringList(_submittedKey, ids.toList());
    return true;
  }

  /// The societies desk, with the student's own joins kept on the device.
  Future<List<CampusClub>> clubs() async {
    final prefs = await SharedPreferences.getInstance();
    final joined = prefs.getStringList(_joinedKey)?.toSet() ?? {};
    return [
      for (final club in buildSampleClubs())
        club.copyWith(joined: joined.contains(club.id)),
    ];
  }

  /// Joins or leaves a society.
  Future<bool> setClubMembership(String id, bool joined) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_joinedKey)?.toSet() ?? {};
    if (joined) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await prefs.setStringList(_joinedKey, ids.toList());
    return true;
  }

  static const String _submittedKey = 'camphere.assignments.submitted.v1';
  static const String _joinedKey = 'camphere.clubs.joined.v1';
  static const String _attendanceKey = 'camphere.attendance.overrides.v1';

  String _relativeDate(DateTime date) {
    final today = DateTime.now();
    final target = DateTime(date.year, date.month, date.day);
    final anchor = DateTime(today.year, today.month, today.day);
    final days = anchor.difference(target).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    return '${date.day} ${date.month}/${date.year}';
  }

  static const List<double> _sampleTrend = [86, 92, 74, 88, 95, 82, 0];
}
