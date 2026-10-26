import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// AirDrop-style sharing: one student turns anything in the app into a
/// six-character code, the other types or scans it.
class ShareEndpoint extends Endpoint {
  static const String _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static final Random _random = Random();

  /// Payloads above this size are rejected — shares carry one item, not a
  /// database.
  static const int _maxPayloadChars = 8192;

  /// How many shares one account may create per hour before being capped.
  static const int _maxSharesPerHour = 50;

  /// Wraps [payload] into a share and returns its code.
  ///
  /// [kind] is `notice` or `event`; [payload] is the item's JSON. Requires a
  /// signed-in account (anonymous accounts count) so flooding can be traced
  /// and capped per account.
  Future<SharedItem> createShare(
    Session session, {
    required String kind,
    required String payload,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw ShareException(
        code: 'UNAUTHENTICATED',
        message: 'Sharing requires a signed-in account.',
      );
    }
    if (payload.length > _maxPayloadChars) {
      throw ShareException(
        code: 'PAYLOAD_TOO_LARGE',
        message: 'The item being shared is too large.',
      );
    }
    if (kind != 'notice' && kind != 'event') {
      throw ShareException(
        code: 'UNKNOWN_KIND',
        message: 'Shares can carry a notice or an event.',
      );
    }

    // Flood cap: one account cannot bury the code space.
    final userId = authInfo.userIdentifier;
    final hourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final recentCount = await SharedItem.db.count(
      session,
      where: (t) => t.createdBy.equals(userId) & (t.createdAt > hourAgo),
    );
    if (recentCount >= _maxSharesPerHour) {
      throw ShareException(
        code: 'RATE_LIMITED',
        message: 'Too many shares from this account right now.',
      );
    }

    // Retries on the unlikely collision of a live code.
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      final existing = await SharedItem.db.findFirstRow(
        session,
        where: (t) => t.code.equals(code),
      );
      if (existing != null) continue;

      return SharedItem.db.insertRow(
        session,
        SharedItem(
          code: code,
          kind: kind,
          payload: payload,
          createdBy: userId,
        ),
      );
    }
    throw ShareException(
      code: 'CODE_EXHAUSTED',
      message: 'Could not allocate a share code, try again.',
    );
  }

  /// Resolves a share code to the item it carries, or null when unknown.
  Future<SharedItem?> resolveShare(Session session, String code) async {
    final normalised = code.trim().toUpperCase();
    if (normalised.length != 6) return null;
    return SharedItem.db.findFirstRow(
      session,
      where: (t) => t.code.equals(normalised),
    );
  }

  String _generateCode() => List.generate(
    6,
    (_) => _alphabet[_random.nextInt(_alphabet.length)],
  ).join();
}
