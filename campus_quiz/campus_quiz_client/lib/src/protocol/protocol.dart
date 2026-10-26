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
import 'package:campus_quiz_client/src/protocol/attendance/attendance_entry.dart'
    as _i1ulllcz;
import 'package:campus_quiz_client/src/protocol/events/event_summary.dart'
    as _id5dtabc;
import 'package:campus_quiz_client/src/protocol/events/rsvp.dart' as _ihpaob0u;
import 'package:campus_quiz_client/src/protocol/notices/notice.dart'
    as _ibkk20sa;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'attendance/attendance_entry.dart' as _i6cjsyrg;
import 'attendance/attendance_exception.dart' as _ist1gidr;
import 'events/event.dart' as _iq09ghc5;
import 'events/event_category.dart' as _in056s28;
import 'events/event_exception.dart' as _ikkdwwzc;
import 'events/event_summary.dart' as _i41vm8xm;
import 'events/rsvp.dart' as _ibgfe0cw;
import 'events/rsvp_status.dart' as _i8nmnugq;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'notices/notice.dart' as _is7ha23q;
import 'notices/notice_exception.dart' as _ixtz6m9s;
import 'sharing/share_exception.dart' as _ifmgnpzw;
import 'sharing/shared_item.dart' as _iyajaqhn;
export 'attendance/attendance_entry.dart';
export 'attendance/attendance_exception.dart';
export 'events/event.dart';
export 'events/event_category.dart';
export 'events/event_exception.dart';
export 'events/event_summary.dart';
export 'events/rsvp.dart';
export 'events/rsvp_status.dart';
export 'greetings/greeting.dart';
export 'notices/notice.dart';
export 'notices/notice_exception.dart';
export 'sharing/share_exception.dart';
export 'sharing/shared_item.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i6cjsyrg.AttendanceEntry) {
      return _i6cjsyrg.AttendanceEntry.fromJson(data) as T;
    }
    if (t == _ist1gidr.AttendanceException) {
      return _ist1gidr.AttendanceException.fromJson(data) as T;
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
    if (t == _is7ha23q.Notice) {
      return _is7ha23q.Notice.fromJson(data) as T;
    }
    if (t == _ixtz6m9s.NoticeException) {
      return _ixtz6m9s.NoticeException.fromJson(data) as T;
    }
    if (t == _ifmgnpzw.ShareException) {
      return _ifmgnpzw.ShareException.fromJson(data) as T;
    }
    if (t == _iyajaqhn.SharedItem) {
      return _iyajaqhn.SharedItem.fromJson(data) as T;
    }
    if (t == _isc.getType<_i6cjsyrg.AttendanceEntry?>()) {
      return (data != null ? _i6cjsyrg.AttendanceEntry.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ist1gidr.AttendanceException?>()) {
      return (data != null
              ? _ist1gidr.AttendanceException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iq09ghc5.Event?>()) {
      return (data != null ? _iq09ghc5.Event.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_in056s28.EventCategory?>()) {
      return (data != null ? _in056s28.EventCategory.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikkdwwzc.EventException?>()) {
      return (data != null ? _ikkdwwzc.EventException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i41vm8xm.EventSummary?>()) {
      return (data != null ? _i41vm8xm.EventSummary.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ibgfe0cw.Rsvp?>()) {
      return (data != null ? _ibgfe0cw.Rsvp.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i8nmnugq.RsvpStatus?>()) {
      return (data != null ? _i8nmnugq.RsvpStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_is7ha23q.Notice?>()) {
      return (data != null ? _is7ha23q.Notice.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixtz6m9s.NoticeException?>()) {
      return (data != null ? _ixtz6m9s.NoticeException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ifmgnpzw.ShareException?>()) {
      return (data != null ? _ifmgnpzw.ShareException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iyajaqhn.SharedItem?>()) {
      return (data != null ? _iyajaqhn.SharedItem.fromJson(data) : null) as T;
    }
    if (t == List<_i1ulllcz.AttendanceEntry>) {
      return (data as List)
              .map((e) => deserialize<_i1ulllcz.AttendanceEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_id5dtabc.EventSummary>) {
      return (data as List)
              .map((e) => deserialize<_id5dtabc.EventSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_ihpaob0u.Rsvp>) {
      return (data as List).map((e) => deserialize<_ihpaob0u.Rsvp>(e)).toList()
          as T;
    }
    if (t == List<_ibkk20sa.Notice>) {
      return (data as List)
              .map((e) => deserialize<_ibkk20sa.Notice>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i6cjsyrg.AttendanceEntry => 'AttendanceEntry',
      _ist1gidr.AttendanceException => 'AttendanceException',
      _iq09ghc5.Event => 'Event',
      _in056s28.EventCategory => 'EventCategory',
      _ikkdwwzc.EventException => 'EventException',
      _i41vm8xm.EventSummary => 'EventSummary',
      _ibgfe0cw.Rsvp => 'Rsvp',
      _i8nmnugq.RsvpStatus => 'RsvpStatus',
      _izw8z7ou.Greeting => 'Greeting',
      _is7ha23q.Notice => 'Notice',
      _ixtz6m9s.NoticeException => 'NoticeException',
      _ifmgnpzw.ShareException => 'ShareException',
      _iyajaqhn.SharedItem => 'SharedItem',
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
      case _i6cjsyrg.AttendanceEntry():
        return 'AttendanceEntry';
      case _ist1gidr.AttendanceException():
        return 'AttendanceException';
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
      case _is7ha23q.Notice():
        return 'Notice';
      case _ixtz6m9s.NoticeException():
        return 'NoticeException';
      case _ifmgnpzw.ShareException():
        return 'ShareException';
      case _iyajaqhn.SharedItem():
        return 'SharedItem';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AttendanceEntry') {
      return deserialize<_i6cjsyrg.AttendanceEntry>(data['data']);
    }
    if (dataClassName == 'AttendanceException') {
      return deserialize<_ist1gidr.AttendanceException>(data['data']);
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
    if (dataClassName == 'Notice') {
      return deserialize<_is7ha23q.Notice>(data['data']);
    }
    if (dataClassName == 'NoticeException') {
      return deserialize<_ixtz6m9s.NoticeException>(data['data']);
    }
    if (dataClassName == 'ShareException') {
      return deserialize<_ifmgnpzw.ShareException>(data['data']);
    }
    if (dataClassName == 'SharedItem') {
      return deserialize<_iyajaqhn.SharedItem>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('campus_quiz', this);
    _iacc.Protocol().registerHostProtocol('campus_quiz', this);
  }

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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
