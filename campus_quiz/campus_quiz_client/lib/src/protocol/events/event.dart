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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../events/event_category.dart' as _i2sr3i4w;

/// An event published on the campus events feed.
abstract class Event
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Event._({
    this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    this.endsAt,
    required this.location,
    required this.organizer,
    this.capacity,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Event({
    _isc.UuidValue? id,
    required String title,
    required String description,
    required DateTime startsAt,
    DateTime? endsAt,
    required String location,
    required String organizer,
    int? capacity,
    required _i2sr3i4w.EventCategory category,
    DateTime? createdAt,
  }) = _EventImpl;

  factory Event.fromJson(Map<String, dynamic> jsonSerialization) {
    return Event(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      startsAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      endsAt: jsonSerialization['endsAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      location: jsonSerialization['location'] as String,
      organizer: jsonSerialization['organizer'] as String,
      capacity: jsonSerialization['capacity'] as int?,
      category: _i2sr3i4w.EventCategory.fromJson(
        (jsonSerialization['category'] as String),
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

  /// Short display title of the event.
  String title;

  /// Longer free-text description shown on the event details screen.
  String description;

  /// When the event starts.
  DateTime startsAt;

  /// When the event ends. Null for open-ended events.
  DateTime? endsAt;

  /// Where the event takes place.
  String location;

  /// Name of the organizing student club or department.
  String organizer;

  /// Maximum number of `going` RSVPs. Null means unlimited.
  int? capacity;

  /// Category used for filtering in the app.
  _i2sr3i4w.EventCategory category;

  /// Time the event was published.
  DateTime createdAt;

  /// Returns a shallow copy of this [Event]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Event copyWith({
    _isc.UuidValue? id,
    String? title,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? organizer,
    int? capacity,
    _i2sr3i4w.EventCategory? category,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Event',
      if (id != null) 'id': id?.toJson(),
      'title': title,
      'description': description,
      'startsAt': startsAt.toJson(),
      if (endsAt != null) 'endsAt': endsAt?.toJson(),
      'location': location,
      'organizer': organizer,
      if (capacity != null) 'capacity': capacity,
      'category': category.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Event',
      if (id != null) 'id': id?.toJson(),
      'title': title,
      'description': description,
      'startsAt': startsAt.toJson(),
      if (endsAt != null) 'endsAt': endsAt?.toJson(),
      'location': location,
      'organizer': organizer,
      if (capacity != null) 'capacity': capacity,
      'category': category.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EventImpl extends Event {
  _EventImpl({
    _isc.UuidValue? id,
    required String title,
    required String description,
    required DateTime startsAt,
    DateTime? endsAt,
    required String location,
    required String organizer,
    int? capacity,
    required _i2sr3i4w.EventCategory category,
    DateTime? createdAt,
  }) : super._(
         id: id,
         title: title,
         description: description,
         startsAt: startsAt,
         endsAt: endsAt,
         location: location,
         organizer: organizer,
         capacity: capacity,
         category: category,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Event]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Event copyWith({
    Object? id = _Undefined,
    String? title,
    String? description,
    DateTime? startsAt,
    Object? endsAt = _Undefined,
    String? location,
    String? organizer,
    Object? capacity = _Undefined,
    _i2sr3i4w.EventCategory? category,
    DateTime? createdAt,
  }) {
    return Event(
      id: id is _isc.UuidValue? ? id : this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt is DateTime? ? endsAt : this.endsAt,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      capacity: capacity is int? ? capacity : this.capacity,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
