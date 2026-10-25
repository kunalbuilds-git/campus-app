/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:campus_quiz_server/src/generated/protocol.dart' as _ift8zms9;
import 'package:serverpod/serverpod.dart' as _is;
import '../events/event.dart' as _inam5zsn;

/// An event with its current RSVP counts, used by list and detail views.
abstract class EventSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  EventSummary._({
    required this.event,
    required this.goingCount,
    required this.interestedCount,
  });

  factory EventSummary({
    required _inam5zsn.Event event,
    required int goingCount,
    required int interestedCount,
  }) = _EventSummaryImpl;

  factory EventSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventSummary(
      event: _ift8zms9.Protocol().deserialize<_inam5zsn.Event>(
        jsonSerialization['event'],
      ),
      goingCount: jsonSerialization['goingCount'] as int,
      interestedCount: jsonSerialization['interestedCount'] as int,
    );
  }

  /// The event itself.
  _inam5zsn.Event event;

  /// Number of `going` RSVPs.
  int goingCount;

  /// Number of `interested` RSVPs.
  int interestedCount;

  /// Returns a shallow copy of this [EventSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EventSummary copyWith({
    _inam5zsn.Event? event,
    int? goingCount,
    int? interestedCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventSummary',
      'event': event.toJson(),
      'goingCount': goingCount,
      'interestedCount': interestedCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EventSummary',
      'event': event.toJsonForProtocol(),
      'goingCount': goingCount,
      'interestedCount': interestedCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _EventSummaryImpl extends EventSummary {
  _EventSummaryImpl({
    required _inam5zsn.Event event,
    required int goingCount,
    required int interestedCount,
  }) : super._(
         event: event,
         goingCount: goingCount,
         interestedCount: interestedCount,
       );

  /// Returns a shallow copy of this [EventSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EventSummary copyWith({
    _inam5zsn.Event? event,
    int? goingCount,
    int? interestedCount,
  }) {
    return EventSummary(
      event: event ?? this.event.copyWith(),
      goingCount: goingCount ?? this.goingCount,
      interestedCount: interestedCount ?? this.interestedCount,
    );
  }
}
