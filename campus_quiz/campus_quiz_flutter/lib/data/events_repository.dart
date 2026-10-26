import 'package:campus_quiz_client/campus_quiz_client.dart';

import '../client.dart';

/// The event data the app needs from the backend.
///
/// The screens talk to this interface instead of the Serverpod client
/// directly, so they can be tested without a running server.
abstract interface class EventsRepository {
  /// Lists the upcoming events, optionally restricted to one [category].
  Future<List<EventSummary>> listEvents({String? category});

  /// Returns a single event with its current RSVP counts.
  Future<EventSummary> getEvent(UuidValue eventId);

  /// Registers or updates the signed-in user's response to an event.
  Future<Rsvp> rsvp(UuidValue eventId, {required RsvpStatus status});

  /// Removes the signed-in user's response to an event.
  Future<void> cancelRsvp(UuidValue eventId);

  /// Returns the signed-in user's responses, newest first.
  Future<List<Rsvp>> myRsvps();
}

/// Reads and writes events through the Serverpod `events` endpoint.
class ServerpodEventsRepository implements EventsRepository {
  const ServerpodEventsRepository();

  @override
  Future<List<EventSummary>> listEvents({String? category}) =>
      client.events.listEvents(category: category);

  @override
  Future<EventSummary> getEvent(UuidValue eventId) =>
      client.events.getEvent(eventId);

  @override
  Future<Rsvp> rsvp(UuidValue eventId, {required RsvpStatus status}) =>
      client.events.rsvp(eventId, status: status.name);

  @override
  Future<void> cancelRsvp(UuidValue eventId) =>
      client.events.cancelRsvp(eventId);

  @override
  Future<List<Rsvp>> myRsvps() => client.events.myRsvps();
}
