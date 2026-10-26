import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:campus_quiz_flutter/utils/event_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatEventTime', () {
    test('formats the start time when the event has no end time', () {
      expect(
        formatEventTime(DateTime(2026, 10, 27, 10), null),
        'Tue, 27 Oct · 10:00',
      );
    });

    test('adds the end time when the event ends the same day', () {
      expect(
        formatEventTime(DateTime(2026, 10, 27, 10), DateTime(2026, 10, 27, 18)),
        'Tue, 27 Oct · 10:00–18:00',
      );
    });

    test('puts the end date on its own line for a multi day event', () {
      expect(
        formatEventTime(
          DateTime(2026, 10, 27, 10),
          DateTime(2026, 10, 28, 16),
        ),
        'Tue, 27 Oct · 10:00\nWed, 28 Oct · 16:00',
      );
    });
  });

  group('categoryLabel', () {
    test('capitalizes the category name', () {
      expect(categoryLabel('tech'), 'Tech');
      expect(categoryLabel('cultural'), 'Cultural');
    });

    test('leaves an empty name alone', () {
      expect(categoryLabel(''), '');
    });
  });

  group('categoryFilterLabels', () {
    test('starts with All and lists every category', () {
      final labels = categoryFilterLabels;

      expect(labels.first, 'All');
      expect(
        labels.skip(1),
        EventCategory.values.map((category) => categoryLabel(category.name)),
      );
    });
  });

  group('rsvpStatusLabel', () {
    test('names both responses', () {
      expect(rsvpStatusLabel(RsvpStatus.going), 'Going');
      expect(rsvpStatusLabel(RsvpStatus.interested), 'Interested');
    });
  });
}
