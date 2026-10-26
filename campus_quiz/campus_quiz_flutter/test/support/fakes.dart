import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:campus_quiz_flutter/data/account_repository.dart';
import 'package:campus_quiz_flutter/data/events_repository.dart';

/// Builds an event with sensible defaults for the tests.
Event buildEvent({
  required String title,
  EventCategory category = EventCategory.tech,
  DateTime? startsAt,
  DateTime? endsAt,
  String description = 'An evening with the robotics club.',
  String location = 'Engineering Hall, room 1',
  String organizer = 'The Robotics Club',
  int? capacity,
  String? id,
}) {
  return Event(
    id: UuidValue.fromString(id ?? '00000000-0000-4000-8000-000000000001'),
    title: title,
    description: description,
    startsAt: startsAt ?? DateTime(2026, 10, 27, 10),
    endsAt: endsAt ?? DateTime(2026, 10, 27, 18),
    location: location,
    organizer: organizer,
    capacity: capacity,
    category: category,
  );
}

/// Builds an event summary for [event].
EventSummary buildSummary(
  Event event, {
  int goingCount = 0,
  int interestedCount = 0,
}) {
  return EventSummary(
    event: event,
    goingCount: goingCount,
    interestedCount: interestedCount,
  );
}

/// Builds an RSVP for [eventId].
Rsvp buildRsvp({
  required UuidValue eventId,
  RsvpStatus status = RsvpStatus.going,
  Event? event,
}) {
  return Rsvp(
    eventId: eventId,
    event: event,
    authUserId: 'test-user',
    status: status,
  );
}

/// An in-memory [EventsRepository] for the widget tests.
class FakeEventsRepository implements EventsRepository {
  FakeEventsRepository({
    List<EventSummary> summaries = const [],
    List<Rsvp> rsvps = const [],
  }) : _summaries = List.of(summaries),
       _rsvps = List.of(rsvps);

  List<EventSummary> _summaries;
  final List<Rsvp> _rsvps;

  /// When set, every call fails with this error.
  Object? error;

  /// The categories the screen asked for, in order.
  final List<String?> listEventsCalls = [];

  /// The events the student responded to, in order.
  final List<UuidValue> rsvpCalls = [];

  /// The events the student cancelled their response to, in order.
  final List<UuidValue> cancelRsvpCalls = [];

  void setSummaries(List<EventSummary> summaries) {
    _summaries = List.of(summaries);
  }

  void setRsvps(List<Rsvp> rsvps) {
    _rsvps
      ..clear()
      ..addAll(rsvps);
  }

  @override
  Future<List<EventSummary>> listEvents({String? category}) async {
    if (error != null) throw error!;
    listEventsCalls.add(category);
    if (category == null) return List.of(_summaries);
    return _summaries
        .where((summary) => summary.event.category.name == category)
        .toList();
  }

  @override
  Future<EventSummary> getEvent(UuidValue eventId) async {
    if (error != null) throw error!;
    return _summaries.firstWhere((summary) => summary.event.id == eventId);
  }

  @override
  Future<Rsvp> rsvp(UuidValue eventId, {required RsvpStatus status}) async {
    if (error != null) throw error!;
    rsvpCalls.add(eventId);
    final rsvp = buildRsvp(eventId: eventId, status: status);
    _rsvps.add(rsvp);
    return rsvp;
  }

  @override
  Future<void> cancelRsvp(UuidValue eventId) async {
    if (error != null) throw error!;
    cancelRsvpCalls.add(eventId);
    _rsvps.removeWhere((rsvp) => rsvp.eventId == eventId);
  }

  @override
  Future<List<Rsvp>> myRsvps() async {
    if (error != null) throw error!;
    return List.of(_rsvps);
  }
}

/// An in-memory [AccountRepository] for the widget tests.
class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({this.hasEmail = false});

  /// Whether the signed-in user has an email account attached.
  bool hasEmail;

  /// Whether the student signed out.
  bool signedOut = false;

  @override
  Future<bool> hasEmailAccount() async => hasEmail;

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}
