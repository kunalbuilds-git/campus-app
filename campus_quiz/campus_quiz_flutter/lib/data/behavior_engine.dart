import 'dart:convert';
import 'dart:math' as math;

import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../security/vault.dart';

/// The personalisation engine behind the "For you" widgets.
///
/// It is a small on-device behavioural model, not a cloud service: every
/// section open, card tap and guide search is recorded with a timestamp and
/// folded into three signals —
///
/// * **section frequency** — which surfaces the student actually uses,
/// * **category affinity** — exponentially decayed interest per event
///   category, so last week's obsession outweighs last month's,
/// * **hour histogram** — when during the day the student checks in.
///
/// The signals drive the For-you widgets: the evening line on the guide, the
/// "tonight's picks" card on the board, and the suggested chips.
class BehaviorEngine {
  BehaviorEngine._();

  static final BehaviorEngine instance = BehaviorEngine._();

  static const _storageKey = 'camphere.behavior.v1';
  static const _halfLifeHours = 96.0;

  bool _loaded = false;
  final List<_Signal> _signals = [];

  /// What the student did, when. [kind] is `section`, `event` or `search`;
  /// [key] is the section name, event category or raw query.
  void record(String kind, String key, {DateTime? at}) {
    _ensureLoaded();
    _signals.add(_Signal(kind: kind, key: key, at: (at ?? DateTime.now())));
    if (_signals.length > 500) _signals.removeRange(0, _signals.length - 500);
    _persist();
  }

  /// Sections ranked by how often the student opens them.
  List<String> topSections({int take = 3}) {
    _ensureLoaded();
    final counts = <String, double>{};
    for (final signal in _signals) {
      if (signal.kind != 'section') continue;
      counts[signal.key] = (counts[signal.key] ?? 0) + _decay(signal.at);
    }
    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(take).map((e) => e.key).toList();
  }

  /// Event categories ranked by decayed engagement.
  Map<String, double> categoryAffinity() {
    _ensureLoaded();
    final affinity = <String, double>{};
    for (final signal in _signals) {
      if (signal.kind != 'event' && signal.kind != 'search') continue;
      for (final category in EventCategory.values) {
        final name = category.name;
        if (signal.key.toLowerCase().contains(name)) {
          affinity[name] = (affinity[name] ?? 0) + _decay(signal.at);
        }
      }
      if (signal.kind == 'event') {
        affinity[signal.key] = (affinity[signal.key] ?? 0) + _decay(signal.at);
      }
    }
    return affinity;
  }

  /// The hour of day the student checks in most, if a pattern exists.
  int? peakHour() {
    _ensureLoaded();
    final byHour = List<double>.filled(24, 0);
    for (final signal in _signals) {
      byHour[signal.at.hour] += _decay(signal.at);
    }
    final peak = byHour.indexWhere((w) => w > 0);
    if (peak < 0) return null;
    var best = peak;
    for (var h = 0; h < 24; h++) {
      if (byHour[h] > byHour[best]) best = h;
    }
    return best;
  }

  /// Feed entries reordered by the student's affinity.
  List<EventSummary> personalizeFeed(List<EventSummary> feed, {int take = 3}) {
    final affinity = categoryAffinity();
    if (affinity.isEmpty) return feed.take(take).toList();
    final ranked = [...feed]
      ..sort((a, b) {
        final scoreA = affinity[a.event.category.name] ?? 0;
        final scoreB = affinity[b.event.category.name] ?? 0;
        if ((scoreA - scoreB).abs() > 0.01) return scoreB.compareTo(scoreA);
        return a.event.startsAt.compareTo(b.event.startsAt);
      });
    return ranked.take(take).toList();
  }

  /// A one-line insight for the guide's opening state.
  String? insight() {
    final sections = topSections(take: 1);
    final hour = peakHour();
    if (sections.isEmpty) return null;
    final section = sections.first;
    if (hour == null) return 'You open $section most often.';
    final human = hour == 0
        ? 'midnight'
        : hour < 12
        ? '$hour am'
        : hour == 12
        ? 'noon'
        : '${hour - 12} pm';
    return 'You open $section most around $human.';
  }

  double _decay(DateTime at) {
    final hours = DateTime.now().difference(at).inHours;
    final exponent = -hours / _halfLifeHours;
    if (exponent.isNaN) return 0;
    return math.pow(0.5, exponent).toDouble();
  }

  void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    try {
      // Synchronous best-effort read is not available on the shared
      // preferences API, so persistence loads asynchronously and the first
      // reads may run on an empty store — acceptable for a live session.
      _loadAsync();
    } catch (_) {}
  }

  Future<void> _loadAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final envelope = await Vault.decryptJson(raw);
      if (envelope == null) {
        // Sealed with a different key (or tampered) — start fresh rather
        // than trusting it.
        await prefs.remove(_storageKey);
        return;
      }
      final list = envelope as List<dynamic>;
      _signals
        ..clear()
        ..addAll([
          for (final entry in list)
            _Signal(
              kind: entry['k'] as String? ?? 'section',
              key: entry['v'] as String? ?? '',
              at:
                  DateTime.tryParse(entry['t'] as String? ?? '') ??
                  DateTime.now(),
            ),
        ]);
    } catch (_) {
      if (kDebugMode) debugPrint('behavior: store unreadable, starting fresh');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode([
          for (final signal in _signals)
            {
              'k': signal.kind,
              'v': signal.key,
              't': signal.at.toIso8601String(),
            },
        ]),
      );
    } catch (_) {}
  }
}

class _Signal {
  const _Signal({required this.kind, required this.key, required this.at});

  final String kind;
  final String key;
  final DateTime at;
}
