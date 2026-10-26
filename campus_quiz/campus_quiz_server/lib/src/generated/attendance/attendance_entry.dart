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
import 'package:serverpod/serverpod.dart' as _is;

/// One subject's attendance record for a student.
abstract class AttendanceEntry
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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

  static final t = AttendanceEntryTable();

  static const db = AttendanceEntryRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AttendanceEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static AttendanceEntryInclude include() {
    return AttendanceEntryInclude._();
  }

  static AttendanceEntryIncludeList includeList({
    _is.WhereExpressionBuilder<AttendanceEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AttendanceEntryTable>? orderBy,
    _is.OrderByListBuilder<AttendanceEntryTable>? orderByList,
    AttendanceEntryInclude? include,
  }) {
    return AttendanceEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AttendanceEntry.t),
      orderByList: orderByList?.call(AttendanceEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class AttendanceEntryUpdateTable extends _is.UpdateTable<AttendanceEntryTable> {
  AttendanceEntryUpdateTable(super.table);

  _is.ColumnValue<String, String> authUserId(String value) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> subjectCode(String value) => _is.ColumnValue(
    table.subjectCode,
    value,
  );

  _is.ColumnValue<String, String> subjectName(String value) => _is.ColumnValue(
    table.subjectName,
    value,
  );

  _is.ColumnValue<int, int> attended(int value) => _is.ColumnValue(
    table.attended,
    value,
  );

  _is.ColumnValue<int, int> total(int value) => _is.ColumnValue(
    table.total,
    value,
  );
}

class AttendanceEntryTable extends _is.Table<int?> {
  AttendanceEntryTable({super.tableRelation})
    : super(tableName: 'attendance_entry') {
    updateTable = AttendanceEntryUpdateTable(this);
    authUserId = _is.ColumnString(
      'authUserId',
      this,
    );
    subjectCode = _is.ColumnString(
      'subjectCode',
      this,
    );
    subjectName = _is.ColumnString(
      'subjectName',
      this,
    );
    attended = _is.ColumnInt(
      'attended',
      this,
    );
    total = _is.ColumnInt(
      'total',
      this,
    );
  }

  late final AttendanceEntryUpdateTable updateTable;

  /// The Serverpod auth user identifier of the student.
  late final _is.ColumnString authUserId;

  /// Subject code, e.g. CS-201.
  late final _is.ColumnString subjectCode;

  /// Subject display name.
  late final _is.ColumnString subjectName;

  /// Classes attended.
  late final _is.ColumnInt attended;

  /// Classes held in total.
  late final _is.ColumnInt total;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    subjectCode,
    subjectName,
    attended,
    total,
  ];
}

class AttendanceEntryInclude extends _is.IncludeObject {
  AttendanceEntryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AttendanceEntry.t;
}

class AttendanceEntryIncludeList extends _is.IncludeList {
  AttendanceEntryIncludeList._({
    _is.WhereExpressionBuilder<AttendanceEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AttendanceEntry.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AttendanceEntry.t;
}

class AttendanceEntryRepository {
  const AttendanceEntryRepository._();

  /// Returns a list of [AttendanceEntry]s matching the given query parameters.
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
  Future<List<AttendanceEntry>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AttendanceEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AttendanceEntryTable>? orderBy,
    _is.OrderByListBuilder<AttendanceEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AttendanceEntry>(
      where: where?.call(AttendanceEntry.t),
      orderBy: orderBy?.call(AttendanceEntry.t),
      orderByList: orderByList?.call(AttendanceEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AttendanceEntry] matching the given query parameters.
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
  Future<AttendanceEntry?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AttendanceEntryTable>? where,
    int? offset,
    _is.OrderByBuilder<AttendanceEntryTable>? orderBy,
    _is.OrderByListBuilder<AttendanceEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AttendanceEntry>(
      where: where?.call(AttendanceEntry.t),
      orderBy: orderBy?.call(AttendanceEntry.t),
      orderByList: orderByList?.call(AttendanceEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AttendanceEntry] by its [id] or null if no such row exists.
  Future<AttendanceEntry?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AttendanceEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AttendanceEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [AttendanceEntry]s will have their `id` fields set.
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
  Future<List<AttendanceEntry>> insert(
    _is.DatabaseSession session,
    List<AttendanceEntry> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AttendanceEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AttendanceEntry] and returns the inserted row.
  ///
  /// The returned [AttendanceEntry] will have its `id` field set.
  Future<AttendanceEntry> insertRow(
    _is.DatabaseSession session,
    AttendanceEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AttendanceEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AttendanceEntry]s in the list and returns the resulting rows.
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
  /// The returned [AttendanceEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AttendanceEntry>> upsert(
    _is.DatabaseSession session,
    List<AttendanceEntry> rows, {
    required _is.ColumnSelections<AttendanceEntryTable> conflictColumns,
    _is.ColumnSelections<AttendanceEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<AttendanceEntryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AttendanceEntry>(
      rows,
      conflictColumns: conflictColumns(AttendanceEntry.t),
      updateColumns: updateColumns?.call(AttendanceEntry.t),
      updateWhere: updateWhere?.call(AttendanceEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AttendanceEntry] and returns the resulting row.
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
  /// The returned [AttendanceEntry] will have its `id` field set.
  Future<AttendanceEntry?> upsertRow(
    _is.DatabaseSession session,
    AttendanceEntry row, {
    required _is.ColumnSelections<AttendanceEntryTable> conflictColumns,
    _is.ColumnSelections<AttendanceEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<AttendanceEntryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AttendanceEntry>(
      row,
      conflictColumns: conflictColumns(AttendanceEntry.t),
      updateColumns: updateColumns?.call(AttendanceEntry.t),
      updateWhere: updateWhere?.call(AttendanceEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [AttendanceEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AttendanceEntry>> update(
    _is.DatabaseSession session,
    List<AttendanceEntry> rows, {
    _is.ColumnSelections<AttendanceEntryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AttendanceEntry>(
      rows,
      columns: columns?.call(AttendanceEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AttendanceEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AttendanceEntry> updateRow(
    _is.DatabaseSession session,
    AttendanceEntry row, {
    _is.ColumnSelections<AttendanceEntryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AttendanceEntry>(
      row,
      columns: columns?.call(AttendanceEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AttendanceEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AttendanceEntry?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AttendanceEntryUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AttendanceEntry>(
      id,
      columnValues: columnValues(AttendanceEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AttendanceEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AttendanceEntry>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AttendanceEntryUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AttendanceEntryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AttendanceEntryTable>? orderBy,
    _is.OrderByListBuilder<AttendanceEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AttendanceEntry>(
      columnValues: columnValues(AttendanceEntry.t.updateTable),
      where: where(AttendanceEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AttendanceEntry.t),
      orderByList: orderByList?.call(AttendanceEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AttendanceEntry]s in the list and returns the deleted rows.
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
  Future<List<AttendanceEntry>> delete(
    _is.DatabaseSession session,
    List<AttendanceEntry> rows, {
    _is.OrderByBuilder<AttendanceEntryTable>? orderBy,
    _is.OrderByListBuilder<AttendanceEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AttendanceEntry>(
      rows,
      orderBy: orderBy?.call(AttendanceEntry.t),
      orderByList: orderByList?.call(AttendanceEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AttendanceEntry].
  Future<AttendanceEntry> deleteRow(
    _is.DatabaseSession session,
    AttendanceEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AttendanceEntry>(
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
  Future<List<AttendanceEntry>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AttendanceEntryTable> where,
    _is.OrderByBuilder<AttendanceEntryTable>? orderBy,
    _is.OrderByListBuilder<AttendanceEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AttendanceEntry>(
      where: where(AttendanceEntry.t),
      orderBy: orderBy?.call(AttendanceEntry.t),
      orderByList: orderByList?.call(AttendanceEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AttendanceEntryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AttendanceEntry>(
      where: where?.call(AttendanceEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AttendanceEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AttendanceEntryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AttendanceEntry>(
      where: where(AttendanceEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
