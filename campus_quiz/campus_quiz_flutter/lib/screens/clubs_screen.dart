import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/campus_repository.dart';
import '../data/campus_seed.dart';
import '../navigation.dart';
import '../theme/brand.dart';
import '../widgets/glass.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_page_backdrop.dart';

/// The societies desk: who is running what, when they meet, and whether you
/// are in.
///
/// Joining is one tap and lives on the device, so the list stays honest
/// across reloads even when the campus server is down.
class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final CampusRepository _repo = CampusRepository();

  List<CampusClub> _clubs = const [];
  bool _loaded = false;
  String _category = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final clubs = await _repo.clubs();
    if (!mounted) return;
    setState(() {
      _clubs = clubs;
      _loaded = true;
    });
  }

  Future<void> _toggleMembership(CampusClub club) async {
    setState(() {
      _clubs = [
        for (final row in _clubs)
          if (row.id == club.id)
            row.copyWith(
              joined: !row.joined,
              members: row.joined ? row.members - 1 : row.members + 1,
            )
          else
            row,
      ];
    });
    await _repo.setClubMembership(club.id, !club.joined);
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
                        clubs: _clubs,
                        loaded: _loaded,
                        category: _category,
                        query: _query,
                        onCategory: (c) => setState(() => _category = c),
                        onQuery: (q) => setState(() => _query = q),
                        onToggle: _toggleMembership,
                        columns: wide ? 2 : 1,
                      );
                      if (wide) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1080),
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
    required this.clubs,
    required this.loaded,
    required this.category,
    required this.query,
    required this.onCategory,
    required this.onQuery,
    required this.onToggle,
    required this.columns,
  });

  final List<CampusClub> clubs;
  final bool loaded;
  final String category;
  final String query;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onQuery;
  final ValueChanged<CampusClub> onToggle;
  final int columns;

  static const List<String> _categories = [
    'All',
    'Technology',
    'Academic',
    'Cultural',
    'Sports',
    'Community',
  ];

  @override
  Widget build(BuildContext context) {
    final needle = query.trim().toLowerCase();
    final visible = clubs.where((club) {
      if (category != 'All' && club.category != category) return false;
      if (needle.isEmpty) return true;
      return club.name.toLowerCase().contains(needle) ||
          club.blurb.toLowerCase().contains(needle) ||
          club.category.toLowerCase().contains(needle);
    }).toList();

    final joined = clubs.where((c) => c.joined).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 40),
      children: [
        Text(
          'CLUBS',
          style: AppType.inter(
            11,
            weight: 600,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Societies worth your Wednesday.',
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
              ? '${clubs.length} societies · you are in $joined'
              : 'Loading the societies…',
          style: AppType.inter(
            13.5,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        _SearchField(onChanged: onQuery),
        const SizedBox(height: 14),
        _CategoryRow(
          categories: _categories,
          selected: category,
          onSelected: onCategory,
        ),
        const SizedBox(height: 20),
        if (!loaded)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Loading the societies…',
                style: AppType.inter(
                  13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          )
        else if (visible.isEmpty)
          _Empty(query: query)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = columns == 2
                  ? (constraints.maxWidth - 14) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (var i = 0; i < visible.length; i++)
                    SizedBox(
                      width: width,
                      child: _ClubCard(
                        club: visible[i],
                        onToggle: () => onToggle(visible[i]),
                        delay: 60 + i * 45,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 17,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: AppType.inter(
                13.5,
                color: Colors.white,
              ),
              cursorColor: Brand.emberLight,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search societies',
                hintStyle: AppType.inter(
                  13.5,
                  color: Colors.white.withValues(alpha: 0.42),
                ),
              ),
            ),
          ),
        ],
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

class _ClubCard extends StatelessWidget {
  const _ClubCard({
    required this.club,
    required this.onToggle,
    required this.delay,
  });

  final CampusClub club;
  final VoidCallback onToggle;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
          radius: 20,
          blur: 22,
          tint: Colors.white.withValues(alpha: 0.07),
          tintTop: Colors.white.withValues(alpha: 0.10),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(initials: club.initials, category: club.category),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: AppType.inter(
                            17,
                            weight: 600,
                            color: Colors.white,
                            letterSpacing: -0.25,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${club.category} · ${club.members} members',
                          style: AppType.inter(
                            12,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _JoinButton(joined: club.joined, onTap: onToggle),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                club.blurb,
                style: AppType.inter(
                  13.5,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    club.schedule,
                    style: AppType.inter(
                      12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.place_outlined,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      club.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.inter(
                        12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.initials, required this.category});

  final String initials;
  final String category;

  static const Map<String, Color> _colors = {
    'Technology': Color(0xFF8FD0B2),
    'Academic': Color(0xFF9DB8E8),
    'Cultural': Color(0xFFC9A2E8),
    'Sports': Color(0xFFE0B15C),
    'Community': Color(0xFFF0A9A0),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[category] ?? const Color(0xFFE8E8EA);

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Text(
        initials,
        style: AppType.inter(
          15,
          weight: 600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.joined, required this.onTap});

  final bool joined;
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
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: joined
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Brand.ember.withValues(alpha: 0.95),
                      Brand.ember.withValues(alpha: 0.72),
                    ],
                  )
                : null,
            color: joined ? null : Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: joined
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            joined ? 'Joined' : 'Join',
            style: AppType.inter(
              12.5,
              weight: 600,
              color: joined
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.query});

  final String query;

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
            Icons.groups_outlined,
            size: 28,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            query.isEmpty ? 'No societies here' : 'Nothing matched',
            style: AppType.inter(
              15,
              weight: 600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            query.isEmpty
                ? 'Try another category.'
                : 'No society matches "$query" in this category.',
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
