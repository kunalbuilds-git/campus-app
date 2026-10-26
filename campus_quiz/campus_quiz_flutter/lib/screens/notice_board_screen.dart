import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/behavior_engine.dart';
import '../data/campus_repository.dart';
import '../data/campus_seed.dart';
import '../navigation.dart';
import '../theme/brand.dart';
import '../widgets/glass.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_page_backdrop.dart';
import '../widgets/share_sheet.dart';

/// The campus digital notice board.
///
/// Everything the offices and societies publish, pinned items first, in the
/// same frosted-glass language as the rest of the app.
class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  List<CampusNotice> _notices = sampleNotices;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    BehaviorEngine.instance.record('section', 'notice board');
    _load();
  }

  Future<void> _load() async {
    final notices = await CampusRepository().notices();
    if (!mounted) return;
    setState(() {
      _notices = notices;
      _loaded = true;
    });
  }

  void _openShare(CampusNotice notice) {
    BehaviorEngine.instance.record('section', 'share notice');
    ShareSheet.showShare(
      context,
      kind: 'notice',
      title: notice.title,
      payload: jsonEncode({
        'title': notice.title,
        'body': notice.body,
        'category': notice.category,
        'office': notice.office,
        'date': notice.date,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notices = _notices;

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
                      final wide = constraints.maxWidth > 860;
                      final content = _Content(
                        notices: notices,
                        columns: wide ? 2 : 1,
                        loaded: _loaded,
                        onShare: _openShare,
                        onImport: () => ShareSheet.showImport(context),
                      );
                      if (wide) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
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
    required this.notices,
    required this.columns,
    required this.loaded,
    required this.onShare,
    required this.onImport,
  });

  final List<CampusNotice> notices;
  final int columns;
  final bool loaded;
  final ValueChanged<CampusNotice> onShare;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final pinnedCount = notices.where((n) => n.pinned).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notice board'.toUpperCase(),
            style: AppType.inter(
              11,
              weight: 500,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Everything the campus publishes.',
            style: AppType.tight(
              30,
              weight: 500,
              color: Colors.white,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                loaded
                    ? '${notices.length} notices · $pinnedCount pinned'
                    : 'Loading the board…',
                style: AppType.inter(
                  13.5,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onImport,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Use a code',
                          style: AppType.inter(
                            12.5,
                            weight: 500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < notices.length; i++)
            _NoticeCard(
              notice: notices[i],
              delay: 90 + i * 55,
              onShare: () => onShare(notices[i]),
            ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    required this.delay,
    required this.onShare,
  });

  final CampusNotice notice;
  final int delay;
  final VoidCallback onShare;

  Color get _categoryColor => switch (notice.category) {
    'Exams' => const Color(0xFFE0B15C),
    'Placement' => const Color(0xFF8FD0B2),
    'Clubs' => const Color(0xFFC9A2E8),
    'Admin' => const Color(0xFF9DB8E8),
    _ => const Color(0xFFE8E8EA),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GlassSurface(
            radius: 20,
            blur: 22,
            tint: Colors.white.withValues(alpha: 0.10),
            tintTop: Colors.white.withValues(alpha: 0.14),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _categoryColor.withValues(alpha: 0.34),
                        ),
                      ),
                      child: Text(
                        notice.category,
                        style: AppType.inter(
                          10.5,
                          weight: 500,
                          color: _categoryColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      notice.office,
                      style: AppType.inter(
                        12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    if (notice.pinned)
                      Icon(
                        Icons.push_pin_rounded,
                        size: 15,
                        color: Brand.emberLight,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      notice.date,
                      style: AppType.inter(
                        12,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notice.title,
                  style: AppType.inter(
                    16.5,
                    weight: 600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notice.body,
                  style: AppType.inter(
                    13.5,
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onShare,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.ios_share_rounded,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Share',
                                style: AppType.inter(
                                  12,
                                  weight: 500,
                                  color: Colors.white.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 360.ms,
          curve: Curves.easeOutCubic,
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
