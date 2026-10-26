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

/// An item one student shared with another through a short code.
abstract class SharedItem
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SharedItemTable();

  static const db = SharedItemRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SharedItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static SharedItemInclude include() {
    return SharedItemInclude._();
  }

  static SharedItemIncludeList includeList({
    _is.WhereExpressionBuilder<SharedItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SharedItemTable>? orderBy,
    _is.OrderByListBuilder<SharedItemTable>? orderByList,
    SharedItemInclude? include,
  }) {
    return SharedItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SharedItem.t),
      orderByList: orderByList?.call(SharedItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class SharedItemUpdateTable extends _is.UpdateTable<SharedItemTable> {
  SharedItemUpdateTable(super.table);

  _is.ColumnValue<String, String> code(String value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> payload(String value) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SharedItemTable extends _is.Table<int?> {
  SharedItemTable({super.tableRelation}) : super(tableName: 'shared_item') {
    updateTable = SharedItemUpdateTable(this);
    code = _is.ColumnString(
      'code',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    payload = _is.ColumnString(
      'payload',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SharedItemUpdateTable updateTable;

  /// The six-character share code students type or scan.
  late final _is.ColumnString code;

  /// What is being shared: `notice` or `event`.
  late final _is.ColumnString kind;

  /// JSON payload of the shared item.
  late final _is.ColumnString payload;

  /// The auth user that created the share, for flood control.
  late final _is.ColumnString createdBy;

  /// Time the share was created.
  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    code,
    kind,
    payload,
    createdBy,
    createdAt,
  ];
}

class SharedItemInclude extends _is.IncludeObject {
  SharedItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SharedItem.t;
}

class SharedItemIncludeList extends _is.IncludeList {
  SharedItemIncludeList._({
    _is.WhereExpressionBuilder<SharedItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SharedItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SharedItem.t;
}

class SharedItemRepository {
  const SharedItemRepository._();

  /// Returns a list of [SharedItem]s matching the given query parameters.
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
  Future<List<SharedItem>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SharedItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SharedItemTable>? orderBy,
    _is.OrderByListBuilder<SharedItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SharedItem>(
      where: where?.call(SharedItem.t),
      orderBy: orderBy?.call(SharedItem.t),
      orderByList: orderByList?.call(SharedItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SharedItem] matching the given query parameters.
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
  Future<SharedItem?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SharedItemTable>? where,
    int? offset,
    _is.OrderByBuilder<SharedItemTable>? orderBy,
    _is.OrderByListBuilder<SharedItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SharedItem>(
      where: where?.call(SharedItem.t),
      orderBy: orderBy?.call(SharedItem.t),
      orderByList: orderByList?.call(SharedItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SharedItem] by its [id] or null if no such row exists.
  Future<SharedItem?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SharedItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SharedItem]s in the list and returns the inserted rows.
  ///
  /// The returned [SharedItem]s will have their `id` fields set.
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
  Future<List<SharedItem>> insert(
    _is.DatabaseSession session,
    List<SharedItem> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SharedItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SharedItem] and returns the inserted row.
  ///
  /// The returned [SharedItem] will have its `id` field set.
  Future<SharedItem> insertRow(
    _is.DatabaseSession session,
    SharedItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SharedItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SharedItem]s in the list and returns the resulting rows.
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
  /// The returned [SharedItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedItem>> upsert(
    _is.DatabaseSession session,
    List<SharedItem> rows, {
    required _is.ColumnSelections<SharedItemTable> conflictColumns,
    _is.ColumnSelections<SharedItemTable>? updateColumns,
    _is.WhereExpressionBuilder<SharedItemTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SharedItem>(
      rows,
      conflictColumns: conflictColumns(SharedItem.t),
      updateColumns: updateColumns?.call(SharedItem.t),
      updateWhere: updateWhere?.call(SharedItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SharedItem] and returns the resulting row.
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
  /// The returned [SharedItem] will have its `id` field set.
  Future<SharedItem?> upsertRow(
    _is.DatabaseSession session,
    SharedItem row, {
    required _is.ColumnSelections<SharedItemTable> conflictColumns,
    _is.ColumnSelections<SharedItemTable>? updateColumns,
    _is.WhereExpressionBuilder<SharedItemTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SharedItem>(
      row,
      conflictColumns: conflictColumns(SharedItem.t),
      updateColumns: updateColumns?.call(SharedItem.t),
      updateWhere: updateWhere?.call(SharedItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [SharedItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedItem>> update(
    _is.DatabaseSession session,
    List<SharedItem> rows, {
    _is.ColumnSelections<SharedItemTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SharedItem>(
      rows,
      columns: columns?.call(SharedItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SharedItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SharedItem> updateRow(
    _is.DatabaseSession session,
    SharedItem row, {
    _is.ColumnSelections<SharedItemTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SharedItem>(
      row,
      columns: columns?.call(SharedItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SharedItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SharedItem?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SharedItemUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SharedItem>(
      id,
      columnValues: columnValues(SharedItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SharedItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedItem>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SharedItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SharedItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SharedItemTable>? orderBy,
    _is.OrderByListBuilder<SharedItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SharedItem>(
      columnValues: columnValues(SharedItem.t.updateTable),
      where: where(SharedItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SharedItem.t),
      orderByList: orderByList?.call(SharedItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SharedItem]s in the list and returns the deleted rows.
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
  Future<List<SharedItem>> delete(
    _is.DatabaseSession session,
    List<SharedItem> rows, {
    _is.OrderByBuilder<SharedItemTable>? orderBy,
    _is.OrderByListBuilder<SharedItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SharedItem>(
      rows,
      orderBy: orderBy?.call(SharedItem.t),
      orderByList: orderByList?.call(SharedItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SharedItem].
  Future<SharedItem> deleteRow(
    _is.DatabaseSession session,
    SharedItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SharedItem>(
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
  Future<List<SharedItem>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SharedItemTable> where,
    _is.OrderByBuilder<SharedItemTable>? orderBy,
    _is.OrderByListBuilder<SharedItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SharedItem>(
      where: where(SharedItem.t),
      orderBy: orderBy?.call(SharedItem.t),
      orderByList: orderByList?.call(SharedItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SharedItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SharedItem>(
      where: where?.call(SharedItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SharedItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SharedItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SharedItem>(
      where: where(SharedItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
