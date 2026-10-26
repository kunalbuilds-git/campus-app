import 'package:flutter_test/flutter_test.dart';

import 'package:campus_quiz_flutter/data/campus_seed.dart';

/// The events desk reads like a calendar, so the feed underneath it has to
/// look like one: every day of the coming week should have something on, and
/// nothing that already happened.
void main() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final feed = buildSampleFeed(now: now);

  int eventsOn(int day) {
    final from = start
        .add(Duration(days: day))
        .subtract(const Duration(seconds: 1));
    final to = start.add(Duration(days: day + 1));
    return feed.where((summary) {
      final at = summary.event.startsAt;
      return at.isAfter(from) && at.isBefore(to);
    }).length;
  }

  test('every day of the coming week has something on', () {
    for (var day = 1; day < 7; day++) {
      expect(
        eventsOn(day),
        greaterThan(0),
        reason: 'day $day of the strip would open on an empty page',
      );
    }
  });

  test('the feed is dense enough to read as a campus calendar', () {
    expect(feed.length, greaterThanOrEqualTo(16));
  });

  test('the feed never advertises something that already started', () {
    final past = feed
        .where((summary) => !summary.event.startsAt.isAfter(now))
        .map((summary) => summary.event.title)
        .toList();
    expect(past, isEmpty);
  });

  test('event identities are unique, so RSVP state cannot collide', () {
    final ids = feed.map((summary) => summary.event.id.toString()).toList();
    expect(ids.toSet().length, ids.length);
  });
}
