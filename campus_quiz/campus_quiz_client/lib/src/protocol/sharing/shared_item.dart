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

/// An item one student shared with another through a short code.
abstract class SharedItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SharedItem._({
    this.id,
    required this.code,
    required this.kind,
    required this.payload,
    required this.createdBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SharedItem({
    int? id,
    required String code,
    required String kind,
    required String payload,
    required String createdBy,
    DateTime? createdAt,
  }) = _SharedItemImpl;

  factory SharedItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return SharedItem(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      kind: jsonSerialization['kind'] as String,
      payload: jsonSerialization['payload'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The six-character share code students type or scan.
  String code;

  /// What is being shared: `notice` or `event`.
  String kind;

  /// JSON payload of the shared item.
  String payload;

  /// The auth user that created the share, for flood control.
  String createdBy;

  /// Time the share was created.
  DateTime createdAt;

  /// Returns a shallow copy of this [SharedItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SharedItem copyWith({
    int? id,
    String? code,
    String? kind,
    String? payload,
    String? createdBy,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SharedItem',
      if (id != null) 'id': id,
      'code': code,
      'kind': kind,
      'payload': payload,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SharedItem',
      if (id != null) 'id': id,
      'code': code,
      'kind': kind,
      'payload': payload,
      'createdBy': createdBy,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SharedItemImpl extends SharedItem {
  _SharedItemImpl({
    int? id,
    required String code,
    required String kind,
    required String payload,
    required String createdBy,
    DateTime? createdAt,
  }) : super._(
         id: id,
         code: code,
         kind: kind,
         payload: payload,
         createdBy: createdBy,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SharedItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SharedItem copyWith({
    Object? id = _Undefined,
    String? code,
    String? kind,
    String? payload,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return SharedItem(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
