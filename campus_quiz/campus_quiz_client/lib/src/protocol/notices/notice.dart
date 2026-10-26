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

/// A notice published on the campus digital notice board.
abstract class Notice
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Notice._({
    this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.office,
    DateTime? publishedAt,
    bool? pinned,
  }) : publishedAt = publishedAt ?? DateTime.now(),
       pinned = pinned ?? false;

  factory Notice({
    int? id,
    required String title,
    required String body,
    required String category,
    required String office,
    DateTime? publishedAt,
    bool? pinned,
  }) = _NoticeImpl;

  factory Notice.fromJson(Map<String, dynamic> jsonSerialization) {
    return Notice(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      category: jsonSerialization['category'] as String,
      office: jsonSerialization['office'] as String,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      pinned: jsonSerialization['pinned'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['pinned']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Headline shown on the board.
  String title;

  /// Body text of the notice.
  String body;

  /// Bucket used for the board's filters, e.g. Exams, Placement, Clubs.
  String category;

  /// Office or society that published the notice.
  String office;

  /// Time the notice was published.
  DateTime publishedAt;

  /// Pinned notices float to the top of the board.
  bool pinned;

  /// Returns a shallow copy of this [Notice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Notice copyWith({
    int? id,
    String? title,
    String? body,
    String? category,
    String? office,
    DateTime? publishedAt,
    bool? pinned,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Notice',
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'category': category,
      'office': office,
      'publishedAt': publishedAt.toJson(),
      'pinned': pinned,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Notice',
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'category': category,
      'office': office,
      'publishedAt': publishedAt.toJson(),
      'pinned': pinned,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NoticeImpl extends Notice {
  _NoticeImpl({
    int? id,
    required String title,
    required String body,
    required String category,
    required String office,
    DateTime? publishedAt,
    bool? pinned,
  }) : super._(
         id: id,
         title: title,
         body: body,
         category: category,
         office: office,
         publishedAt: publishedAt,
         pinned: pinned,
       );

  /// Returns a shallow copy of this [Notice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Notice copyWith({
    Object? id = _Undefined,
    String? title,
    String? body,
    String? category,
    String? office,
    DateTime? publishedAt,
    bool? pinned,
  }) {
    return Notice(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      office: office ?? this.office,
      publishedAt: publishedAt ?? this.publishedAt,
      pinned: pinned ?? this.pinned,
    );
  }
}
