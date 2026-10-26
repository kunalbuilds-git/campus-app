import 'package:campus_quiz_client/campus_quiz_client.dart';

import 'campus_seed.dart';

/// An action the guide offers with an answer, e.g. opening the student's
/// board.
class ChatAction {
  const ChatAction({required this.label, required this.route});

  final String label;
  final String route;
}

/// A reply from the campus guide: a line of copy, the events it points at,
/// and any follow-up actions it offers.
class ChatReply {
  const ChatReply({
    required this.text,
    required this.events,
    this.actions = const [],
  });

  final String text;
  final List<EventSummary> events;
  final List<ChatAction> actions;
}

/// Searches everything the app knows — the events feed, the societies, the
/// locations and the student's own board — and answers in plain language.
///
/// The matcher is deliberately small and predictable so the guide still works
/// with no network and no LLM keys. When an LLM is reachable the guide uses
/// its prose instead, but the event cards and actions shown under the answer
/// always come from this search.
class CampusAssistant {
  const CampusAssistant(this.feed, {this.profile = sampleProfile});

  final List<EventSummary> feed;
  final CampusProfile profile;

  ChatReply reply(String query) {
    final q = query.toLowerCase().trim();
    final now = DateTime.now();

    if (q.isEmpty) {
      return ChatReply(
        text:
            'Tell me a day, a place, a society or a subject and I will pull '
            'the matching events from the feed.',
        events: const [],
      );
    }

    final intent = _matchIntent(q, now);
    if (intent != null) return intent;

    final matches = searchEvents(query);
    if (matches.isEmpty) {
      return ChatReply(
        text:
            'Nothing on the feed matches "$query" yet. These are the next '
            'things happening on campus:',
        events: feed.take(3).toList(),
      );
    }

    final lead = matches.first.event;
    return ChatReply(
      text:
          '${matches.length} ${matches.length == 1 ? 'match' : 'matches'} '
          'on the feed. "${lead.title}" is the closest — ${lead.organizer}, '
          '${_when(lead.startsAt, now)}.',
      events: matches,
    );
  }

  /// Keyword search across titles, descriptions, societies, locations and
  /// categories. Used both for the fallback answers and to attach event
  /// cards to LLM answers.
  List<EventSummary> searchEvents(String query) {
    final tokens = query
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length > 2)
        .toList();

    final scored = <(EventSummary, int)>[];
    for (final summary in feed) {
      final event = summary.event;
      final haystack = [
        event.title,
        event.description,
        event.organizer,
        event.location,
        event.category.name,
      ].join(' ').toLowerCase();
      var score = 0;
      for (final token in tokens) {
        if (event.title.toLowerCase().contains(token)) score += 3;
        if (event.organizer.toLowerCase().contains(token)) score += 2;
        if (event.location.toLowerCase().contains(token)) score += 2;
        if (haystack.contains(token)) score += 1;
      }
      if (score > 0) scored.add((summary, score));
    }

    scored.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      if (byScore != 0) return byScore;
      return a.$1.event.startsAt.compareTo(b.$1.event.startsAt);
    });
    return scored.take(4).map((e) => e.$1).toList();
  }

  ChatReply? _matchIntent(String q, DateTime now) {
    // --- The student's own board -------------------------------------------
    if (q.contains('my ') ||
        q.contains('rsvp') ||
        q.contains('board') ||
        q.contains('profile') ||
        q.contains('am i going') ||
        q.contains('how many')) {
      final mine = profile.going + profile.interested;
      return ChatReply(
        text:
            'You are on the board for $mine events this term — '
            '${profile.going} going and ${profile.interested} saved, across '
            '${profile.clubs} societies. ${profile.term} is looking busy.',
        events: const [],
        actions: const [ChatAction(label: 'Open my board', route: '/profile')],
      );
    }

    // --- Societies ----------------------------------------------------------
    if (q.contains('societ') || q.contains('club')) {
      final byOrganizer = <String, int>{};
      for (final summary in feed) {
        byOrganizer[summary.event.organizer] =
            (byOrganizer[summary.event.organizer] ?? 0) + 1;
      }
      final societies = byOrganizer.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final names = societies.take(3).map((e) => e.key).join(', ');
      return ChatReply(
        text:
            '${societies.length} societies are running events right now — '
            'the busiest are $names. Which one catches your eye?',
        events: feed.take(3).toList(),
      );
    }

    // --- Capacity -----------------------------------------------------------
    if (q.contains('seat') ||
        q.contains('full') ||
        q.contains('sold out') ||
        q.contains('space') ||
        q.contains('room')) {
      final withSeats =
          feed
              .where(
                (s) =>
                    s.event.capacity != null &&
                    s.event.capacity! - s.goingCount > 0,
              )
              .toList()
            ..sort(
              (a, b) => (b.event.capacity! - b.goingCount).compareTo(
                a.event.capacity! - a.goingCount,
              ),
            );
      if (withSeats.isEmpty) {
        return const ChatReply(
          text:
              'Everything with a cap is full right now. New events usually '
              'land early in the week.',
          events: [],
        );
      }
      final first = withSeats.first.event;
      return ChatReply(
        text:
            '${withSeats.length} events still have room. "${first.title}" '
            'is the widest open — ${first.capacity! - withSeats.first.goingCount} '
            'of ${first.capacity} seats left.',
        events: withSeats.take(3).toList(),
      );
    }

    // --- Weekend ------------------------------------------------------------
    if (q.contains('weekend') ||
        q.contains('saturday') ||
        q.contains('sunday')) {
      final weekend = feed.where((s) {
        final day = s.event.startsAt.weekday;
        return day == DateTime.saturday || day == DateTime.sunday;
      }).toList();
      if (weekend.isEmpty) {
        return const ChatReply(
          text:
              'The weekend board is empty at the moment — weekdays carry '
              'the term.',
          events: [],
        );
      }
      return ChatReply(
        text:
            '${weekend.length} things on this weekend. '
            '"${weekend.first.event.title}" opens the list.',
        events: weekend.take(3).toList(),
      );
    }

    // --- Tonight ------------------------------------------------------------
    if (q.contains('tonight')) {
      final tonight = _afterHours(now, 16);
      if (tonight.isEmpty) {
        return const ChatReply(
          text:
              'Nothing starts after four tonight. The feed is quiet this '
              'evening — try tomorrow instead.',
          events: [],
        );
      }
      return ChatReply(
        text:
            'Starting tonight: ${tonight.length} '
            '${tonight.length == 1 ? 'event' : 'events'}. '
            '${tonight.first.event.title} kicks off at '
            '${_clock(tonight.first.event.startsAt)}.',
        events: tonight.take(3).toList(),
      );
    }

    // --- Tomorrow -----------------------------------------------------------
    if (q.contains('tomorrow')) {
      final tomorrow = feed.where((s) {
        final diff = s.event.startsAt.difference(now);
        return !diff.isNegative &&
            diff.inHours < 48 &&
            !_isToday(s.event.startsAt, now);
      }).toList();
      if (tomorrow.isEmpty) {
        return const ChatReply(
          text: 'The feed is empty for tomorrow right now.',
          events: [],
        );
      }
      return ChatReply(
        text:
            'Tomorrow: ${tomorrow.length} '
            '${tomorrow.length == 1 ? 'event' : 'events'} on the board.',
        events: tomorrow.take(3).toList(),
      );
    }

    // --- Free food ----------------------------------------------------------
    if (q.contains('free') && (q.contains('food') || q.contains('eat'))) {
      final food = feed
          .where((s) => s.event.description.toLowerCase().contains('food'))
          .toList();
      if (food.isEmpty) {
        return const ChatReply(
          text:
              'No events mention food at the moment. The cultural societies '
              'usually sort that out within the week.',
          events: [],
        );
      }
      return ChatReply(
        text:
            '${food.length} '
            '${food.length == 1 ? 'event has' : 'events have'} food. '
            '${food.first.event.title} at ${food.first.event.location} is the '
            'one to plan around.',
        events: food.take(3).toList(),
      );
    }

    // --- Subject clusters ---------------------------------------------------
    if (q.contains('study') ||
        q.contains('exam') ||
        q.contains('lecture') ||
        q.contains('seminar')) {
      return _byCategory(
        const [EventCategory.academic, EventCategory.workshop],
        'For studying',
        'academic session',
        'academic sessions',
      );
    }
    if (q.contains('sport') || q.contains('match') || q.contains('football')) {
      return _byCategory(
        const [EventCategory.sports],
        'Sporting fixtures on the board',
        'fixture',
        'fixtures',
      );
    }
    if (q.contains('code') ||
        q.contains('hack') ||
        q.contains('build') ||
        q.contains('tech')) {
      return _byCategory(
        const [EventCategory.tech],
        'Tech events',
        'event',
        'events',
      );
    }
    if (q.contains('music') ||
        q.contains('mic') ||
        q.contains('cultural') ||
        q.contains('dance')) {
      return _byCategory(
        const [EventCategory.cultural],
        'Cultural events',
        'event',
        'events',
      );
    }

    // --- Locations ----------------------------------------------------------
    final tokens = q.split(RegExp(r'[^a-z0-9]+')).where((t) => t.length > 2);
    final placeHits = feed
        .where(
          (s) => tokens.any((t) => s.event.location.toLowerCase().contains(t)),
        )
        .take(3)
        .toList();
    if (placeHits.isNotEmpty) {
      return ChatReply(
        text:
            'On at ${placeHits.first.event.location}: '
            '"${placeHits.first.event.title}", '
            '${_when(placeHits.first.event.startsAt, now)}.',
        events: placeHits,
      );
    }

    // --- Help ---------------------------------------------------------------
    if (q.contains('what can you') || q.contains('help')) {
      return const ChatReply(
        text:
            "I can search the whole app: tonight's events, free food, "
            'sporting fixtures, societies, seats still open, and everything '
            'on your own board. Try "what\'s on tonight" or "any seats left?".',
        events: [],
      );
    }

    return null;
  }

  ChatReply _byCategory(
    List<EventCategory> categories,
    String prefix,
    String singular,
    String plural,
  ) {
    final matches = feed
        .where((s) => categories.contains(s.event.category))
        .toList();
    if (matches.isEmpty) {
      return ChatReply(
        text: '$prefix: nothing on the feed at the moment.',
        events: const [],
      );
    }
    return ChatReply(
      text:
          '$prefix: ${matches.length} '
          '${matches.length == 1 ? singular : plural}. '
          '${matches.first.event.title} is the next one.',
      events: matches.take(3).toList(),
    );
  }

  List<EventSummary> _afterHours(DateTime now, int hour) {
    return feed.where((s) {
      final start = s.event.startsAt;
      final sameDay = _isToday(start, now);
      return sameDay && start.hour >= hour;
    }).toList();
  }

  static bool _isToday(DateTime date, DateTime now) =>
      date.year == now.year && date.month == now.month && date.day == now.day;

  static String _when(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final days = target.difference(today).inDays;
    if (days == 0) return 'today at ${_clock(date)}';
    if (days == 1) return 'tomorrow at ${_clock(date)}';
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[date.weekday - 1]} at ${_clock(date)}';
  }

  static String _clock(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'am' : 'pm'}';
  }

  /// A time-aware opening line for the empty chat state.
  String greeting() {
    final now = DateTime.now();
    final partOfDay = now.hour < 12
        ? 'Morning'
        : now.hour < 17
        ? 'Afternoon'
        : 'Evening';
    final tonight = _afterHours(now, 16);
    if (tonight.isNotEmpty) {
      return '$partOfDay. ${tonight.length} '
          '${tonight.length == 1 ? 'thing is' : 'things are'} on tonight, '
          'starting with ${tonight.first.event.title}.';
    }
    if (feed.isNotEmpty) {
      return '$partOfDay. The next thing on campus is '
          '${feed.first.event.title}, ${_when(feed.first.event.startsAt, now)}.';
    }
    return '$partOfDay. The campus feed is quiet — ask me anything anyway.';
  }

  /// The compact digest handed to the LLM as its system context: the whole
  /// feed, the societies and the student's board, so its answers stay inside
  /// the app's reality.
  String systemContext() {
    final buffer = StringBuffer()
      ..writeln(
        'You are the campus guide inside CampHere, a campus events app. '
        'You search the whole app for the student.',
      )
      ..writeln(
        'Answer ONLY from the data below. If something is not in the data, '
        'say so plainly. Keep answers under 60 words, warm and concrete, no '
        'emojis. Refer to events by their exact titles.',
      )
      ..writeln()
      ..writeln(
        'STUDENT: ${profile.name} — ${profile.going} going, '
        '${profile.interested} saved, ${profile.clubs} societies this term.',
      )
      ..writeln()
      ..writeln('EVENT FEED (soonest first):');
    for (final summary in feed) {
      final event = summary.event;
      final cap = event.capacity == null
          ? 'no cap'
          : '${event.capacity! - summary.goingCount} of ${event.capacity} '
                'seats left';
      buffer.writeln(
        '- "${event.title}" [${event.category.name}] at ${event.location}, '
        'by ${event.organizer}, ${formatEventWhen(event)}, '
        '${summary.goingCount} going / ${summary.interestedCount} interested, '
        '$cap.',
      );
    }
    return buffer.toString();
  }
}

/// Human labels for the protocol enums.
extension EventCategoryLabel on EventCategory {
  String get label => switch (this) {
    EventCategory.sports => 'Sports',
    EventCategory.cultural => 'Cultural',
    EventCategory.academic => 'Academic',
    EventCategory.tech => 'Tech',
    EventCategory.workshop => 'Workshop',
    EventCategory.community => 'Community',
    EventCategory.other => 'Other',
  };
}

/// Formats an event time the way the feed cards show it.
String formatEventWhen(Event event, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final target = DateTime(
    event.startsAt.year,
    event.startsAt.month,
    event.startsAt.day,
  );
  final days = target.difference(today).inDays;
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final time = event.startsAt;
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final clock = '$hour:$minute ${time.hour < 12 ? 'am' : 'pm'}';

  if (days == 0) return 'Today, $clock';
  if (days == 1) return 'Tomorrow, $clock';
  if (days < 7) return '${weekdays[event.startsAt.weekday - 1]}, $clock';
  return '${event.startsAt.day} ${_month(event.startsAt.month)}, $clock';
}

String _month(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];
