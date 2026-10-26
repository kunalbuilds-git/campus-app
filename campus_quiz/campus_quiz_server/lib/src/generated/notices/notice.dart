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

/// A notice published on the campus digital notice board.
abstract class Notice implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      pinned: jsonSerialization['pinned'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['pinned']),
    );
  }

  static final t = NoticeTable();

  static const db = NoticeRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Notice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static NoticeInclude include() {
    return NoticeInclude._();
  }

  static NoticeIncludeList includeList({
    _is.WhereExpressionBuilder<NoticeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NoticeTable>? orderBy,
    _is.OrderByListBuilder<NoticeTable>? orderByList,
    NoticeInclude? include,
  }) {
    return NoticeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Notice.t),
      orderByList: orderByList?.call(Notice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class NoticeUpdateTable extends _is.UpdateTable<NoticeTable> {
  NoticeUpdateTable(super.table);

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> body(String value) => _is.ColumnValue(
    table.body,
    value,
  );

  _is.ColumnValue<String, String> category(String value) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<String, String> office(String value) => _is.ColumnValue(
    table.office,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> publishedAt(DateTime value) =>
      _is.ColumnValue(
        table.publishedAt,
        value,
      );

  _is.ColumnValue<bool, bool> pinned(bool value) => _is.ColumnValue(
    table.pinned,
    value,
  );
}

class NoticeTable extends _is.Table<int?> {
  NoticeTable({super.tableRelation}) : super(tableName: 'notice') {
    updateTable = NoticeUpdateTable(this);
    title = _is.ColumnString(
      'title',
      this,
    );
    body = _is.ColumnString(
      'body',
      this,
    );
    category = _is.ColumnString(
      'category',
      this,
    );
    office = _is.ColumnString(
      'office',
      this,
    );
    publishedAt = _is.ColumnDateTime(
      'publishedAt',
      this,
    );
    pinned = _is.ColumnBool(
      'pinned',
      this,
      hasDefault: true,
    );
  }

  late final NoticeUpdateTable updateTable;

  /// Headline shown on the board.
  late final _is.ColumnString title;

  /// Body text of the notice.
  late final _is.ColumnString body;

  /// Bucket used for the board's filters, e.g. Exams, Placement, Clubs.
  late final _is.ColumnString category;

  /// Office or society that published the notice.
  late final _is.ColumnString office;

  /// Time the notice was published.
  late final _is.ColumnDateTime publishedAt;

  /// Pinned notices float to the top of the board.
  late final _is.ColumnBool pinned;

  @override
  List<_is.Column> get columns => [
    id,
    title,
    body,
    category,
    office,
    publishedAt,
    pinned,
  ];
}

class NoticeInclude extends _is.IncludeObject {
  NoticeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Notice.t;
}

class NoticeIncludeList extends _is.IncludeList {
  NoticeIncludeList._({
    _is.WhereExpressionBuilder<NoticeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Notice.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Notice.t;
}

class NoticeRepository {
  const NoticeRepository._();

  /// Returns a list of [Notice]s matching the given query parameters.
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
  Future<List<Notice>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NoticeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NoticeTable>? orderBy,
    _is.OrderByListBuilder<NoticeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Notice>(
      where: where?.call(Notice.t),
      orderBy: orderBy?.call(Notice.t),
      orderByList: orderByList?.call(Notice.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Notice] matching the given query parameters.
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
  Future<Notice?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NoticeTable>? where,
    int? offset,
    _is.OrderByBuilder<NoticeTable>? orderBy,
    _is.OrderByListBuilder<NoticeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Notice>(
      where: where?.call(Notice.t),
      orderBy: orderBy?.call(Notice.t),
      orderByList: orderByList?.call(Notice.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Notice] by its [id] or null if no such row exists.
  Future<Notice?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Notice>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Notice]s in the list and returns the inserted rows.
  ///
  /// The returned [Notice]s will have their `id` fields set.
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
  Future<List<Notice>> insert(
    _is.DatabaseSession session,
    List<Notice> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Notice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Notice] and returns the inserted row.
  ///
  /// The returned [Notice] will have its `id` field set.
  Future<Notice> insertRow(
    _is.DatabaseSession session,
    Notice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Notice>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Notice]s in the list and returns the resulting rows.
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
  /// The returned [Notice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Notice>> upsert(
    _is.DatabaseSession session,
    List<Notice> rows, {
    required _is.ColumnSelections<NoticeTable> conflictColumns,
    _is.ColumnSelections<NoticeTable>? updateColumns,
    _is.WhereExpressionBuilder<NoticeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Notice>(
      rows,
      conflictColumns: conflictColumns(Notice.t),
      updateColumns: updateColumns?.call(Notice.t),
      updateWhere: updateWhere?.call(Notice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Notice] and returns the resulting row.
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
  /// The returned [Notice] will have its `id` field set.
  Future<Notice?> upsertRow(
    _is.DatabaseSession session,
    Notice row, {
    required _is.ColumnSelections<NoticeTable> conflictColumns,
    _is.ColumnSelections<NoticeTable>? updateColumns,
    _is.WhereExpressionBuilder<NoticeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Notice>(
      row,
      conflictColumns: conflictColumns(Notice.t),
      updateColumns: updateColumns?.call(Notice.t),
      updateWhere: updateWhere?.call(Notice.t),
      transaction: transaction,
    );
  }

  /// Updates all [Notice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Notice>> update(
    _is.DatabaseSession session,
    List<Notice> rows, {
    _is.ColumnSelections<NoticeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Notice>(
      rows,
      columns: columns?.call(Notice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Notice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Notice> updateRow(
    _is.DatabaseSession session,
    Notice row, {
    _is.ColumnSelections<NoticeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Notice>(
      row,
      columns: columns?.call(Notice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Notice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Notice?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<NoticeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Notice>(
      id,
      columnValues: columnValues(Notice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Notice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Notice>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<NoticeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<NoticeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NoticeTable>? orderBy,
    _is.OrderByListBuilder<NoticeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Notice>(
      columnValues: columnValues(Notice.t.updateTable),
      where: where(Notice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Notice.t),
      orderByList: orderByList?.call(Notice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Notice]s in the list and returns the deleted rows.
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
  Future<List<Notice>> delete(
    _is.DatabaseSession session,
    List<Notice> rows, {
    _is.OrderByBuilder<NoticeTable>? orderBy,
    _is.OrderByListBuilder<NoticeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Notice>(
      rows,
      orderBy: orderBy?.call(Notice.t),
      orderByList: orderByList?.call(Notice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Notice].
  Future<Notice> deleteRow(
    _is.DatabaseSession session,
    Notice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Notice>(
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
  Future<List<Notice>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NoticeTable> where,
    _is.OrderByBuilder<NoticeTable>? orderBy,
    _is.OrderByListBuilder<NoticeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Notice>(
      where: where(Notice.t),
      orderBy: orderBy?.call(Notice.t),
      orderByList: orderByList?.call(Notice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NoticeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Notice>(
      where: where?.call(Notice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Notice] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NoticeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Notice>(
      where: where(Notice.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
