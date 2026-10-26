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

/// One subject's attendance record for a student.
abstract class AttendanceEntry
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AttendanceEntry._({
    this.id,
    required this.authUserId,
    required this.subjectCode,
    required this.subjectName,
    required this.attended,
    required this.total,
  });

  factory AttendanceEntry({
    int? id,
    required String authUserId,
    required String subjectCode,
    required String subjectName,
    required int attended,
    required int total,
  }) = _AttendanceEntryImpl;

  factory AttendanceEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return AttendanceEntry(
      id: jsonSerialization['id'] as int?,
      authUserId: jsonSerialization['authUserId'] as String,
      subjectCode: jsonSerialization['subjectCode'] as String,
      subjectName: jsonSerialization['subjectName'] as String,
      attended: jsonSerialization['attended'] as int,
      total: jsonSerialization['total'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The Serverpod auth user identifier of the student.
  String authUserId;

  /// Subject code, e.g. CS-201.
  String subjectCode;

  /// Subject display name.
  String subjectName;

  /// Classes attended.
  int attended;

  /// Classes held in total.
  int total;

  /// Returns a shallow copy of this [AttendanceEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AttendanceEntry copyWith({
    int? id,
    String? authUserId,
    String? subjectCode,
    String? subjectName,
    int? attended,
    int? total,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AttendanceEntry',
      if (id != null) 'id': id,
      'authUserId': authUserId,
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'attended': attended,
      'total': total,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AttendanceEntry',
      if (id != null) 'id': id,
      'authUserId': authUserId,
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'attended': attended,
      'total': total,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AttendanceEntryImpl extends AttendanceEntry {
  _AttendanceEntryImpl({
    int? id,
    required String authUserId,
    required String subjectCode,
    required String subjectName,
    required int attended,
    required int total,
  }) : super._(
         id: id,
         authUserId: authUserId,
         subjectCode: subjectCode,
         subjectName: subjectName,
         attended: attended,
         total: total,
       );

  /// Returns a shallow copy of this [AttendanceEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AttendanceEntry copyWith({
    Object? id = _Undefined,
    String? authUserId,
    String? subjectCode,
    String? subjectName,
    int? attended,
    int? total,
  }) {
    return AttendanceEntry(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      attended: attended ?? this.attended,
      total: total ?? this.total,
    );
  }
}
