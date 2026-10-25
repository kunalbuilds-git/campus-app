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
import 'package:campus_quiz_client/src/protocol/protocol.dart' as _ir72obe3;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../events/event.dart' as _inam5zsn;
import '../events/rsvp_status.dart' as _iiv55n98;

/// A user's RSVP to an event.
abstract class Rsvp
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Rsvp._({
    this.id,
    required this.eventId,
    this.event,
    required this.authUserId,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Rsvp({
    _isc.UuidValue? id,
    required _isc.UuidValue eventId,
    _inam5zsn.Event? event,
    required String authUserId,
    required _iiv55n98.RsvpStatus status,
    DateTime? createdAt,
  }) = _RsvpImpl;

  factory Rsvp.fromJson(Map<String, dynamic> jsonSerialization) {
    return Rsvp(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      event: jsonSerialization['event'] == null
          ? null
          : _ir72obe3.Protocol().deserialize<_inam5zsn.Event>(
              jsonSerialization['event'],
            ),
      authUserId: jsonSerialization['authUserId'] as String,
      status: _iiv55n98.RsvpStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue eventId;

  /// The event this RSVP belongs to.
  _inam5zsn.Event? event;

  /// The Serverpod auth user identifier of the attendee.
  String authUserId;

  /// The attendance status registered by the user.
  _iiv55n98.RsvpStatus status;

  /// Time the RSVP was first created.
  DateTime createdAt;

  /// Returns a shallow copy of this [Rsvp]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Rsvp copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? eventId,
    _inam5zsn.Event? event,
    String? authUserId,
    _iiv55n98.RsvpStatus? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Rsvp',
      if (id != null) 'id': id?.toJson(),
      'eventId': eventId.toJson(),
      if (event != null) 'event': event?.toJson(),
      'authUserId': authUserId,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Rsvp',
      if (id != null) 'id': id?.toJson(),
      'eventId': eventId.toJson(),
      if (event != null) 'event': event?.toJsonForProtocol(),
      'authUserId': authUserId,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RsvpImpl extends Rsvp {
  _RsvpImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue eventId,
    _inam5zsn.Event? event,
    required String authUserId,
    required _iiv55n98.RsvpStatus status,
    DateTime? createdAt,
  }) : super._(
         id: id,
         eventId: eventId,
         event: event,
         authUserId: authUserId,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Rsvp]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Rsvp copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? eventId,
    Object? event = _Undefined,
    String? authUserId,
    _iiv55n98.RsvpStatus? status,
    DateTime? createdAt,
  }) {
    return Rsvp(
      id: id is _isc.UuidValue? ? id : this.id,
      eventId: eventId ?? this.eventId,
      event: event is _inam5zsn.Event? ? event : this.event?.copyWith(),
      authUserId: authUserId ?? this.authUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
