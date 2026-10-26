import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/campus_repository.dart';
import '../data/campus_seed.dart';
import '../navigation.dart';
import '../theme/brand.dart';
import '../widgets/glass.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_page_backdrop.dart';

/// The assignment desk: what is owed, by which course, and how late it is.
///
/// Work is grouped by urgency rather than by course, because the question a
/// student opens this screen with is "what do I have to do next".
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final CampusRepository _repo = CampusRepository();

  List<CampusAssignment> _items = const [];
  bool _loaded = false;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.assignments();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loaded = true;
    });
  }

  Future<void> _toggleSubmitted(CampusAssignment item) async {
    setState(() {
      _items = [
        for (final row in _items)
          if (row.id == item.id)
            row.copyWith(submitted: !row.submitted)
          else
            row,
      ];
    });
    await _repo.setAssignmentSubmitted(item.id, !item.submitted);
  }

  @override
  Widget build(BuildContext context) {
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
                        items: _items,
                        loaded: _loaded,
                        filter: _filter,
                        onFilter: (f) => setState(() => _filter = f),
                        onToggle: _toggleSubmitted,
                      );
                      if (wide) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
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
    required this.items,
    required this.loaded,
    required this.filter,
    required this.onFilter,
    required this.onToggle,
  });

  final List<CampusAssignment> items;
  final bool loaded;
  final String filter;
  final ValueChanged<String> onFilter;
  final ValueChanged<CampusAssignment> onToggle;

  static const List<String> _filters = [
    'All',
    'Due today',
    'This week',
    'Submitted',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final endOfWeek = endOfToday.add(const Duration(days: 7));

    final filtered = items.where((item) {
      switch (filter) {
        case 'Due today':
          return !item.submitted && item.due.isBefore(endOfToday);
        case 'This week':
          return !item.submitted &&
              item.due.isBefore(endOfWeek) &&
              !item.due.isBefore(now);
        case 'Submitted':
          return item.submitted;
        default:
          return true;
      }
    }).toList();

    final groups = <String, List<CampusAssignment>>{
      'Overdue': [],
      'Due today': [],
      'This week': [],
      'Later': [],
      'Handed in': [],
    };
    for (final item in filtered) {
      if (item.submitted) {
        groups['Handed in']!.add(item);
      } else if (item.due.isBefore(now)) {
        groups['Overdue']!.add(item);
      } else if (item.due.isBefore(endOfToday)) {
        groups['Due today']!.add(item);
      } else if (item.due.isBefore(endOfWeek)) {
        groups['This week']!.add(item);
      } else {
        groups['Later']!.add(item);
      }
    }

    final outstanding = items.where((i) => !i.submitted).length;
    final handedIn = items.where((i) => i.submitted).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 40),
      children: [
        Text(
          'ASSIGNMENTS',
          style: AppType.inter(
            11,
            weight: 600,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'What is owed, and by when.',
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
              ? '$outstanding still open · $handedIn handed in this term'
              : 'Loading your coursework…',
          style: AppType.inter(
            13.5,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 22),
        _FilterRow(
          filters: _filters,
          selected: filter,
          onSelected: onFilter,
        ),
        const SizedBox(height: 22),
        if (!loaded)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Loading your coursework…',
                style: AppType.inter(
                  13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          )
        else if (filtered.isEmpty)
          _Empty(filter: filter)
        else
          for (final entry in groups.entries) ...[
            if (entry.value.isNotEmpty) ...[
              if (entry.key != groups.keys.first) const SizedBox(height: 22),
              _GroupHeader(
                label: entry.key,
                count: entry.value.length,
                urgent: entry.key == 'Overdue',
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < entry.value.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _AssignmentCard(
                  item: entry.value[i],
                  onToggle: () => onToggle(entry.value[i]),
                  delay: 60 + i * 45,
                ),
              ],
            ],
          ],
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in filters)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(filter),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: filter == selected
                      ? Colors.white.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: filter == selected
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  filter,
                  style: AppType.inter(
                    12.5,
                    weight: 500,
                    color: filter == selected
                        ? Brand.ink
                        : Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.count,
    required this.urgent,
  });

  final String label;
  final int count;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppType.inter(
            10.5,
            weight: 600,
            color: urgent
                ? Brand.emberLight
                : Colors.white.withValues(alpha: 0.5),
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: urgent
                ? Brand.ember.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.08),
          ),
          child: Text(
            '$count',
            style: AppType.inter(
              10.5,
              weight: 600,
              color: urgent
                  ? Brand.emberLight
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.item,
    required this.onToggle,
    required this.delay,
  });

  final CampusAssignment item;
  final VoidCallback onToggle;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final overdue = item.isOverdue;
    final dueToday = _isDueToday(item.due);

    return GlassSurface(
          radius: 18,
          blur: 20,
          tint: Colors.white.withValues(alpha: 0.06),
          tintTop: Colors.white.withValues(alpha: 0.09),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Checkbox(done: item.submitted, onTap: onToggle),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.code,
                          style: AppType.inter(
                            11,
                            weight: 600,
                            color: Colors.white.withValues(alpha: 0.55),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.inter(
                              12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Text(
                          '${item.marks} marks',
                          style: AppType.inter(
                            11.5,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.title,
                      style: AppType.inter(
                        15.5,
                        weight: 600,
                        color: item.submitted
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.white,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.detail,
                      style: AppType.inter(
                        13,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          overdue
                              ? Icons.warning_amber_rounded
                              : Icons.schedule_rounded,
                          size: 13,
                          color: overdue
                              ? Brand.emberLight
                              : Colors.white.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.submitted
                              ? 'Handed in'
                              : overdue
                              ? 'Overdue — was due ${_when(item.due)}'
                              : dueToday
                              ? 'Due today, ${_clock(item.due)}'
                              : 'Due ${_when(item.due)}',
                          style: AppType.inter(
                            12,
                            weight: overdue && !item.submitted ? 500 : 400,
                            color: overdue && !item.submitted
                                ? Brand.emberLight
                                : Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.07,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }

  static bool _isDueToday(DateTime due) {
    final now = DateTime.now();
    return due.year == now.year && due.month == now.month && due.day == now.day;
  }

  static String _clock(DateTime due) {
    final hour = due.hour % 12 == 0 ? 12 : due.hour % 12;
    final minute = due.minute.toString().padLeft(2, '0');
    final meridiem = due.hour < 12 ? 'am' : 'pm';
    return '$hour:$minute $meridiem';
  }

  static String _when(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(due.year, due.month, due.day);
    final days = target.difference(today).inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    if (days < 7) return 'in $days days';
    return 'on ${due.day}/${due.month}';
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Brand.easeSoft,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: done
                ? Brand.ember.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: done
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.28),
            ),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.filter});

  final String filter;

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
            Icons.task_alt_rounded,
            size: 28,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            filter == 'Submitted' ? 'Nothing handed in yet' : 'All clear',
            style: AppType.inter(
              15,
              weight: 600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filter == 'Submitted'
                ? 'Tick an assignment off and it lands here.'
                : 'No coursework matches this filter right now.',
            textAlign: TextAlign.center,
            style: AppType.inter(
              13,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
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
