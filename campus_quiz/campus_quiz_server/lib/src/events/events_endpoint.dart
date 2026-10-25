import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Public API of the campus events feed.
///
/// Reading events is open to everyone; RSVP endpoints require an
/// authenticated user (anonymous accounts count as authenticated).
class EventsEndpoint extends Endpoint {
  static const int _maxListLimit = 100;
  static const int _defaultLimit = 50;

  static final Map<String, EventCategory> _categoriesByName = {
    for (final category in EventCategory.values) category.name: category,
  };

  static final Map<String, RsvpStatus> _statusesByName = {
    for (final status in RsvpStatus.values) status.name: status,
  };

  /// Lists events ordered by start time, with their RSVP counts.
  ///
  /// [category] must be an [EventCategory] name, [upcomingOnly] excludes
  /// events that have already ended, and [limit] is clamped to 1..100.
  ///
  /// The parameters are nullable so that they stay optional in the client
  /// protocol; the defaults are applied here.
  Future<List<EventSummary>> listEvents(
    Session session, {
    String? category,
    bool? upcomingOnly,
    int? limit,
  }) async {
    final categoryFilter = category == null ? null : _parseCategory(category);
    final showUpcoming = upcomingOnly ?? true;
    final clampedLimit = (limit ?? _defaultLimit).clamp(1, _maxListLimit);

    final now = DateTime.now();
    final events = await Event.db.find(
      session,
      where: (t) {
        Expression expression = Constant.bool(true);
        if (categoryFilter != null) {
          expression &= t.category.equals(categoryFilter);
        }
        if (showUpcoming) {
          // Open-ended events (null endsAt) are always upcoming.
          expression &= t.endsAt.equals(null) | (t.endsAt > now);
        }
        return expression;
      },
      orderBy: (t) => t.startsAt,
      limit: clampedLimit,
    );

    return _toSummaries(session, events);
  }

  /// Returns a single event with its RSVP counts.
  Future<EventSummary> getEvent(Session session, UuidValue eventId) async {
    final event = await Event.db.findById(session, eventId);
    if (event == null) {
      throw EventException(
        code: 'EVENT_NOT_FOUND',
        message: 'No event with id $eventId.',
      );
    }
    final counts = await _countByStatus(session, {eventId});
    return EventSummary(
      event: event,
      goingCount: counts.going[eventId] ?? 0,
      interestedCount: counts.interested[eventId] ?? 0,
    );
  }

  /// Registers or updates the signed-in user's RSVP to an event.
  ///
  /// Passing a different [status] updates the existing RSVP, so calling
  /// this twice is safe. The status defaults to `going`.
  Future<Rsvp> rsvp(
    Session session,
    UuidValue eventId, {
    String? status,
  }) async {
    final authUserId = _requireAuth(session);
    final rsvpStatus = _parseStatus(status ?? 'going');

    final event = await Event.db.findById(session, eventId);
    if (event == null) {
      throw EventException(
        code: 'EVENT_NOT_FOUND',
        message: 'No event with id $eventId.',
      );
    }
    final endsAt = event.endsAt;
    if (endsAt != null && endsAt.isBefore(DateTime.now())) {
      throw EventException(
        code: 'EVENT_ENDED',
        message: 'The event "${event.title}" has already ended.',
      );
    }

    final existing = await _findRsvp(session, eventId, authUserId);

    // Users who are already counted as going can keep their spot even when
    // the event is full; only new or switching attendees hit the cap.
    if (rsvpStatus == RsvpStatus.going &&
        existing?.status != RsvpStatus.going) {
      final capacity = event.capacity;
      if (capacity != null) {
        final goingCount = await Rsvp.db.count(
          session,
          where: (t) =>
              t.eventId.equals(eventId) & t.status.equals(RsvpStatus.going),
        );
        if (goingCount >= capacity) {
          throw EventException(
            code: 'EVENT_CAPACITY_REACHED',
            message:
                'The event "${event.title}" has reached its capacity of '
                '$capacity attendees.',
          );
        }
      }
    }

    if (existing != null) {
      existing.status = rsvpStatus;
      return Rsvp.db.updateRow(session, existing);
    }

    return Rsvp.db.insertRow(
      session,
      Rsvp(
        eventId: eventId,
        authUserId: authUserId,
        status: rsvpStatus,
      ),
    );
  }

  /// Cancels the signed-in user's RSVP to an event. Cancelling an RSVP the
  /// user does not have is not an error.
  Future<void> cancelRsvp(Session session, UuidValue eventId) async {
    final authUserId = _requireAuth(session);
    await Rsvp.db.deleteWhere(
      session,
      where: (t) => t.eventId.equals(eventId) & t.authUserId.equals(authUserId),
    );
  }

  /// Returns the signed-in user's RSVPs, newest first, with their events.
  Future<List<Rsvp>> myRsvps(Session session) async {
    final authUserId = _requireAuth(session);
    return Rsvp.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      include: Rsvp.include(event: Event.include()),
      orderByList: (t) => [t.createdAt.desc()],
    );
  }

  String _requireAuth(Session session) {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw EventException(
        code: 'UNAUTHENTICATED',
        message: 'This action requires a signed-in user.',
      );
    }
    return authInfo.userIdentifier;
  }

  EventCategory _parseCategory(String category) {
    final value = _categoriesByName[category.trim().toLowerCase()];
    if (value == null) {
      throw EventException(
        code: 'EVENT_INVALID_CATEGORY',
        message:
            'Unknown category "$category". Valid categories: '
            '${EventCategory.values.map((c) => c.name).join(', ')}.',
      );
    }
    return value;
  }

  RsvpStatus _parseStatus(String status) {
    final value = _statusesByName[status.trim().toLowerCase()];
    if (value == null) {
      throw EventException(
        code: 'RSVP_INVALID_STATUS',
        message:
            'Unknown RSVP status "$status". Valid statuses: '
            '${RsvpStatus.values.map((s) => s.name).join(', ')}.',
      );
    }
    return value;
  }

  Future<List<EventSummary>> _toSummaries(
    Session session,
    List<Event> events,
  ) async {
    if (events.isEmpty) return const [];

    final eventIds = events.map((event) => event.id!).toSet();
    final counts = await _countByStatus(session, eventIds);

    return [
      for (final event in events)
        EventSummary(
          event: event,
          goingCount: counts.going[event.id!] ?? 0,
          interestedCount: counts.interested[event.id!] ?? 0,
        ),
    ];
  }

  Future<({Map<UuidValue, int> going, Map<UuidValue, int> interested})>
  _countByStatus(Session session, Set<UuidValue> eventIds) async {
    final rsvps = await Rsvp.db.find(
      session,
      where: (t) => t.eventId.inSet(eventIds),
    );

    final going = <UuidValue, int>{};
    final interested = <UuidValue, int>{};
    for (final rsvp in rsvps) {
      final eventId = rsvp.eventId;
      switch (rsvp.status) {
        case RsvpStatus.going:
          going[eventId] = (going[eventId] ?? 0) + 1;
        case RsvpStatus.interested:
          interested[eventId] = (interested[eventId] ?? 0) + 1;
      }
    }
    return (going: going, interested: interested);
  }

  Future<Rsvp?> _findRsvp(
    Session session,
    UuidValue eventId,
    String authUserId,
  ) {
    return Rsvp.db.findFirstRow(
      session,
      where: (t) => t.eventId.equals(eventId) & t.authUserId.equals(authUserId),
    );
  }
}
