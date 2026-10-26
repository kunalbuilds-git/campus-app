import 'dart:math' as math;
import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/material.dart';

import '../data/behavior_engine.dart';
import '../data/campus_assistant.dart';
import '../data/campus_repository.dart';
import '../data/campus_seed.dart';
import '../theme/brand.dart';
import '../widgets/brand_mark.dart';
import '../widgets/glass.dart';
import '../widgets/wave_chart.dart';

/// The student profile.
///
/// The composition follows the reference dashboard: a narrow rail on the
/// left, a header with the account tools, a hero block, a weekly activity
/// curve, and a column of glass cards on the right. Every panel is frosted —
/// translucent white over the blurred photograph — rather than a solid card.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  final CampusProfile profile = sampleProfile;
  List<EventSummary> _feed = const [];

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }
    BehaviorEngine.instance.record('section', 'my board');
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final feed = await CampusRepository().feed();
    if (!mounted) return;
    setState(() => _feed = feed);
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  double _u(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final byWidth = size.width / 1357;
    final byHeight = size.height / 871;
    return math.min(byWidth, byHeight).toDouble();
  }

  Animation<double> _at(double start, double duration, Curve curve) {
    // The choreography beats are absolute seconds along the timeline.
    final total = _entrance.duration!.inMilliseconds;
    final begin = (start * 1000 / total).clamp(0.0, 1.0);
    final end = math.min(1.0, begin + duration * 1000 / total);
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(begin, end, curve: curve),
    );
  }

  Widget _enter(
    Animation<double> animation, {
    required Widget child,
    Offset from = const Offset(0, 14),
    double scale = 1,
  }) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(from.dx * (1 - t), from.dy * (1 - t)),
            child: Transform.scale(
              scale: scale + (1 - scale) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mobile = size.width <= 860;

    return Scaffold(
      backgroundColor: const Color(0xFF04121B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackdrop(),
          if (mobile) _buildMobile(context) else _buildDesktop(context),
          if (mobile) _buildDock(context, math.min(size.width / 430, 1.22)),
        ],
      ),
    );
  }

  Widget _buildBackdrop() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/campus_bg.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.5),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF041018).withValues(alpha: 0.34),
                  const Color(0xFF041018).withValues(alpha: 0.20),
                  const Color(0xFF041018).withValues(alpha: 0.06),
                  const Color(0xFF041018).withValues(alpha: 0),
                ],
                stops: const [0, 0.40, 0.78, 1],
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF041018).withValues(alpha: 0.12),
                    const Color(0xFF041018).withValues(alpha: 0),
                  ],
                  stops: const [0, 0.22],
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF041018).withValues(alpha: 0.07),
                      const Color(0xFF041018).withValues(alpha: 0.07),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Desktop ------------------------------------------------------------

  Widget _buildDesktop(BuildContext context) {
    final u = _u(context);

    return Stack(
      children: [
        Positioned(
          left: 16 * u,
          top: 14 * u,
          bottom: 7 * u,
          width: 72 * u,
          child: _buildSidebar(context, u),
        ),
        Positioned(
          left: 126 * u,
          right: 37 * u,
          top: 22 * u,
          child: _buildHeader(context, u),
        ),
        Positioned(
          left: 126 * u,
          top: 136 * u,
          width: 560 * u,
          child: _buildHero(context, u),
        ),
        Positioned(
          left: 126 * u,
          right: 396 * u,
          bottom: 99 * u,
          child: _buildForecast(context, u),
        ),
        Positioned(
          right: 38 * u,
          top: 134 * u,
          bottom: 95 * u,
          width: 310 * u,
          child: _buildRail(context, u),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, double u) {
    const items = [
      (Icons.grid_view_outlined, 'Home', '/'),
      (Icons.local_activity_outlined, 'Events', '/events'),
      (Icons.campaign_outlined, 'Notice board', '/notices'),
      (Icons.assignment_outlined, 'Assignments', '/assignments'),
      (Icons.groups_outlined, 'Clubs', '/clubs'),
      (Icons.event_available_outlined, 'Attendance', '/attendance'),
      (Icons.star_border_outlined, 'My events', '/profile'),
      (Icons.settings_outlined, 'Settings', '/profile'),
    ];

    return GlassSurface(
      radius: 26 * u,
      blur: 18 * u,
      saturation: 115,
      tint: Colors.white.withValues(alpha: 0.092),
      tintTop: Colors.white.withValues(alpha: 0.125),
      sheen: false,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _enter(
                _at(0.26, 0.70, Brand.easePrimary),
                child: QuadLogo(size: 40 * u),
                from: Offset.zero,
                scale: 0.7,
              ),
              SizedBox(height: 57.5 * u),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 43 * u),
                  child: _enter(
                    _at(0.36 + i * 0.05, 0.60, Brand.easeSoft),
                    child: _railButton(
                      items[i].$1,
                      items[i].$2,
                      u,
                      route: items[i].$3,
                      active: i == 0,
                    ),
                  ),
                ),
            ],
          ),
          // Active pip.
          Positioned(
            left: -2 * u,
            top: 131 * u,
            child: _enter(
              _at(0.68, 0.50, Brand.easeSoft),
              child: Container(
                width: 5 * u,
                height: 29 * u,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3 * u),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.55),
                      blurRadius: 10 * u,
                    ),
                  ],
                ),
              ),
              from: Offset.zero,
              scale: 1,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22 * u,
            child: _enter(
              _at(0.70, 0.60, Brand.easeSoft),
              child: _railButton(Icons.logout_outlined, 'Sign out', u),
            ),
          ),
        ],
      ),
    );
  }

  Widget _railButton(
    IconData icon,
    String label,
    double u, {
    bool active = false,
    String? route,
  }) {
    return Tooltip(
      message: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: route == null
              ? null
              : () => Navigator.of(context).pushNamed(route),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 23 * u,
            height: 23 * u,
            child: Icon(icon, size: 23 * u, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double u) {
    // The head bar: the account block and tools sit inside one frosted
    // pill floating over the photograph.
    return GlassSurface(
      radius: 999,
      blur: 20 * u,
      tint: Colors.white.withValues(alpha: 0.10),
      tintTop: Colors.white.withValues(alpha: 0.15),
      sheen: false,
      padding: EdgeInsets.symmetric(horizontal: 24 * u, vertical: 10 * u),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _enter(
                  _at(0.14, 0.70, Brand.easeSoft),
                  child: Text(
                    'Welcome',
                    style: AppType.inter(
                      16 * u,
                      color: Colors.white.withValues(alpha: 0.93),
                      height: 1.05,
                    ),
                  ),
                ),
                _enter(
                  _at(0.22, 0.80, Brand.easeSoft),
                  child: Padding(
                    padding: EdgeInsets.only(top: 10 * u),
                    child: Row(
                      children: [
                        Text(
                          profile.name,
                          style: AppType.inter(
                            19.5 * u,
                            weight: 700,
                            color: Colors.white,
                            letterSpacing: -0.35 * u,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(width: 10 * u),
                        Text(
                          profile.handle,
                          style: AppType.inter(
                            13 * u,
                            color: Colors.white.withValues(alpha: 0.55),
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: 16 * u),
                _enter(
                  _at(0.30 + i * 0.065, 0.58, Brand.easePrimary),
                  child: GlassToolButton(
                    icon: i == 0
                        ? Icons.add_outlined
                        : i == 1
                        ? Icons.search_outlined
                        : Icons.notifications_none_outlined,
                    size: 52 * u,
                    iconSize: 21 * u,
                    onTap: () {},
                  ),
                  from: Offset.zero,
                  scale: 0.7,
                ),
              ],
              SizedBox(width: 16 * u),
              _enter(
                _at(0.495, 0.58, Brand.easePrimary),
                child: _Avatar(u: u),
                from: Offset.zero,
                scale: 0.7,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, double u) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _enter(
          _at(0.44, 0.80, Brand.easeSoft),
          child: ClipRect(
            child: SlideReveal(
              animation: _at(0.44, 0.80, Brand.easeSoft),
              axis: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * u,
                  vertical: 6 * u,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'Your term',
                  style: AppType.inter(
                    12.5 * u,
                    weight: 500,
                    color: Colors.white,
                    letterSpacing: 0.02 * 12.5 * u,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20 * u),
        _MaskLine(
          text: 'Twelve events',
          u: u,
          animation: _at(0.56, 1.05, Brand.easePrimary),
        ),
        _MaskLine(
          text: 'and counting',
          u: u,
          animation: _at(0.67, 1.05, Brand.easePrimary),
        ),
        SizedBox(height: 22 * u),
        _enter(
          _at(0.90, 0.90, Brand.easeSoft),
          child: SizedBox(
            width: 480 * u,
            child: Text(
              'You have said yes to ${profile.going} events this term across '
              '${profile.clubs} societies, and kept ${profile.interested} more '
              'on the board. Here is how the autumn is shaping up.',
              style: AppType.inter(
                15.2 * u,
                weight: 500,
                color: Colors.white.withValues(alpha: 0.95),
                letterSpacing: -0.3 * u,
                height: 24 / 15.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForecast(BuildContext context, double u) {
    final points = sampleWeek;
    final cells = points.take(6).toList();

    // The reference pulls the day labels up into the chart's lower padding
    // with a negative margin; the labels are layered over the chart instead.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < cells.length; i++)
              _enter(
                _at(1.26 + i * 0.07, 0.60, Brand.easeSoft),
                child: Column(
                  children: [
                    Icon(
                      _weatherIcon(i),
                      size: 26 * u,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    SizedBox(height: 6 * u),
                    Text(
                      '${cells[i].value}',
                      style: AppType.inter(
                        37 * u,
                        weight: 400,
                        color: Colors.white,
                        letterSpacing: -0.7 * u,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 43 * u),
        SizedBox(
          height: 230 * u,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: WaveChart(
                  values: points.map((p) => p.value.toDouble()).toList(),
                  height: 230 * u,
                  strokeWidth: 3.4 * u,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 199 * u,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < points.length; i++)
                      _enter(
                        _at(2.10 + i * 0.055, 0.60, Brand.easeSoft),
                        child: Text(
                          points[i].label,
                          style: AppType.inter(
                            18 * u,
                            weight: points[i].isToday ? 600 : 500,
                            color: points[i].isToday
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _weatherIcon(int index) => const [
    Icons.cloud_outlined,
    Icons.cloud_outlined,
    Icons.wb_sunny_outlined,
    Icons.ac_unit_outlined,
    Icons.wb_cloudy_outlined,
    Icons.wb_sunny_outlined,
  ][index % 6];

  Widget _buildRail(BuildContext context, double u) {
    final next = buildSampleFeed().take(3).toList();

    // The reference rail: three fixed-height event rows under the summary
    // card. It scrolls rather than overflowing, so the cards never paint
    // over each other on shorter screens.
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_feed.isNotEmpty)
            _ForYouCard(
              picks: BehaviorEngine.instance.personalizeFeed(_feed, take: 2),
              insight: BehaviorEngine.instance.insight(),
              u: u,
            ),
          SizedBox(height: _feed.isNotEmpty ? 20 * u : 0),
          _enter(
            _at(0.80, 0.95, Brand.easeSoft),
            child: _BigCard(u: u),
            from: const Offset(30, 0),
          ),
          SizedBox(height: 20 * u),
          for (var i = 0; i < next.length; i++) ...[
            if (i > 0) SizedBox(height: 20 * u),
            _enter(
              _at(0.92 + i * 0.11, 0.95, Brand.easeSoft),
              child: SizedBox(
                height: 120 * u,
                child: _EventRailCard(summary: next[i], u: u),
              ),
              from: const Offset(30, 0),
            ),
          ],
        ],
      ),
    );
  }

  // --- Mobile -------------------------------------------------------------

  Widget _buildMobile(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final u = math.min(size.width / 430, 1.22);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final next = buildSampleFeed().take(3).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 64 * u + bottomInset + 20 * u),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20 * u,
              18 * u + MediaQuery.paddingOf(context).top,
              20 * u,
              0,
            ),
            child: _buildHeader(context, u),
          ),
          SizedBox(height: 28 * u),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * u),
            child: _buildHero(context, u),
          ),
          SizedBox(height: 30 * u),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * u),
            child: _buildForecast(context, u),
          ),
          SizedBox(height: 34 * u),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * u),
            child: Column(
              children: [
                _BigCard(u: u),
                SizedBox(height: 20 * u),
                for (var i = 0; i < next.length; i++) ...[
                  if (i > 0) SizedBox(height: 20 * u),
                  _EventRailCard(summary: next[i], u: u),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDock(BuildContext context, double u) {
    const items = [
      (Icons.grid_view_outlined, '/'),
      (Icons.local_activity_outlined, '/events'),
      (Icons.campaign_outlined, '/notices'),
      (Icons.assignment_outlined, '/assignments'),
      (Icons.groups_outlined, '/clubs'),
      (Icons.event_available_outlined, '/attendance'),
      (Icons.star_border_outlined, '/profile'),
    ];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GlassSurface(
        radius: 26 * u,
        blur: 18 * u,
        saturation: 115,
        tint: Colors.white.withValues(alpha: 0.10),
        tintTop: Colors.white.withValues(alpha: 0.13),
        sheen: false,
        child: SizedBox(
          height: 64 * u,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < items.length; i++)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(items[i].$2),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6 * u),
                      child: Icon(
                        items[i].$1,
                        size: 21 * u,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52 * u,
      height: 52 * u,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5 * u,
        ),
      ),
      child: SizedBox.expand(
        child: Image.network(
          sampleProfile.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: Colors.white.withValues(alpha: 0.18),
            child: Center(
              child: Text(
                sampleProfile.initials,
                style: AppType.inter(
                  17 * u,
                  weight: 600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(color: Colors.white.withValues(alpha: 0.12));
          },
        ),
      ),
    );
  }
}

/// A headline line that rises out of a mask.
class _MaskLine extends StatelessWidget {
  const _MaskLine({
    required this.text,
    required this.u,
    required this.animation,
  });

  final String text;
  final double u;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        child: Text(
          text,
          style: AppType.tight(
            63 * u,
            weight: 500,
            color: Colors.white,
            letterSpacing: 0.25 * u,
            height: 78 / 63,
          ),
        ),
        builder: (context, child) {
          final t = animation.value;
          return Transform.translate(
            offset: Offset(0, (1 - t) * 115),
            child: Opacity(opacity: t.clamp(0, 1), child: child),
          );
        },
      ),
    );
  }
}

/// A chip that wipes in from the left.
class SlideReveal extends StatelessWidget {
  const SlideReveal({
    super.key,
    required this.animation,
    required this.child,
    this.axis = Axis.vertical,
  });

  final Animation<double> animation;
  final Widget child;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        return ClipRect(
          child: Align(
            alignment: axis == Axis.horizontal
                ? Alignment.centerLeft
                : Alignment.topCenter,
            widthFactor: axis == Axis.horizontal ? t : null,
            heightFactor: axis == Axis.vertical ? t : null,
            child: child,
          ),
        );
      },
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    final profile = sampleProfile;

    return GlassSurface(
      radius: 26 * u,
      blur: 26 * u,
      saturation: 118,
      tint: Colors.white.withValues(alpha: 0.232),
      tintTop: Colors.white.withValues(alpha: 0.20),
      padding: EdgeInsets.fromLTRB(22 * u, 20 * u, 22 * u, 20 * u),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CampHere',
                style: AppType.inter(
                  15 * u,
                  weight: 500,
                  color: Colors.white,
                  letterSpacing: -0.01 * 15 * u,
                ),
              ),
              SizedBox(width: 6 * u),
              Icon(
                Icons.place_outlined,
                size: 15 * u,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const Spacer(),
              Text(
                profile.term,
                style: AppType.inter(
                  12.5 * u,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * u),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${profile.going}',
                style: AppType.tight(
                  92 * u,
                  weight: 500,
                  color: Colors.white,
                  letterSpacing: -4.4 * u,
                  height: 0.95,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16 * u, left: 6 * u),
                child: Text(
                  'events',
                  style: AppType.inter(
                    17 * u,
                    weight: 400,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * u),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(
                icon: Icons.air_outlined,
                value: '${profile.going}',
                label: 'going',
                u: u,
              ),
              _Metric(
                icon: Icons.water_drop_outlined,
                value: '${profile.interested}',
                label: 'saved',
                u: u,
              ),
              _Metric(
                icon: Icons.navigation_outlined,
                value: '${profile.clubs}',
                label: 'clubs',
                u: u,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.u,
  });

  final IconData icon;
  final String value;
  final String label;
  final double u;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15 * u, color: Colors.white.withValues(alpha: 0.7)),
        SizedBox(width: 5 * u),
        Text(
          value,
          style: AppType.inter(
            15 * u,
            weight: 600,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 4 * u),
        Text(
          label,
          style: AppType.inter(
            13 * u,
            weight: 400,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _EventRailCard extends StatelessWidget {
  const _EventRailCard({required this.summary, required this.u});

  final EventSummary summary;
  final double u;

  @override
  Widget build(BuildContext context) {
    final event = summary.event;

    return GlassSurface(
      radius: 24 * u,
      blur: 26 * u,
      saturation: 118,
      tint: Colors.white.withValues(alpha: 0.232),
      tintTop: Colors.white.withValues(alpha: 0.20),
      padding: EdgeInsets.fromLTRB(20 * u, 16 * u, 20 * u, 16 * u),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.category.label,
                  style: AppType.inter(
                    12 * u,
                    weight: 500,
                    color: Colors.white.withValues(alpha: 0.62),
                    letterSpacing: 0.02 * 12 * u,
                  ),
                ),
                SizedBox(height: 3 * u),
                Text(
                  event.location,
                  style: AppType.inter(
                    15.5 * u,
                    weight: 600,
                    color: Colors.white,
                    letterSpacing: -0.01 * 15.5 * u,
                  ),
                ),
                SizedBox(height: 2 * u),
                Text(
                  event.organizer,
                  style: AppType.inter(
                    13 * u,
                    weight: 400,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                _categoryIcon(event.category),
                size: 24 * u,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              SizedBox(height: 6 * u),
              Text(
                '${summary.goingCount} going',
                style: AppType.inter(
                  13 * u,
                  weight: 500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2 * u),
              Text(
                formatEventWhen(event),
                style: AppType.inter(
                  11.5 * u,
                  weight: 400,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(EventCategory category) => switch (category) {
    EventCategory.tech => Icons.code_outlined,
    EventCategory.sports => Icons.sports_soccer_outlined,
    EventCategory.cultural => Icons.music_note_outlined,
    EventCategory.academic => Icons.school_outlined,
    EventCategory.workshop => Icons.handyman_outlined,
    EventCategory.community => Icons.groups_outlined,
    EventCategory.other => Icons.category_outlined,
  };
}

/// The personalisation surface on the board: what the behaviour engine
/// thinks the student wants next, and why.
class _ForYouCard extends StatelessWidget {
  const _ForYouCard({
    required this.picks,
    required this.insight,
    required this.u,
  });

  final List<EventSummary> picks;
  final String? insight;
  final double u;

  @override
  Widget build(BuildContext context) {
    final lead = picks.isEmpty ? null : picks.first.event;

    return GlassSurface(
      radius: 24 * u,
      blur: 24 * u,
      tint: Brand.ember.withValues(alpha: 0.14),
      tintTop: Brand.ember.withValues(alpha: 0.20),
      sheen: false,
      padding: EdgeInsets.fromLTRB(20 * u, 16 * u, 20 * u, 16 * u),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14 * u,
                color: Brand.emberLight,
              ),
              SizedBox(width: 6 * u),
              Text(
                'For you',
                style: AppType.inter(
                  13.5 * u,
                  weight: 600,
                  color: Brand.emberLight,
                  letterSpacing: 0.02 * 13.5 * u,
                ),
              ),
              SizedBox(width: 10 * u),
              if (insight != null)
                Expanded(
                  child: Text(
                    insight!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppType.inter(
                      11.5 * u,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.3,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8 * u),
          if (lead != null)
            Text(
              lead.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppType.inter(
                15 * u,
                weight: 600,
                color: Colors.white,
                letterSpacing: -0.15 * u,
                height: 1.2,
              ),
            ),
          if (picks.length > 1)
            Padding(
              padding: EdgeInsets.only(top: 4 * u),
              child: Text(
                'and ${picks[1].event.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.inter(
                  12.5 * u,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
            ),
          SizedBox(height: 6 * u),
          Text(
            'Ranked from what you open, not what everyone opens.',
            style: AppType.inter(
              11.5 * u,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
