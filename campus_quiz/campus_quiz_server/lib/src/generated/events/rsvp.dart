/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:campus_quiz_server/src/generated/protocol.dart' as _ift8zms9;
import 'package:serverpod/serverpod.dart' as _is;
import '../events/event.dart' as _inam5zsn;
import '../events/rsvp_status.dart' as _iiv55n98;

/// A user's RSVP to an event.
abstract class Rsvp
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Rsvp._({
    this.id,
    required this.eventId,
    this.event,
    required this.authUserId,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Rsvp({
    _is.UuidValue? id,
    required _is.UuidValue eventId,
    _inam5zsn.Event? event,
    required String authUserId,
    required _iiv55n98.RsvpStatus status,
    DateTime? createdAt,
  }) = _RsvpImpl;

  factory Rsvp.fromJson(Map<String, dynamic> jsonSerialization) {
    return Rsvp(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      event: jsonSerialization['event'] == null
          ? null
          : _ift8zms9.Protocol().deserialize<_inam5zsn.Event>(
              jsonSerialization['event'],
            ),
      authUserId: jsonSerialization['authUserId'] as String,
      status: _iiv55n98.RsvpStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = RsvpTable();

  static const db = RsvpRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue eventId;

  /// The event this RSVP belongs to.
  _inam5zsn.Event? event;

  /// The Serverpod auth user identifier of the attendee.
  String authUserId;

  /// The attendance status registered by the user.
  _iiv55n98.RsvpStatus status;

  /// Time the RSVP was first created.
  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Rsvp]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Rsvp copyWith({
    _is.UuidValue? id,
    _is.UuidValue? eventId,
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

  static RsvpInclude include({_inam5zsn.EventInclude? event}) {
    return RsvpInclude._(event: event);
  }

  static RsvpIncludeList includeList({
    _is.WhereExpressionBuilder<RsvpTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RsvpTable>? orderBy,
    _is.OrderByListBuilder<RsvpTable>? orderByList,
    RsvpInclude? include,
  }) {
    return RsvpIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Rsvp.t),
      orderByList: orderByList?.call(Rsvp.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RsvpImpl extends Rsvp {
  _RsvpImpl({
    _is.UuidValue? id,
    required _is.UuidValue eventId,
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
  @_is.useResult
  @override
  Rsvp copyWith({
    Object? id = _Undefined,
    _is.UuidValue? eventId,
    Object? event = _Undefined,
    String? authUserId,
    _iiv55n98.RsvpStatus? status,
    DateTime? createdAt,
  }) {
    return Rsvp(
      id: id is _is.UuidValue? ? id : this.id,
      eventId: eventId ?? this.eventId,
      event: event is _inam5zsn.Event? ? event : this.event?.copyWith(),
      authUserId: authUserId ?? this.authUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RsvpUpdateTable extends _is.UpdateTable<RsvpTable> {
  RsvpUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> eventId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.eventId,
        value,
      );

  _is.ColumnValue<String, String> authUserId(String value) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<_iiv55n98.RsvpStatus, _iiv55n98.RsvpStatus> status(
    _iiv55n98.RsvpStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class RsvpTable extends _is.Table<_is.UuidValue?> {
  RsvpTable({super.tableRelation}) : super(tableName: 'rsvp') {
    updateTable = RsvpUpdateTable(this);
    eventId = _is.ColumnUuid(
      'eventId',
      this,
    );
    authUserId = _is.ColumnString(
      'authUserId',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final RsvpUpdateTable updateTable;

  late final _is.ColumnUuid eventId;

  /// The event this RSVP belongs to.
  _inam5zsn.EventTable? _event;

  /// The Serverpod auth user identifier of the attendee.
  late final _is.ColumnString authUserId;

  /// The attendance status registered by the user.
  late final _is.ColumnEnum<_iiv55n98.RsvpStatus> status;

  /// Time the RSVP was first created.
  late final _is.ColumnDateTime createdAt;

  _inam5zsn.EventTable get event {
    if (_event != null) return _event!;
    _event = _is.createRelationTable(
      relationFieldName: 'event',
      field: Rsvp.t.eventId,
      foreignField: _inam5zsn.Event.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _inam5zsn.EventTable(tableRelation: foreignTableRelation),
    );
    return _event!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    eventId,
    authUserId,
    status,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'event') {
      return event;
    }
    return null;
  }
}

class RsvpInclude extends _is.IncludeObject {
  RsvpInclude._({_inam5zsn.EventInclude? event}) {
    _event = event;
  }

  _inam5zsn.EventInclude? _event;

  @override
  Map<String, _is.Include?> get includes => {'event': _event};

  @override
  _is.Table<_is.UuidValue?> get table => Rsvp.t;
}

class RsvpIncludeList extends _is.IncludeList {
  RsvpIncludeList._({
    _is.WhereExpressionBuilder<RsvpTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Rsvp.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Rsvp.t;
}

class RsvpRepository {
  const RsvpRepository._();

  final attachRow = const RsvpAttachRowRepository._();

  /// Returns a list of [Rsvp]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Rsvp>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RsvpTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RsvpTable>? orderBy,
    _is.OrderByListBuilder<RsvpTable>? orderByList,
    _is.Transaction? transaction,
    RsvpInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Rsvp>(
      where: where?.call(Rsvp.t),
      orderBy: orderBy?.call(Rsvp.t),
      orderByList: orderByList?.call(Rsvp.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Rsvp] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Rsvp?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RsvpTable>? where,
    int? offset,
    _is.OrderByBuilder<RsvpTable>? orderBy,
    _is.OrderByListBuilder<RsvpTable>? orderByList,
    _is.Transaction? transaction,
    RsvpInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Rsvp>(
      where: where?.call(Rsvp.t),
      orderBy: orderBy?.call(Rsvp.t),
      orderByList: orderByList?.call(Rsvp.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Rsvp] by its [id] or null if no such row exists.
  Future<Rsvp?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    RsvpInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Rsvp>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Rsvp]s in the list and returns the inserted rows.
  ///
  /// The returned [Rsvp]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Rsvp>> insert(
    _is.DatabaseSession session,
    List<Rsvp> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Rsvp>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Rsvp] and returns the inserted row.
  ///
  /// The returned [Rsvp] will have its `id` field set.
  Future<Rsvp> insertRow(
    _is.DatabaseSession session,
    Rsvp row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Rsvp>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Rsvp]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Rsvp]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Rsvp>> upsert(
    _is.DatabaseSession session,
    List<Rsvp> rows, {
    required _is.ColumnSelections<RsvpTable> conflictColumns,
    _is.ColumnSelections<RsvpTable>? updateColumns,
    _is.WhereExpressionBuilder<RsvpTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Rsvp>(
      rows,
      conflictColumns: conflictColumns(Rsvp.t),
      updateColumns: updateColumns?.call(Rsvp.t),
      updateWhere: updateWhere?.call(Rsvp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Rsvp] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Rsvp] will have its `id` field set.
  Future<Rsvp?> upsertRow(
    _is.DatabaseSession session,
    Rsvp row, {
    required _is.ColumnSelections<RsvpTable> conflictColumns,
    _is.ColumnSelections<RsvpTable>? updateColumns,
    _is.WhereExpressionBuilder<RsvpTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Rsvp>(
      row,
      conflictColumns: conflictColumns(Rsvp.t),
      updateColumns: updateColumns?.call(Rsvp.t),
      updateWhere: updateWhere?.call(Rsvp.t),
      transaction: transaction,
    );
  }

  /// Updates all [Rsvp]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Rsvp>> update(
    _is.DatabaseSession session,
    List<Rsvp> rows, {
    _is.ColumnSelections<RsvpTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Rsvp>(
      rows,
      columns: columns?.call(Rsvp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Rsvp]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Rsvp> updateRow(
    _is.DatabaseSession session,
    Rsvp row, {
    _is.ColumnSelections<RsvpTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Rsvp>(
      row,
      columns: columns?.call(Rsvp.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Rsvp] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Rsvp?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<RsvpUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Rsvp>(
      id,
      columnValues: columnValues(Rsvp.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Rsvp]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Rsvp>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RsvpUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RsvpTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RsvpTable>? orderBy,
    _is.OrderByListBuilder<RsvpTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Rsvp>(
      columnValues: columnValues(Rsvp.t.updateTable),
      where: where(Rsvp.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Rsvp.t),
      orderByList: orderByList?.call(Rsvp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Rsvp]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Rsvp>> delete(
    _is.DatabaseSession session,
    List<Rsvp> rows, {
    _is.OrderByBuilder<RsvpTable>? orderBy,
    _is.OrderByListBuilder<RsvpTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Rsvp>(
      rows,
      orderBy: orderBy?.call(Rsvp.t),
      orderByList: orderByList?.call(Rsvp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Rsvp].
  Future<Rsvp> deleteRow(
    _is.DatabaseSession session,
    Rsvp row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Rsvp>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Rsvp>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RsvpTable> where,
    _is.OrderByBuilder<RsvpTable>? orderBy,
    _is.OrderByListBuilder<RsvpTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Rsvp>(
      where: where(Rsvp.t),
      orderBy: orderBy?.call(Rsvp.t),
      orderByList: orderByList?.call(Rsvp.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RsvpTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Rsvp>(
      where: where?.call(Rsvp.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Rsvp] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RsvpTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Rsvp>(
      where: where(Rsvp.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class RsvpAttachRowRepository {
  const RsvpAttachRowRepository._();

  /// Creates a relation between the given [Rsvp] and [Event]
  /// by setting the [Rsvp]'s foreign key `eventId` to refer to the [Event].
  Future<void> event(
    _is.DatabaseSession session,
    Rsvp rsvp,
    _inam5zsn.Event event, {
    _is.Transaction? transaction,
  }) async {
    if (rsvp.id == null) {
      throw ArgumentError.notNull('rsvp.id');
    }
    if (event.id == null) {
      throw ArgumentError.notNull('event.id');
    }

    var $rsvp = rsvp.copyWith(eventId: event.id);
    await session.db.updateRow<Rsvp>(
      $rsvp,
      columns: [Rsvp.t.eventId],
      transaction: transaction,
    );
  }
}
