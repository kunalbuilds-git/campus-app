/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:campus_quiz_server/src/generated/events/event_summary.dart'
    as _iew5lf5r;
import 'package:campus_quiz_server/src/generated/events/rsvp.dart' as _iiw3sxrr;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'events/event.dart' as _iq09ghc5;
import 'events/event_category.dart' as _in056s28;
import 'events/event_exception.dart' as _ikkdwwzc;
import 'events/event_summary.dart' as _i41vm8xm;
import 'events/rsvp.dart' as _ibgfe0cw;
import 'events/rsvp_status.dart' as _i8nmnugq;
import 'greetings/greeting.dart' as _izw8z7ou;
export 'events/event.dart';
export 'events/event_category.dart';
export 'events/event_exception.dart';
export 'events/event_summary.dart';
export 'events/rsvp.dart';
export 'events/rsvp_status.dart';
export 'greetings/greeting.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'event',
      dartName: 'Event',
      schema: 'public',
      module: 'campus_quiz',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'startsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'location',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'organizer',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'capacity',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'category',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EventCategory',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'event_starts_at_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'startsAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'rsvp',
      dartName: 'Rsvp',
      schema: 'public',
      module: 'campus_quiz',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'eventId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:RsvpStatus',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'rsvp_fk_0',
          columns: ['eventId'],
          referenceTable: 'event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'rsvp_event_user_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'rsvp_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iq09ghc5.Event) {
      return _iq09ghc5.Event.fromJson(data) as T;
    }
    if (t == _in056s28.EventCategory) {
      return _in056s28.EventCategory.fromJson(data) as T;
    }
    if (t == _ikkdwwzc.EventException) {
      return _ikkdwwzc.EventException.fromJson(data) as T;
    }
    if (t == _i41vm8xm.EventSummary) {
      return _i41vm8xm.EventSummary.fromJson(data) as T;
    }
    if (t == _ibgfe0cw.Rsvp) {
      return _ibgfe0cw.Rsvp.fromJson(data) as T;
    }
    if (t == _i8nmnugq.RsvpStatus) {
      return _i8nmnugq.RsvpStatus.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _is.getType<_iq09ghc5.Event?>()) {
      return (data != null ? _iq09ghc5.Event.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_in056s28.EventCategory?>()) {
      return (data != null ? _in056s28.EventCategory.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikkdwwzc.EventException?>()) {
      return (data != null ? _ikkdwwzc.EventException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i41vm8xm.EventSummary?>()) {
      return (data != null ? _i41vm8xm.EventSummary.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ibgfe0cw.Rsvp?>()) {
      return (data != null ? _ibgfe0cw.Rsvp.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8nmnugq.RsvpStatus?>()) {
      return (data != null ? _i8nmnugq.RsvpStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == List<_iew5lf5r.EventSummary>) {
      return (data as List)
              .map((e) => deserialize<_iew5lf5r.EventSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_iiw3sxrr.Rsvp>) {
      return (data as List).map((e) => deserialize<_iiw3sxrr.Rsvp>(e)).toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iq09ghc5.Event => 'Event',
      _in056s28.EventCategory => 'EventCategory',
      _ikkdwwzc.EventException => 'EventException',
      _i41vm8xm.EventSummary => 'EventSummary',
      _ibgfe0cw.Rsvp => 'Rsvp',
      _i8nmnugq.RsvpStatus => 'RsvpStatus',
      _izw8z7ou.Greeting => 'Greeting',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('campus_quiz.', '');
    }

    switch (data) {
      case _iq09ghc5.Event():
        return 'Event';
      case _in056s28.EventCategory():
        return 'EventCategory';
      case _ikkdwwzc.EventException():
        return 'EventException';
      case _i41vm8xm.EventSummary():
        return 'EventSummary';
      case _ibgfe0cw.Rsvp():
        return 'Rsvp';
      case _i8nmnugq.RsvpStatus():
        return 'RsvpStatus';
      case _izw8z7ou.Greeting():
        return 'Greeting';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Event') {
      return deserialize<_iq09ghc5.Event>(data['data']);
    }
    if (dataClassName == 'EventCategory') {
      return deserialize<_in056s28.EventCategory>(data['data']);
    }
    if (dataClassName == 'EventException') {
      return deserialize<_ikkdwwzc.EventException>(data['data']);
    }
    if (dataClassName == 'EventSummary') {
      return deserialize<_i41vm8xm.EventSummary>(data['data']);
    }
    if (dataClassName == 'Rsvp') {
      return deserialize<_ibgfe0cw.Rsvp>(data['data']);
    }
    if (dataClassName == 'RsvpStatus') {
      return deserialize<_i8nmnugq.RsvpStatus>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('campus_quiz', this);
    _iacs.Protocol().registerHostProtocol('campus_quiz', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iq09ghc5.Event:
        return _iq09ghc5.Event.t;
      case _ibgfe0cw.Rsvp:
        return _ibgfe0cw.Rsvp.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'campus_quiz';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
