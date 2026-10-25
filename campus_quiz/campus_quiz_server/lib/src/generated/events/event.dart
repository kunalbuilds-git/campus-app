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
import '../events/event_category.dart' as _i2sr3i4w;

/// An event published on the campus events feed.
abstract class Event
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    _is.UuidValue? id,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      startsAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      endsAt: jsonSerialization['endsAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      location: jsonSerialization['location'] as String,
      organizer: jsonSerialization['organizer'] as String,
      capacity: jsonSerialization['capacity'] as int?,
      category: _i2sr3i4w.EventCategory.fromJson(
        (jsonSerialization['category'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = EventTable();

  static const db = EventRepository._();

  @override
  _is.UuidValue? id;

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

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Event]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Event copyWith({
    _is.UuidValue? id,
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

  static EventInclude include() {
    return EventInclude._();
  }

  static EventIncludeList includeList({
    _is.WhereExpressionBuilder<EventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EventTable>? orderBy,
    _is.OrderByListBuilder<EventTable>? orderByList,
    EventInclude? include,
  }) {
    return EventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Event.t),
      orderByList: orderByList?.call(Event.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EventImpl extends Event {
  _EventImpl({
    _is.UuidValue? id,
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
  @_is.useResult
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
      id: id is _is.UuidValue? ? id : this.id,
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

class EventUpdateTable extends _is.UpdateTable<EventTable> {
  EventUpdateTable(super.table);

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> startsAt(DateTime value) =>
      _is.ColumnValue(
        table.startsAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> endsAt(DateTime? value) =>
      _is.ColumnValue(
        table.endsAt,
        value,
      );

  _is.ColumnValue<String, String> location(String value) => _is.ColumnValue(
    table.location,
    value,
  );

  _is.ColumnValue<String, String> organizer(String value) => _is.ColumnValue(
    table.organizer,
    value,
  );

  _is.ColumnValue<int, int> capacity(int? value) => _is.ColumnValue(
    table.capacity,
    value,
  );

  _is.ColumnValue<_i2sr3i4w.EventCategory, _i2sr3i4w.EventCategory> category(
    _i2sr3i4w.EventCategory value,
  ) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class EventTable extends _is.Table<_is.UuidValue?> {
  EventTable({super.tableRelation}) : super(tableName: 'event') {
    updateTable = EventUpdateTable(this);
    title = _is.ColumnString(
      'title',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    startsAt = _is.ColumnDateTime(
      'startsAt',
      this,
    );
    endsAt = _is.ColumnDateTime(
      'endsAt',
      this,
    );
    location = _is.ColumnString(
      'location',
      this,
    );
    organizer = _is.ColumnString(
      'organizer',
      this,
    );
    capacity = _is.ColumnInt(
      'capacity',
      this,
    );
    category = _is.ColumnEnum(
      'category',
      this,
      _is.EnumSerialization.byName,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final EventUpdateTable updateTable;

  /// Short display title of the event.
  late final _is.ColumnString title;

  /// Longer free-text description shown on the event details screen.
  late final _is.ColumnString description;

  /// When the event starts.
  late final _is.ColumnDateTime startsAt;

  /// When the event ends. Null for open-ended events.
  late final _is.ColumnDateTime endsAt;

  /// Where the event takes place.
  late final _is.ColumnString location;

  /// Name of the organizing student club or department.
  late final _is.ColumnString organizer;

  /// Maximum number of `going` RSVPs. Null means unlimited.
  late final _is.ColumnInt capacity;

  /// Category used for filtering in the app.
  late final _is.ColumnEnum<_i2sr3i4w.EventCategory> category;

  /// Time the event was published.
  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    title,
    description,
    startsAt,
    endsAt,
    location,
    organizer,
    capacity,
    category,
    createdAt,
  ];
}

class EventInclude extends _is.IncludeObject {
  EventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Event.t;
}

class EventIncludeList extends _is.IncludeList {
  EventIncludeList._({
    _is.WhereExpressionBuilder<EventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Event.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Event.t;
}

class EventRepository {
  const EventRepository._();

  /// Returns a list of [Event]s matching the given query parameters.
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
  Future<List<Event>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EventTable>? orderBy,
    _is.OrderByListBuilder<EventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Event>(
      where: where?.call(Event.t),
      orderBy: orderBy?.call(Event.t),
      orderByList: orderByList?.call(Event.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Event] matching the given query parameters.
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
  Future<Event?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EventTable>? where,
    int? offset,
    _is.OrderByBuilder<EventTable>? orderBy,
    _is.OrderByListBuilder<EventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Event>(
      where: where?.call(Event.t),
      orderBy: orderBy?.call(Event.t),
      orderByList: orderByList?.call(Event.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Event] by its [id] or null if no such row exists.
  Future<Event?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Event>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Event]s in the list and returns the inserted rows.
  ///
  /// The returned [Event]s will have their `id` fields set.
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
  Future<List<Event>> insert(
    _is.DatabaseSession session,
    List<Event> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Event>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Event] and returns the inserted row.
  ///
  /// The returned [Event] will have its `id` field set.
  Future<Event> insertRow(
    _is.DatabaseSession session,
    Event row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Event>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Event]s in the list and returns the resulting rows.
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
  /// The returned [Event]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Event>> upsert(
    _is.DatabaseSession session,
    List<Event> rows, {
    required _is.ColumnSelections<EventTable> conflictColumns,
    _is.ColumnSelections<EventTable>? updateColumns,
    _is.WhereExpressionBuilder<EventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Event>(
      rows,
      conflictColumns: conflictColumns(Event.t),
      updateColumns: updateColumns?.call(Event.t),
      updateWhere: updateWhere?.call(Event.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Event] and returns the resulting row.
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
  /// The returned [Event] will have its `id` field set.
  Future<Event?> upsertRow(
    _is.DatabaseSession session,
    Event row, {
    required _is.ColumnSelections<EventTable> conflictColumns,
    _is.ColumnSelections<EventTable>? updateColumns,
    _is.WhereExpressionBuilder<EventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Event>(
      row,
      conflictColumns: conflictColumns(Event.t),
      updateColumns: updateColumns?.call(Event.t),
      updateWhere: updateWhere?.call(Event.t),
      transaction: transaction,
    );
  }

  /// Updates all [Event]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Event>> update(
    _is.DatabaseSession session,
    List<Event> rows, {
    _is.ColumnSelections<EventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Event>(
      rows,
      columns: columns?.call(Event.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Event]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Event> updateRow(
    _is.DatabaseSession session,
    Event row, {
    _is.ColumnSelections<EventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Event>(
      row,
      columns: columns?.call(Event.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Event] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Event?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<EventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Event>(
      id,
      columnValues: columnValues(Event.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Event]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Event>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<EventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EventTable>? orderBy,
    _is.OrderByListBuilder<EventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Event>(
      columnValues: columnValues(Event.t.updateTable),
      where: where(Event.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Event.t),
      orderByList: orderByList?.call(Event.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Event]s in the list and returns the deleted rows.
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
  Future<List<Event>> delete(
    _is.DatabaseSession session,
    List<Event> rows, {
    _is.OrderByBuilder<EventTable>? orderBy,
    _is.OrderByListBuilder<EventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Event>(
      rows,
      orderBy: orderBy?.call(Event.t),
      orderByList: orderByList?.call(Event.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Event].
  Future<Event> deleteRow(
    _is.DatabaseSession session,
    Event row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Event>(
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
  Future<List<Event>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EventTable> where,
    _is.OrderByBuilder<EventTable>? orderBy,
    _is.OrderByListBuilder<EventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Event>(
      where: where(Event.t),
      orderBy: orderBy?.call(Event.t),
      orderByList: orderByList?.call(Event.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Event>(
      where: where?.call(Event.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Event] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Event>(
      where: where(Event.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
