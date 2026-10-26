import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Public API of the campus notice board.
class NoticesEndpoint extends Endpoint {
  /// Lists notices, pinned first, newest first.
  ///
  /// [category] filters by bucket, [pinnedOnly] keeps only pinned notices,
  /// and [limit] is clamped to 1..100 (default 50).
  Future<List<Notice>> listNotices(
    Session session, {
    String? category,
    bool? pinnedOnly,
    int? limit,
  }) async {
    final clamped = (limit ?? 50).clamp(1, 100);

    return Notice.db.find(
      session,
      where: (t) {
        Expression expression = Constant.bool(true);
        if (category != null) {
          expression &= t.category.equals(category);
        }
        if (pinnedOnly ?? false) {
          expression &= t.pinned.equals(true);
        }
        return expression;
      },
      orderBy: (t) => t.publishedAt.desc(),
      limit: clamped,
    );
  }

  /// Publishes a notice.
  ///
  /// Deliberately gated: publishing to the campus board must never be an
  /// anonymous action. Office tooling is expected to act through a signed-in
  /// account; a role check lands with the admin surface.
  Future<Notice> publish(
    Session session, {
    required String title,
    required String body,
    required String category,
    required String office,
    bool? pinned,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw NoticeException(
        code: 'UNAUTHENTICATED',
        message: 'Publishing a notice requires a signed-in account.',
      );
    }
    return Notice.db.insertRow(
      session,
      Notice(
        title: title,
        body: body,
        category: category,
        office: office,
        pinned: pinned ?? false,
      ),
    );
  }
}
