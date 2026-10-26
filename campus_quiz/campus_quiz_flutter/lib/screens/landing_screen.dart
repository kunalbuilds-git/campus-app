import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../navigation.dart';
import '../theme/brand.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/grain_overlay.dart';

/// The landing page.
///
/// Scrolling does not move the page: it scrubs a fixed background video frame
/// by frame while three text panels cross-fade over it. Each panel owns a
/// slice of the scroll as `[fadeInStart, fadeInEnd, fadeOutStart, fadeOutEnd]`;
/// the gaps between one panel's fade-out and the next panel's fade-in are
/// deliberate dead zones where only the footage is visible, so two panels are
/// never readable at once.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  // 1920x1080, 10.04s, 241 frames, all-intra: every frame is a keyframe,
  // which is why a scroll scrub can land on an exact frame instantly.
  static const String _videoUrl =
      'https://d2ol7oe51mr4n9.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/45567745-d826-44a2-a5ce-7ef670944e60.mp4';

  static const List<List<double>> _cues = [
    [0.00, 0.00, 0.15, 0.23],
    [0.35, 0.43, 0.57, 0.65],
    [0.77, 0.85, 1.10, 1.20],
  ];

  static const double _drift = 22;

  final ValueNotifier<double> _progress = ValueNotifier<double>(0);

  VideoPlayerController? _video;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  double _scrollOffset = 0;
  double _velocity = 0;
  double? _dragAnchor;

  double _seekTo = 0;
  double _seekAt = 0;
  double _duration = 0;
  bool _ready = false;

  double _bootProgress = 0;
  bool _booted = false;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _ticker = createTicker(_onTick)..start();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _video = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      _duration = controller.value.duration.inMilliseconds / 1000;
      _seekAt = _seekTo;
      await controller.seekTo(const Duration(milliseconds: 1));
      setState(() {
        _ready = true;
        _bootProgress = 1;
      });
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (mounted) setState(() => _booted = true);
    } catch (_) {
      // A blocked or offline clip must not strand the page behind the
      // preloader: reveal the surface and let the copy carry it.
      if (!mounted) return;
      setState(() {
        _ready = true;
        _bootProgress = 1;
        _booted = true;
      });
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _progress.dispose();
    _video?.dispose();
    super.dispose();
  }

  // --- Scroll model -------------------------------------------------------

  double get _maxScroll {
    final height = MediaQuery.sizeOf(context).height;
    final track = math.max(height * 5.6, 3200);
    return math.max(track - height, 1);
  }

  void _readScroll() {
    final progress = (_scrollOffset / _maxScroll).clamp(0.0, 1.0);
    _progress.value = progress;
    if (_duration > 0) _seekTo = progress * _duration;
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    // Inertia after a flick, so the page keeps travelling briefly.
    if (_dragAnchor == null && _velocity.abs() > 0.02) {
      _scrollOffset = (_scrollOffset + _velocity * delta * 60).clamp(
        0.0,
        _maxScroll,
      );
      _velocity *= math.pow(0.94, delta * 60).toDouble();
      if (_velocity.abs() < 0.02) _velocity = 0;
      _readScroll();
    }

    if (_ready && _duration > 0) {
      final gap = _seekTo - _seekAt;
      if (gap.abs() > 0.0008) {
        // Easing the playhead towards the scroll target, rather than
        // snapping to it, is what turns a jumpy scrub into a smooth one.
        _seekAt += gap * 0.115;
        final value = _video?.value;
        if (value != null && !value.isBuffering && !value.isPlaying) {
          _video?.seekTo(
            Duration(milliseconds: (_seekAt * 1000).round()),
          );
        }
      }
    }

    if (!_booted && _bootProgress < 0.92) {
      _bootProgress = math.min(0.92, _bootProgress + delta * 0.55);
      if (mounted) setState(() {});
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _velocity = 0;
      _scrollOffset = (_scrollOffset + event.scrollDelta.dy).clamp(
        0.0,
        _maxScroll,
      );
      _readScroll();
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragAnchor = event.position.dy;
    _velocity = 0;
    _unlockVideo();
  }

  void _onPointerMove(PointerMoveEvent event) {
    final anchor = _dragAnchor;
    if (anchor == null) return;
    final delta = anchor - event.position.dy;
    _dragAnchor = event.position.dy;
    _scrollOffset = (_scrollOffset + delta).clamp(0.0, _maxScroll);
    _readScroll();
  }

  void _onPointerUp(PointerUpEvent event) {
    _dragAnchor = null;
  }

  /// iOS will not paint a frame from a video that has never been played, so
  /// nudge it once on the first interaction and pause immediately.
  void _unlockVideo() {
    if (_unlocked) return;
    _unlocked = true;
    final video = _video;
    if (video == null) return;
    video.play().then((_) => video.pause()).catchError((_) {});
  }

  // --- Helpers ------------------------------------------------------------

  static double _clamp(double v, double a, double b) =>
      v < a ? a : (v > b ? b : v);

  static double _smooth(double t) => t * t * (3 - 2 * t);

  /// 1 while `p` is past the ramp, 0 before it, smooth in between.
  static double _ramp(double p, double a, double b) {
    if (b <= a) return p >= b ? 1 : 0;
    return _smooth(_clamp((p - a) / (b - a), 0, 1));
  }

  void _goTo(String route) {
    if (_booted) Navigator.of(context).pushNamed(route);
  }

  // --- Build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width <= 720;
    final tiny = size.width <= 420;
    final short = size.height <= 520 && size.width > size.height;

    return Scaffold(
      backgroundColor: Brand.paper,
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerSignal: _onPointerSignal,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: (_) => _dragAnchor = null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildVideoLayer(),
            _buildVeil(compact: compact),
            Positioned.fill(child: GrainOverlay(opacity: 0.13)),
            _buildPanels(compact: compact, tiny: tiny, short: short),
            _buildHeader(compact: compact, tiny: tiny),
            _buildFooter(compact: compact),
            _buildMeter(),
            if (!_booted) _buildBoot(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayer() {
    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const ColoredBox(color: Brand.paper);
    }

    return ClipRect(
      child: Transform.scale(
        scale: 1.02,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: video.value.size.width,
            height: video.value.size.height,
            child: VideoPlayer(video),
          ),
        ),
      ),
    );
  }

  /// A deliberately light wash over high-key footage, heavier at the top and
  /// bottom edges where the navigation and footer sit.
  Widget _buildVeil({required bool compact}) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: compact
                ? [
                    const Color(0xFFB8B5B1).withValues(alpha: 0.72),
                    const Color(0xFFF2F0EC).withValues(alpha: 0.18),
                    const Color(0xFFF2F0EC).withValues(alpha: 0.18),
                    const Color(0xFFB8B5B1).withValues(alpha: 0.74),
                  ]
                : [
                    const Color(0xFFF2F0EC).withValues(alpha: 0.62),
                    const Color(0xFFF2F0EC).withValues(alpha: 0.12),
                    const Color(0xFFF2F0EC).withValues(alpha: 0.12),
                    const Color(0xFFF2F0EC).withValues(alpha: 0.66),
                  ],
            stops: compact
                ? const [0, 0.24, 0.76, 1]
                : const [0, 0.22, 0.78, 1],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.8,
              colors: [
                Brand.paper.withValues(alpha: 0),
                Brand.paper.withValues(alpha: compact ? 0.40 : 0.34),
              ],
            ),
          ),
          child: ColoredBox(
            color: Brand.paper.withValues(alpha: compact ? 0.24 : 0.20),
          ),
        ),
      ),
    );
  }

  Widget _buildPanels({
    required bool compact,
    required bool tiny,
    required bool short,
  }) {
    final panels = <Widget>[
      _PanelContent(
        eyebrow: const [
          TextSpan(text: 'Campus events'),
          TextSpan(text: ' · '),
          TextSpan(text: 'Every club, one feed'),
        ],
        headline: 'Everything’s on.\nNothing’s buried.',
        sub:
            'Lectures, matches, mixers and maker nights — every event on '
            'campus in one feed, with live numbers on who is going.',
        cta: 'See the feed',
        onCta: () => _goTo('/chat'),
        compact: compact,
        tiny: tiny,
        short: short,
      ),
      _PanelContent(
        eyebrow: const [TextSpan(text: 'Around the quad')],
        headline: 'Know it’s open\nbefore you walk.',
        sub:
            'Capacity and RSVPs stay live, so you never cross the quad for a '
            'talk that filled up an hour ago.',
        cta: 'Browse events',
        onCta: () => _goTo('/chat'),
        compact: compact,
        tiny: tiny,
        short: short,
      ),
      _PanelContent(
        eyebrow: const [TextSpan(text: 'One tap')],
        headline: 'Say you’re going.\nWe’ll handle the rest.',
        sub:
            'Mark yourself going in a tap, and we’ll remind you when the room '
            'changes or the event starts.',
        cta: 'Open your board',
        onCta: () => _goTo('/profile'),
        compact: compact,
        tiny: tiny,
        short: short,
      ),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < panels.length; i++)
          ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (context, progress, _) {
              final cue = _cues[i];
              final enter = _ramp(progress, cue[0], cue[1]);
              final leave = _ramp(progress, cue[2], cue[3]);
              final opacity = enter * (1 - leave);
              final y = (1 - enter) * _drift - leave * _drift;

              return IgnorePointer(
                ignoring: opacity <= 0.6,
                child: Opacity(
                  opacity: opacity.clamp(0, 1),
                  child: Transform.translate(
                    offset: Offset(0, y),
                    child: panels[i],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildHeader({required bool compact, required bool tiny}) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
          left: compact ? 12 : 20,
          right: compact ? 12 : 20,
          top: math.max(12, topInset + 8),
          child: GlassNavBar(
            dark: false,
            brand: 'CampHere',
            links: campLinks,
            linkRoutes: campRoutes,
            trailing: _pill(
              label: 'Ask a question',
              height: compact ? 38 : 40,
              padding: compact ? 16 : 21,
              fontSize: compact ? 13.5 : 14.5,
              onTap: () => _goTo('/chat'),
            ),
          ),
        )
        .animate(delay: 60.ms)
        .fadeIn(duration: 560.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: -0.3,
          end: 0,
          duration: 560.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _pill({
    required String label,
    required double height,
    required double padding,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: Brand.ink,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x1A0A0908)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppType.inter(
                  fontSize,
                  weight: 500,
                  color: Colors.white,
                  letterSpacing: -0.008 * fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter({required bool compact}) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          padding: EdgeInsets.only(
            top: 14,
            left: compact ? 16 : 24,
            right: compact ? 16 : 24,
            bottom: math.max(16, bottomInset + 12),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Brand.paper.withValues(alpha: 0.92),
                Brand.paper.withValues(alpha: 0.72),
                Brand.paper.withValues(alpha: 0),
              ],
              stops: const [0, 0.72, 1],
            ),
          ),
          child: Text(
            'The Quad · Every day, 8am till the last event ends',
            textAlign: TextAlign.center,
            style: AppType.inter(
              compact ? 11 : 12,
              color: Brand.ink.withValues(alpha: 0.42),
              letterSpacing: 0.02 * (compact ? 11 : 12),
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeter() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: ValueListenableBuilder<double>(
        valueListenable: _progress,
        builder: (context, progress, _) {
          return Transform.translate(
            offset: Offset.zero,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..scaleByDouble(progress, 1, 1, 1),
                  child: Container(
                    height: 2,
                    color: Brand.ink.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoot() {
    return Positioned.fill(
      child: ColoredBox(
        color: Brand.paper,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 1,
              child: ColoredBox(
                color: Brand.ink.withValues(alpha: 0.16),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _bootProgress.clamp(0, 1),
                  child: const ColoredBox(color: Brand.ink),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'LOADING ${(_bootProgress.clamp(0, 1) * 100).round()}%',
              style: AppType.inter(
                12.5,
                color: Brand.ink.withValues(alpha: 0.42),
                letterSpacing: 0.05 * 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double sizeWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

/// One text panel: eyebrow, headline, supporting line and a single action.
class _PanelContent extends StatelessWidget {
  const _PanelContent({
    required this.eyebrow,
    required this.headline,
    required this.sub,
    required this.cta,
    required this.onCta,
    required this.compact,
    required this.tiny,
    required this.short,
  });

  final List<InlineSpan> eyebrow;
  final String headline;
  final String sub;
  final String cta;
  final VoidCallback onCta;
  final bool compact;
  final bool tiny;
  final bool short;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final headlineSize = short
        ? 28.0
        : tiny
        ? (30 + width * 0.075).clamp(28, 40).toDouble()
        : compact
        ? (30 + width * 0.068).clamp(30, 52).toDouble()
        : (34 + width * 0.037).clamp(34, 104).toDouble();

    final subSize = compact
        ? 15.0
        : (15 + width * 0.0028).clamp(15, 19).toDouble();
    final eyebrowSize = tiny ? 11.0 : 12.5;
    final eyebrowMax = tiny ? 28 * 12.5 : 46 * 12.5;

    final padding = short
        ? EdgeInsets.only(
            top: math.max(72, topInset + 56),
            left: 24,
            right: 24,
            bottom: math.max(64, bottomInset + 48),
          )
        : EdgeInsets.only(
            top: math.max(compact ? 92 : 104, topInset + (compact ? 76 : 88)),
            left: compact ? 18 : (width * 0.05).clamp(20, 60),
            right: compact ? 18 : (width * 0.05).clamp(20, 60),
            bottom: math.max(
              compact ? 88 : 96,
              bottomInset + (compact ? 72 : 80),
            ),
          );

    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: eyebrowMax),
            child: Text.rich(
              TextSpan(children: eyebrow),
              textAlign: TextAlign.center,
              style: AppType.inter(
                eyebrowSize,
                color: Brand.ink.withValues(alpha: 0.64),
                letterSpacing: 0.045 * eyebrowSize,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(
            height: compact ? 16 : math.min(22, width * 0.02).toDouble(),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: tiny
                  ? 11 * headlineSize
                  : compact
                  ? 12 * headlineSize
                  : 15 * headlineSize,
            ),
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: AppType.tight(
                headlineSize,
                weight: 400,
                color: Brand.ink,
                letterSpacing: -0.036 * headlineSize,
                height: 0.98,
              ),
            ),
          ),
          SizedBox(
            height: short
                ? 12
                : (compact ? 18 : math.min(28, width * 0.022).toDouble()),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 34 * 15 : 46 * 19),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: AppType.inter(
                subSize,
                color: Brand.ink.withValues(alpha: 0.64),
                letterSpacing: -0.008 * subSize,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(
            height: short
                ? 16
                : (compact ? 28 : math.min(44, width * 0.034).toDouble()),
          ),
          _PanelPill(
            label: cta,
            onTap: onCta,
            compact: compact,
            tiny: tiny,
          ),
        ],
      ),
    );
  }
}

class _PanelPill extends StatefulWidget {
  const _PanelPill({
    required this.label,
    required this.onTap,
    required this.compact,
    required this.tiny,
  });

  final String label;
  final VoidCallback onTap;
  final bool compact;
  final bool tiny;

  @override
  State<_PanelPill> createState() => _PanelPillState();
}

class _PanelPillState extends State<_PanelPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final height = widget.tiny ? 44.0 : 48.0;
    final fontSize = widget.tiny ? 14.0 : 15.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Brand.easePrimary,
          height: height,
          width: widget.tiny ? 280 : null,
          padding: EdgeInsets.symmetric(horizontal: widget.tiny ? 20 : 27),
          decoration: BoxDecoration(
            color: _hovered ? Brand.ember : Brand.ink,
            borderRadius: BorderRadius.circular(999),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: AppType.inter(
                    fontSize,
                    weight: 500,
                    color: Colors.white,
                    letterSpacing: -0.008 * fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
