import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/campus_repository.dart';
import '../navigation.dart';
import '../theme/brand.dart';
import '../widgets/glass.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_page_backdrop.dart';

/// The events desk: what is on, where, and whether there is still a seat.
///
/// It reads like a ticketing site rather than a feed — pick a day, filter by
/// kind, then claim a seat. RSVPs go to the backend when it is reachable and
/// are kept on the device when it is not, so the seat is never silently lost.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final CampusRepository _repo = CampusRepository();

  List<EventSummary> _events = const [];
  bool _loaded = false;
  int _dayIndex = 0;
  String _category = 'All';
  final Set<UuidValue> _going = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await _repo.feed();
    if (!mounted) return;
    setState(() {
      _events = events;
      _loaded = true;
      // Open on the first day that actually has something on, today
      // included — the way a ticketing site opens on the next show.
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      var opened = false;
      for (var day = 0; day < 7 && !opened; day++) {
        final from = startOfToday
            .add(Duration(days: day))
            .subtract(const Duration(seconds: 1));
        final to = startOfToday.add(Duration(days: day + 1));
        final any = events.any(
          (e) =>
              e.event.startsAt.isAfter(from) && e.event.startsAt.isBefore(to),
        );
        if (any) {
          _dayIndex = day;
          opened = true;
        }
      }
    });
  }

  /// How many events land on each of the next seven days.
  ///
  /// The strip carries these counts so a student can see where the busy
  /// days are before choosing one, instead of picking a day and finding
  /// it empty.
  List<int> get _dayCounts {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return [
      for (var day = 0; day < 7; day++)
        _events.where((summary) {
          final at = summary.event.startsAt;
          final from = start
              .add(Duration(days: day))
              .subtract(const Duration(seconds: 1));
          final to = start.add(Duration(days: day + 1));
          return at.isAfter(from) && at.isBefore(to);
        }).length,
    ];
  }

  /// The closest day that has something on, searching forward first and
  /// then backward, so an empty day can offer a way out.
  int? _nearestBusyDay(int from) {
    for (var step = 1; step < 7; step++) {
      final forward = from + step;
      if (forward < 7 && _dayCounts[forward] > 0) return forward;
      final backward = from - step;
      if (backward >= 0 && _dayCounts[backward] > 0) return backward;
    }
    return null;
  }

  static const List<String> _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _dayLabel(int index) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day).add(
      Duration(days: index),
    );
    return '${_weekdayNames[date.weekday - 1]} ${date.day}';
  }

  List<EventSummary> get _visible {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final day = startOfToday.add(Duration(days: _dayIndex));
    final next = startOfToday.add(Duration(days: _dayIndex + 1));

    return _events.where((summary) {
      final at = summary.event.startsAt;
      final sameDay =
          at.isAfter(day.subtract(const Duration(seconds: 1))) &&
          at.isBefore(next);
      if (!sameDay) return false;
      if (_category == 'All') return true;
      return summary.event.category.name.toLowerCase() ==
          _category.toLowerCase();
    }).toList();
  }

  Future<void> _toggleRsvp(EventSummary summary) async {
    final id = summary.event.id;
    if (id == null) return;
    final joining = !_going.contains(id);
    setState(() {
      if (joining) {
        _going.add(id);
      } else {
        _going.remove(id);
      }
    });
    await _repo.setRsvp(id, joining ? RsvpStatus.going : RsvpStatus.interested);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFF04121B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GlassPageBackdrop(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GlassNavBar(
                    dark: true,
                    brand: 'CampHere',
                    links: campLinks,
                    linkRoutes: campRoutes,
                    trailing: _HeaderCta(
                      label: "Ask what's on",
                      onTap: () => Navigator.of(context).pushNamed('/chat'),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 900;
                      final content = _Content(
                        events: _visible,
                        allEvents: _events,
                        loaded: _loaded,
                        now: now,
                        dayIndex: _dayIndex,
                        category: _category,
                        going: _going,
                        counts: _dayCounts,
                        dayLabel: _dayLabel,
                        nearestBusyDay: _nearestBusyDay,
                        onDay: (i) => setState(() => _dayIndex = i),
                        onCategory: (c) => setState(() => _category = c),
                        onRsvp: _toggleRsvp,
                        columns: wide ? 2 : 1,
                      );
                      if (wide) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: content,
                          ),
                        );
                      }
                      return content;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.events,
    required this.allEvents,
    required this.loaded,
    required this.now,
    required this.dayIndex,
    required this.category,
    required this.going,
    required this.counts,
    required this.dayLabel,
    required this.nearestBusyDay,
    required this.onDay,
    required this.onCategory,
    required this.onRsvp,
    required this.columns,
  });

  final List<EventSummary> events;
  final List<EventSummary> allEvents;
  final bool loaded;
  final DateTime now;
  final int dayIndex;
  final String category;
  final Set<UuidValue> going;
  final List<int> counts;
  final String Function(int) dayLabel;
  final int? Function(int) nearestBusyDay;
  final ValueChanged<int> onDay;
  final ValueChanged<String> onCategory;
  final ValueChanged<EventSummary> onRsvp;
  final int columns;

  static const List<String> _categories = [
    'All',
    'Academic',
    'Tech',
    'Sports',
    'Cultural',
    'Workshop',
    'Community',
  ];

  @override
  Widget build(BuildContext context) {
    final seats = events.fold<int>(0, (sum, e) => sum + e.goingCount);
    final busyDay = nearestBusyDay(dayIndex);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 40),
      children: [
        Text(
          'EVENTS',
          style: AppType.inter(
            11,
            weight: 600,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Everything happening on campus.',
          style: AppType.inter(
            27,
            weight: 600,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loaded
              ? '${allEvents.length} events listed · $seats seats claimed on this day'
              : 'Loading the calendar…',
          style: AppType.inter(
            13.5,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 22),
        _DayStrip(
          now: now,
          selected: dayIndex,
          counts: counts,
          onDay: onDay,
        ),
        const SizedBox(height: 16),
        _CategoryRow(
          categories: _categories,
          selected: category,
          onSelected: onCategory,
        ),
        const SizedBox(height: 22),
        if (!loaded)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Loading the calendar…',
                style: AppType.inter(
                  13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          )
        else if (events.isEmpty)
          _EmptyDay(
            dayIndex: dayIndex,
            busyDay: busyDay,
            busyLabel: busyDay == null ? null : dayLabel(busyDay),
            busyCount: busyDay == null ? 0 : counts[busyDay],
            onJump: busyDay == null ? null : () => onDay(busyDay),
          )
        else
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _EventCard(
              summary: events[i],
              going: going.contains(events[i].event.id),
              onRsvp: () => onRsvp(events[i]),
              delay: 70 + i * 50,
            ),
          ],
      ],
    );
  }
}

/// The day picker: seven days starting today, the way a ticketing site
/// opens on the next show. Each chip carries the number of events on that
/// day, so the busiest days are visible before one is chosen.
class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.now,
    required this.selected,
    required this.counts,
    required this.onDay,
  });

  final DateTime now;
  final int selected;
  final List<int> counts;
  final ValueChanged<int> onDay;

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime(now.year, now.month, now.day);

    return SizedBox(
      height: 78,
      child: Row(
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _DayChip(
                weekday: i == 0
                    ? 'Today'
                    : _weekdays[today.add(Duration(days: i)).weekday - 1],
                date: today.add(Duration(days: i)),
                selected: selected == i,
                count: i < counts.length ? counts[i] : 0,
                onTap: () => onDay(i),
                delay: 40 + i * 35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.weekday,
    required this.date,
    required this.selected,
    required this.count,
    required this.onTap,
    required this.delay,
  });

  final String weekday;
  final DateTime date;
  final bool selected;
  final int count;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Brand.easeSoft,
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Brand.ember.withValues(alpha: 0.95),
                          Brand.ember.withValues(alpha: 0.72),
                        ],
                      )
                    : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.07),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 5,
                    right: 5,
                    child: _CountBadge(count: count, selected: selected),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekday,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.inter(
                            11.5,
                            weight: 500,
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: AppType.inter(
                            19,
                            weight: 600,
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.92),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.12,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// The number of events on a day, as a small pip in the corner of the chip.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.92)
            : Brand.ember.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: AppType.inter(
          9.5,
          weight: 700,
          color: selected ? Brand.ember : Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final category = categories[i];
          final active = category == selected;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(category),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: active
                      ? Colors.white.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  category,
                  style: AppType.inter(
                    12.5,
                    weight: 500,
                    color: active
                        ? Brand.ink
                        : Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One event, laid out like a show card: date block, the details, and the
/// seat button on the right.
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.summary,
    required this.going,
    required this.onRsvp,
    required this.delay,
  });

  final EventSummary summary;
  final bool going;
  final VoidCallback onRsvp;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final event = summary.event;
    final capacity = event.capacity;
    final seatsLeft = capacity == null ? null : capacity - summary.goingCount;
    final almostFull = seatsLeft != null && seatsLeft <= 12;

    return GlassSurface(
          radius: 20,
          blur: 22,
          tint: Colors.white.withValues(alpha: 0.07),
          tintTop: Colors.white.withValues(alpha: 0.10),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateBlock(startsAt: event.startsAt),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CategoryChip(category: event.category),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.organizer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.inter(
                              12,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: AppType.inter(
                        17,
                        weight: 600,
                        color: Colors.white,
                        letterSpacing: -0.25,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${_time(event.startsAt)} · ${event.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.inter(
                        13,
                        color: Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _GoingPip(count: summary.goingCount),
                        if (seatsLeft != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            almostFull
                                ? '$seatsLeft seats left'
                                : '${summary.goingCount} of $capacity seats taken',
                            style: AppType.inter(
                              12,
                              color: almostFull
                                  ? Brand.emberLight
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _SeatButton(going: going, onTap: onRsvp),
            ],
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 340.ms,
          curve: Curves.easeOutCubic,
        );
  }

  static String _time(DateTime at) {
    final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final minute = at.minute.toString().padLeft(2, '0');
    final meridiem = at.hour < 12 ? 'am' : 'pm';
    return '$hour:$minute $meridiem';
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.startsAt});

  final DateTime startsAt;

  static const List<String> _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Text(
            _months[startsAt.month - 1],
            style: AppType.inter(
              10,
              weight: 600,
              color: Brand.emberLight,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${startsAt.day}',
            style: AppType.inter(
              22,
              weight: 600,
              color: Colors.white,
              letterSpacing: -0.4,
              height: 1.05,
            ),
          ),
          Text(
            _time(startsAt),
            style: AppType.inter(
              9.5,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  static String _time(DateTime at) {
    final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final minute = at.minute == 0
        ? ''
        : ':${at.minute.toString().padLeft(2, '0')}';
    final meridiem = at.hour < 12 ? 'am' : 'pm';
    return '$hour$minute$meridiem';
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      EventCategory.academic => const Color(0xFF9DB8E8),
      EventCategory.tech => const Color(0xFF8FD0B2),
      EventCategory.sports => const Color(0xFFE0B15C),
      EventCategory.cultural => const Color(0xFFC9A2E8),
      EventCategory.workshop => const Color(0xFF9FD6E8),
      EventCategory.community => const Color(0xFFF0A9A0),
      _ => const Color(0xFFE8E8EA),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        category.name,
        style: AppType.inter(
          10.5,
          weight: 500,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _GoingPip extends StatelessWidget {
  const _GoingPip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 18,
            height: 18,
            margin: EdgeInsets.only(right: i == 2 ? 7 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
          ),
        Text(
          '$count going',
          style: AppType.inter(
            12,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}

class _SeatButton extends StatelessWidget {
  const _SeatButton({required this.going, required this.onTap});

  final bool going;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Brand.easeSoft,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: going
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Brand.ember.withValues(alpha: 0.95),
                      Brand.ember.withValues(alpha: 0.72),
                    ],
                  )
                : null,
            color: going ? null : Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: going
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                going ? Icons.check_rounded : Icons.add_rounded,
                size: 14,
                color: going
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 5),
              Text(
                going ? 'Going' : 'RSVP',
                style: AppType.inter(
                  12.5,
                  weight: 600,
                  color: going
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({
    required this.dayIndex,
    required this.busyDay,
    required this.busyLabel,
    required this.busyCount,
    required this.onJump,
  });

  final int dayIndex;
  final int? busyDay;
  final String? busyLabel;
  final int busyCount;
  final VoidCallback? onJump;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 28,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            dayIndex == 0
                ? 'Nothing on today'
                : 'Nothing scheduled on this day',
            style: AppType.inter(
              15,
              weight: 600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick another day, or clear the filter to see the whole week.',
            textAlign: TextAlign.center,
            style: AppType.inter(
              13,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          if (onJump != null && busyLabel != null) ...[
            const SizedBox(height: 18),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onJump,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    'See $busyCount on $busyLabel',
                    style: AppType.inter(
                      12.5,
                      weight: 500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderCta extends StatelessWidget {
  const _HeaderCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Brand.ember,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppType.inter(13.5, weight: 500, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
