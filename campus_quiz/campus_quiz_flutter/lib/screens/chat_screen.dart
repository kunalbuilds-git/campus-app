import 'dart:math' as math;
import 'dart:ui';

import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../data/behavior_engine.dart';
import '../data/campus_assistant.dart';
import '../data/campus_repository.dart';
import '../llm/llm_router.dart';
import '../navigation.dart';
import '../theme/brand.dart';
import '../widgets/glass_nav_bar.dart';

/// The event finder.
///
/// The surface follows the dark reference: a looping landscape behind the
/// whole viewport, a glass composer card, and a proof strip at the bottom.
/// The composer keeps the reference geometry exactly — the model label, the
/// paperclip and the send circle are placed at measured offsets rather than
/// being centred in a flex row.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final VideoPlayerController _video;
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _thread = ScrollController();

  final List<_ChatMessage> _messages = [];
  List<EventSummary> _feed = const [];
  bool _loading = true;
  bool _sheetOpen = false;
  bool _videoReady = false;
  late final LlmRouter _llm = LlmRouter();

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    _initVideo();
    _loadFeed();
    // Keep the provider health warm in the background so failover happens
    // before the student asks the next question.
    _llm.startProbing();
  }

  Future<void> _initVideo() async {
    _video = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260826_124724_bc041163-d651-425f-aea3-2acc1efc2c96.mp4',
      ),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await _video.initialize();
      await _video.setLooping(true);
      await _video.play();
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {
      // The surface is designed to stand on its own without the footage.
    }
  }

  Future<void> _loadFeed() async {
    final repository = CampusRepository();
    final feed = await repository.feed();
    if (!mounted) return;
    setState(() {
      _feed = feed;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _llm.dispose();
    _entrance.dispose();
    _input.dispose();
    _inputFocus.dispose();
    _thread.dispose();
    _video.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    BehaviorEngine.instance.record('search', text);

    _input.clear();
    setState(() {
      _messages.add(_ChatMessage.user(text));
      _loading = true;
    });
    _scrollThread();

    final search = CampusAssistant(_feed);
    final searchReply = search.reply(text);
    // Asking about events is itself a signal the engine learns from.
    for (final match in searchReply.events) {
      BehaviorEngine.instance.record('event', match.event.category.name);
    }

    // The guide answers with an LLM when one is reachable; if a provider is
    // down the router silently fails over, and if none answer the local
    // search takes over. Either way the student only ever sees one reply.
    var answer = searchReply.text;
    if (_llm.isConfigured) {
      final llmText = await _llm.complete(
        messages: [
          LlmMessage(role: 'system', content: search.systemContext()),
          LlmMessage(role: 'user', content: text),
        ],
      );
      if (llmText != null) answer = llmText;
    }

    if (!mounted) return;
    setState(() {
      _messages.add(
        _ChatMessage.assistant(
          ChatReply(
            text: answer,
            events: searchReply.events,
            actions: searchReply.actions,
          ),
        ),
      );
      _loading = false;
    });
    _scrollThread();
  }

  void _scrollThread() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_thread.hasClients) return;
      _thread.animateTo(
        _thread.position.maxScrollExtent,
        duration: const Duration(milliseconds: 420),
        curve: Brand.easeSoft,
      );
    });
  }

  // --- Layout helpers -----------------------------------------------------

  /// One reference pixel on the 1560x1008 canvas.
  ///
  /// The reference CSS expresses this as min(0.06410256vw, 0.12400794vh),
  /// i.e. a percentage of the viewport: width / 1560 against height / 1008.
  double _u(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return math.min(size.width / 1560, size.height / 1008);
  }

  /// One reference pixel measured against the viewport height.
  double _vu(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return height / 1008;
  }

  _LayoutMode _mode(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width <= 599) return _LayoutMode.compact;
    if (size.height <= 599 && size.width <= 1180) return _LayoutMode.compact;
    if (size.width <= 1180) return _LayoutMode.tablet;
    return _LayoutMode.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode(context);

    return Scaffold(
      backgroundColor: Brand.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackdrop(),
          if (mode == _LayoutMode.desktop)
            _buildDesktop(context)
          else
            _buildResponsive(context, mode),
        ],
      ),
    );
  }

  Widget _buildBackdrop() {
    if (!_videoReady) {
      return const ColoredBox(color: Brand.night);
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _video.value.size.width,
          height: _video.value.size.height,
          child: VideoPlayer(_video),
        ),
      ),
    );
  }

  // --- Desktop composition ------------------------------------------------

  Widget _buildDesktop(BuildContext context) {
    final u = _u(context);
    final vu = _vu(context);
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 1561;

    final insetTop = wide ? 27.0 : 41.0;
    final insetBottom = wide ? 74.0 : 106.0;

    return Padding(
      padding: EdgeInsets.only(
        top: insetTop * vu,
        bottom: insetBottom * vu,
        left: 225 * u,
        right: 225 * u,
      ),
      child: Column(
        children: [
          _buildNav(context, u, vu, compact: false),
          Expanded(
            child: _messages.isEmpty
                ? _buildHero(context, u, vu)
                : _buildThread(context, u, vu),
          ),
          _buildProof(context, u, vu),
        ],
      ),
    );
  }

  Widget _buildNav(
    BuildContext context,
    double u,
    double vu, {
    required bool compact,
  }) {
    return SizedBox(
          height: 56,
          child: GlassNavBar(
            dark: true,
            brand: 'CampHere',
            links: campLinks,
            linkRoutes: campRoutes,
            statusDot: true,
            trailing: compact
                ? _BurgerButton(
                    open: _sheetOpen,
                    onTap: () => setState(() => _sheetOpen = !_sheetOpen),
                  )
                : _headerCta('Post an event', 1),
          ),
        )
        .animate(delay: 80.ms)
        .fadeIn(duration: 520.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: -0.3,
          end: 0,
          duration: 520.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _headerCta(String label, double u) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 140 * u,
          height: 43 * u,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * u),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3D3D3F), Color(0xFF1D1D20)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 14 * u,
                offset: Offset(0, 2 * u),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, 2 * u),
                child: Text(
                  label,
                  style: AppType.inter(
                    15.70 * u,
                    weight: 520,
                    color: Colors.white,
                    letterSpacing: -0.0127 * 15.70 * u,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final base = CampusAssistant(_feed).greeting();
    final insight = BehaviorEngine.instance.insight();
    return insight == null ? base : '$base  ·  $insight';
  }

  Widget _buildHero(BuildContext context, double u, double vu) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _enter(
          _entranceAt(0.30, 1.00, Brand.easePrimary),
          dy: 14 * u,
          blur: 6 * u,
          child: Text(
            'Ask what’s on. We’ll find it.',
            textAlign: TextAlign.center,
            style: AppType.inter(
              36.25 * u,
              weight: 410,
              color: Colors.white,
              letterSpacing: 0.0018 * 36.25 * u,
              height: 1.10,
              opsz: 32,
            ),
          ),
        ),
        SizedBox(height: 14 * u),
        _enter(
          _entranceAt(0.46, 0.60, Brand.easeSoft),
          dy: 8 * u,
          child: Text(
            _greeting(),
            textAlign: TextAlign.center,
            style: AppType.inter(
              13.5 * u,
              weight: 400,
              color: Colors.white.withValues(alpha: 0.66),
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 34 * vu),
        _enter(
          _entranceAt(0.62, 0.90, Brand.easePrimary),
          dy: 18 * u,
          child: _ComposerCard(
            u: u,
            mode: _LayoutMode.desktop,
            controller: _input,
            focusNode: _inputFocus,
            onSend: _send,
          ),
        ),
      ],
    );
  }

  Widget _buildThread(BuildContext context, double u, double vu) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _thread,
            padding: EdgeInsets.only(top: 24 * vu, bottom: 12 * vu),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _messages.length) {
                return _TypingLine(u: u, vu: vu);
              }
              final message = _messages[index];
              return _MessageBlock(message: message, u: u, vu: vu);
            },
          ),
        ),
        _ComposerCard(
          u: u,
          mode: _LayoutMode.desktop,
          controller: _input,
          focusNode: _inputFocus,
          onSend: _send,
        ),
      ],
    );
  }

  Widget _buildProof(BuildContext context, double u, double vu) {
    const societies = [
      ('Coding Club', 96.84),
      ('Sports Council', 67.29),
      ('Cultural Society', 88.68),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _enter(
          _entranceAt(1.08, 0.55, Brand.easeSoft),
          dy: 6 * vu,
          child: Text(
            'Hosted by student societies',
            style: AppType.inter(
              14.01 * u,
              weight: 480,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: 0.0065 * 14.01 * u,
              opsz: 32,
            ),
          ),
        ),
        SizedBox(height: 52.3 * vu),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < societies.length; i++) ...[
              if (i > 0) SizedBox(width: 62 * u),
              _enter(
                _entranceAt(1.16 + i * 0.06, 0.55, Brand.easeSoft),
                dy: 6 * vu,
                child: SizedBox(
                  width: societies[i].$2 * u,
                  height: 22 * u,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: Text(
                      societies[i].$1,
                      maxLines: 1,
                      style: AppType.inter(
                        15.7 * u,
                        weight: 500,
                        color: Colors.white,
                        letterSpacing: -0.01 * 15.7 * u,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // --- Tablet and compact -------------------------------------------------

  Widget _buildResponsive(BuildContext context, _LayoutMode mode) {
    final size = MediaQuery.sizeOf(context);
    final compact = mode == _LayoutMode.compact;
    const u = 1.0;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: compact
            ? math.max(18, topInset)
            : math.max(24, 3.4 * size.height / 100),
        left: compact
            ? math.max(
                math.max(18, 5.2 * size.width / 100),
                MediaQuery.paddingOf(context).left,
              )
            : (4.2 * size.width / 100).clamp(28, 60).toDouble(),
        right: compact
            ? math.max(
                math.max(18, 5.2 * size.width / 100),
                MediaQuery.paddingOf(context).right,
              )
            : (4.2 * size.width / 100).clamp(28, 60).toDouble(),
        bottom: compact
            ? math.max(20, bottomInset)
            : (4.4 * size.height / 100).clamp(26, 56).toDouble(),
      ),
      child: Column(
        children: [
          _buildResponsiveNav(context, compact, u),
          if (_sheetOpen) _buildSheet(context),
          Expanded(
            child: _messages.isEmpty
                ? _buildResponsiveHero(context, mode, u)
                : _buildResponsiveThread(context, mode, u),
          ),
          SizedBox(height: compact ? 18 : 24),
          _buildProof(context, u, size.height / 1008),
        ],
      ),
    );
  }

  /// The compact menu panel, opened by the burger.
  Widget _buildSheet(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final link in const ['Feed', 'Events', 'Clubs', 'Docs'])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  link,
                  style: AppType.inter(15, color: Colors.white),
                ),
              ),
            ),
          const Divider(color: Color(0x14FFFFFF), height: 18),
          SizedBox(
            height: 40,
            child: _headerCta('Post an event', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveNav(
    BuildContext context,
    bool compact,
    double u,
  ) {
    return SizedBox(
          height: 56,
          child: GlassNavBar(
            dark: true,
            brand: 'CampHere',
            links: campLinks,
            linkRoutes: campRoutes,
            statusDot: true,
            trailing: compact
                ? _BurgerButton(
                    open: _sheetOpen,
                    onTap: () => setState(() => _sheetOpen = !_sheetOpen),
                  )
                : _headerCta('Post an event', 1),
          ),
        )
        .animate(delay: 80.ms)
        .fadeIn(duration: 520.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: -0.3,
          end: 0,
          duration: 520.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildResponsiveHero(
    BuildContext context,
    _LayoutMode mode,
    double u,
  ) {
    final compact = mode == _LayoutMode.compact;
    final size = MediaQuery.sizeOf(context);
    final headlineSize = compact
        ? (29 + size.width * 0.046).clamp(29, 50).toDouble()
        : (27 + size.width * 0.0169).clamp(27, 44).toDouble();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ask what’s on. We’ll find it.',
          textAlign: TextAlign.center,
          style: AppType.inter(
            headlineSize,
            weight: 410,
            color: Colors.white,
            letterSpacing: compact
                ? -0.012 * headlineSize
                : 0.0018 * headlineSize,
            height: compact ? 1.14 : 1.12,
            opsz: 32,
          ),
        ),
        SizedBox(height: compact ? 22 : 28),
        _ComposerCard(
          u: 1,
          mode: mode,
          controller: _input,
          focusNode: _inputFocus,
          onSend: _send,
        ),
      ],
    );
  }

  Widget _buildResponsiveThread(
    BuildContext context,
    _LayoutMode mode,
    double u,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _thread,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _messages.length) {
                return const _TypingLine(u: 1, vu: 1);
              }
              return _MessageBlock(message: _messages[index], u: 1, vu: 1);
            },
          ),
        ),
        _ComposerCard(
          u: 1,
          mode: mode,
          controller: _input,
          focusNode: _inputFocus,
          onSend: _send,
        ),
      ],
    );
  }

  // --- Entrance helpers ---------------------------------------------------

  Animation<double> _entranceAt(
    double start,
    double duration,
    Curve curve,
  ) {
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
    double dy = 0,
    double blur = 0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        final widget = Transform.translate(
          offset: Offset(0, dy * (1 - t)),
          child: child,
        );
        if (blur <= 0) {
          return Opacity(opacity: t.clamp(0, 1), child: widget);
        }
        return Opacity(
          opacity: t.clamp(0, 1),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blur * (1 - t),
              sigmaY: blur * (1 - t),
            ),
            child: widget,
          ),
        );
      },
    );
  }
}

enum _LayoutMode { desktop, tablet, compact }

class _ChatMessage {
  const _ChatMessage.user(this.text) : reply = null, isUser = true;

  const _ChatMessage.assistant(this.reply) : text = '', isUser = false;

  final String text;
  final ChatReply? reply;
  final bool isUser;
}

/// The glass composer card.
///
/// On the desktop canvas the card keeps the measured reference layout: the
/// placeholder sits in its own band near the top, the chips fill a 30u strip
/// near the bottom, and the model label, paperclip and send circle are placed
/// at fixed offsets inside that strip. The send circle is taller than the
/// chips and deliberately overhangs the strip.
class _ComposerCard extends StatefulWidget {
  const _ComposerCard({
    required this.u,
    required this.mode,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final double u;
  final _LayoutMode mode;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String?> onSend;

  @override
  State<_ComposerCard> createState() => _ComposerCardState();
}

class _ComposerCardState extends State<_ComposerCard> {
  static const List<_ChipSpec> _chips = [
    _ChipSpec(
      label: 'Near me',
      width: 107,
      padding: 12,
      gap: 3.7,
      icon: Icons.place_rounded,
    ),
    _ChipSpec(
      label: 'Tonight',
      width: 108,
      padding: 16,
      gap: 3.9,
      icon: Icons.nightlight_round,
    ),
    _ChipSpec(
      label: 'Free food',
      width: 107,
      padding: 15.8,
      gap: 2.9,
      icon: Icons.local_dining_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case _LayoutMode.desktop:
        return _desktopCard(context);
      case _LayoutMode.tablet:
        return _fluidCard(context, tablet: true);
      case _LayoutMode.compact:
        return _fluidCard(context, tablet: false);
    }
  }

  Widget _desktopCard(BuildContext context) {
    final u = widget.u;

    return Container(
      width: 708 * u,
      height: 143 * u,
      margin: EdgeInsets.only(right: 3 * u),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF29292B).withValues(alpha: 0.955),
        borderRadius: BorderRadius.circular(26 * u),
        border: Border.all(color: const Color(0x24D6E4FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 60 * u,
            offset: Offset(0, 22 * u),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26 * u, sigmaY: 26 * u),
        child: Stack(
          children: [
            // A hairline of light along the top edge of the glass.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 2 * u,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Placeholder band — near the top of the card.
            Positioned(
              left: 27 * u,
              top: 33 * u,
              right: 24 * u,
              child: _inputField(context, 9.97 * u, u),
            ),

            // Chip row — 30u tall, near the bottom of the card.
            Positioned(
              left: 19 * u,
              top: 92 * u,
              height: 30 * u,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final chip in _chips) ...[
                    _chip(chip, u),
                    if (chip != _chips.last) SizedBox(width: 5.5 * u),
                  ],
                ],
              ),
            ),

            // The right cluster: measured offsets, not a centred flex row.
            Positioned(
              left: 529.2 * u,
              top: 92 * u + 15.5 * u,
              child: _modelLabel(u),
            ),
            Positioned(
              left: 618.15 * u,
              top: 92 * u + 10.14 * u,
              child: _attachButton(u),
            ),
            Positioned(
              left: 659 * u,
              top: 92 * u + 2 * u,
              child: _sendButton(u),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fluidCard(BuildContext context, {required bool tablet}) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = tablet
        ? math
              .min(
                width * 0.9,
                (516 + 244 * (width / 1180)).clamp(516, 760).toDouble(),
              )
              .toDouble()
        : math.min(width, 600).toDouble();
    final padding = tablet
        ? (15 + width * 0.008).clamp(15, 24).toDouble()
        : (13 + width * 0.009).clamp(13, 18).toDouble();
    final radius = tablet
        ? (17 + width * 0.007).clamp(17, 26).toDouble()
        : 18.0;
    final gap = tablet
        ? (20 + MediaQuery.sizeOf(context).height * 0.014)
              .clamp(20, 44)
              .toDouble()
        : 18.0;
    final chipHeight = tablet
        ? (29 + MediaQuery.sizeOf(context).height * 0.002)
              .clamp(29, 34)
              .toDouble()
        : 32.0;
    final chipFont = tablet
        ? (9.6 + width * 0.0014).clamp(9.6, 12.5).toDouble()
        : 11.0;
    final modelFont = tablet
        ? (9.8 + width * 0.0014).clamp(9.8, 12.5).toDouble()
        : 11.0;
    final inputFont = tablet
        ? (11 + width * 0.0025).clamp(11, 14).toDouble()
        : (9.4 + width * 0.0107).clamp(9.4, 14).toDouble();

    return Container(
      width: cardWidth,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF29292B).withValues(alpha: 0.955),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0x24D6E4FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 50,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _inputField(context, inputFont, 1, singleLine: true),
              SizedBox(height: gap),
              if (tablet)
                Row(
                  children: [
                    Flexible(child: _chipRow(chipHeight, chipFont, 1)),
                    const SizedBox(width: 10),
                    _modelLabel(1, fontSize: modelFont),
                    SizedBox(
                      width: (9 + width * 0.005).clamp(9, 20).toDouble(),
                    ),
                    _attachButton(1),
                    SizedBox(
                      width: (9 + width * 0.004).clamp(9, 18).toDouble(),
                    ),
                    _sendButton(
                      1,
                      diameter: (32 + width * 0.005).clamp(32, 38),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _chipRow(chipHeight, chipFont, 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _modelLabel(1, fontSize: modelFont),
                        const Spacer(),
                        _attachButton(1),
                        const SizedBox(width: 14),
                        _sendButton(1, diameter: 40),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipRow(double height, double fontSize, double u) {
    return Wrap(
      spacing: 5.5,
      runSpacing: 8,
      children: [
        for (final chip in _chips)
          _chip(chip, u, height: height, fontSize: fontSize),
      ],
    );
  }

  Widget _chip(
    _ChipSpec chip,
    double u, {
    double? height,
    double? fontSize,
  }) {
    final h = height ?? 30 * u;
    final fs = fontSize ?? 9.0 * u;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.controller.text = _chipQuery(chip.label);
          widget.onSend(_chipQuery(chip.label));
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: chip.padding * u),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9 * u),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.088),
                Colors.white.withValues(alpha: 0.050),
                Colors.white.withValues(alpha: 0.038),
              ],
              stops: const [0, 0.45, 1],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(chip.icon, size: 11.5 * u, color: const Color(0xFF909093)),
              SizedBox(width: chip.gap * u),
              Transform.translate(
                offset: Offset(0, 2 * u),
                child: Text(
                  chip.label,
                  style: AppType.inter(
                    fs,
                    weight: 500,
                    color: const Color(0xFF909093),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _chipQuery(String label) => switch (label) {
    'Near me' => 'What is on near me this week?',
    'Tonight' => 'What is on tonight?',
    'Free food' => 'Anything with free food?',
    _ => label,
  };

  Widget _inputField(
    BuildContext context,
    double fontSize,
    double u, {
    bool singleLine = false,
  }) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onSubmitted: (_) => widget.onSend(null),
      maxLines: singleLine ? 1 : 3,
      minLines: 1,
      cursorColor: Brand.emberLight,
      style: AppType.inter(
        fontSize,
        color: const Color(0xFFE8E8EA),
        letterSpacing: 0.007 * fontSize,
        height: 1.35,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText:
            'Ask for a lecture tonight, a free meal, or anything with a '
            'projector...',
        hintStyle: AppType.inter(
          fontSize,
          color: const Color(0xFF8B8C8E),
          letterSpacing: 0.007 * fontSize,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _modelLabel(double u, {double? fontSize}) {
    final fs = fontSize ?? 10.4 * u;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Guide 4.5',
              style: AppType.inter(
                fs,
                color: const Color(0xFF98999C),
                height: 1,
              ),
            ),
            SizedBox(width: 6.2 * u),
            SizedBox(
              width: 6.8 * u,
              height: 4 * u,
              child: CustomPaint(painter: _ChevronPainter()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachButton(double u) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 19.79 * u,
          height: 19.79 * u,
          child: Icon(
            Icons.attach_file_rounded,
            size: 19.79 * u,
            color: const Color(0xFFA9AAAD),
          ),
        ),
      ),
    );
  }

  Widget _sendButton(double u, {double? diameter}) {
    final d = diameter ?? 35 * u;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onSend(null),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: d,
          height: d,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFBBC94),
                Color(0xFFF49D70),
                Color(0xFFE88654),
              ],
              stops: [0, 0.46, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x57D26E3C),
                blurRadius: 12 * u,
                offset: Offset(0, 3 * u),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            size: 11.66 * u,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// A chip definition for the composer toolbar.
class _ChipSpec {
  const _ChipSpec({
    required this.label,
    required this.width,
    required this.padding,
    required this.gap,
    required this.icon,
  });

  final String label;
  final double width;
  final double padding;
  final double gap;
  final IconData icon;
}

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF98999C);

    final path = Path()
      ..moveTo(0, size.height * 0.28)
      ..lineTo(size.width / 2, size.height * 0.78)
      ..lineTo(size.width, size.height * 0.28);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => false;
}

class _BurgerButton extends StatelessWidget {
  const _BurgerButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: Colors.white.withValues(alpha: 0.10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 17,
                height: 1.6,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 3.4),
              ),
              Container(width: 17, height: 1.6, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.message,
    required this.u,
    required this.vu,
  });

  final _ChatMessage message;
  final double u;
  final double vu;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.fromLTRB(40 * u, 6 * u, 0, 6 * u),
              padding: EdgeInsets.symmetric(
                horizontal: 14 * u,
                vertical: 10 * u,
              ),
              decoration: BoxDecoration(
                color: Brand.ember.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16 * u),
              ),
              child: Text(
                message.text,
                style: AppType.inter(
                  14 * u,
                  weight: 400,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
          .slideY(
            begin: 0.14,
            end: 0,
            duration: 340.ms,
            curve: Curves.easeOutCubic,
          );
    }

    final reply = message.reply!;
    return Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10 * u, 40 * u, 8 * u),
                child: Text(
                  reply.text,
                  style: AppType.inter(
                    14.5 * u,
                    weight: 400,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.45,
                  ),
                ),
              ),
              if (reply.actions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 10 * u),
                  child: Wrap(
                    spacing: 8 * u,
                    runSpacing: 8 * u,
                    children: [
                      for (final action in reply.actions)
                        _ActionChip(
                          label: action.label,
                          route: action.route,
                          u: u,
                        ),
                    ],
                  ),
                ),
              for (var i = 0; i < reply.events.length; i++)
                _EventCard(summary: reply.events[i], u: u)
                    .animate(delay: (220 + i * 90).ms)
                    .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
                    .slideY(
                      begin: 0.12,
                      end: 0,
                      duration: 360.ms,
                      curve: Curves.easeOutCubic,
                    ),
            ],
          ),
        )
        .animate(delay: 140.ms)
        .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// A follow-up action offered with an answer, e.g. opening the board.
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.route,
    required this.u,
  });

  final String label;
  final String route;
  final double u;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child:
          GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(route),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 32 * u,
                  padding: EdgeInsets.symmetric(horizontal: 13 * u),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Brand.ember.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Brand.ember.withValues(alpha: 0.38),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppType.inter(
                          12 * u,
                          weight: 500,
                          color: Brand.emberLight,
                        ),
                      ),
                      SizedBox(width: 5 * u),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 12 * u,
                        color: Brand.emberLight,
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 260.ms, curve: Curves.easeOutCubic)
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.summary, required this.u});

  final EventSummary summary;
  final double u;

  @override
  Widget build(BuildContext context) {
    final event = summary.event;

    return Container(
      width: 420 * u,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 8 * u),
      padding: EdgeInsets.all(14 * u),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16 * u),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 7 * u,
                  vertical: 3 * u,
                ),
                decoration: BoxDecoration(
                  color: Brand.ember.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  event.category.label,
                  style: AppType.inter(
                    10.5 * u,
                    weight: 500,
                    color: Brand.emberLight,
                    letterSpacing: 0.02 * 10.5 * u,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formatEventWhen(event),
                style: AppType.inter(
                  11.5 * u,
                  weight: 400,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * u),
          Text(
            event.title,
            style: AppType.inter(
              16 * u,
              weight: 500,
              color: Colors.white,
              letterSpacing: -0.01 * 16 * u,
              height: 1.25,
            ),
          ),
          SizedBox(height: 4 * u),
          Text(
            '${event.location} · ${event.organizer}',
            style: AppType.inter(
              12.5 * u,
              weight: 400,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          SizedBox(height: 10 * u),
          Row(
            children: [
              _Stat(
                icon: Icons.people_alt_rounded,
                label: '${summary.goingCount} going',
                u: u,
              ),
              SizedBox(width: 16 * u),
              _Stat(
                icon: Icons.bookmark_border_rounded,
                label: '${summary.interestedCount} interested',
                u: u,
              ),
              if (event.capacity != null) ...[
                SizedBox(width: 16 * u),
                _Stat(
                  icon: Icons.event_seat_rounded,
                  label: '${event.capacity} seats',
                  u: u,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.u});

  final IconData icon;
  final String label;
  final double u;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13 * u, color: Colors.white.withValues(alpha: 0.55)),
        SizedBox(width: 5 * u),
        Text(
          label,
          style: AppType.inter(
            11.5 * u,
            weight: 400,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}

class _TypingLine extends StatelessWidget {
  const _TypingLine({required this.u, required this.vu});

  final double u;
  final double vu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8 * u, 0, 8 * u),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16 * u,
            height: 16 * u,
            child: CircularProgressIndicator(
              strokeWidth: 1.6 * u,
              color: Brand.emberLight.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(width: 10 * u),
          Text(
            'Campus guide is reading the feed',
            style: AppType.inter(
              13 * u,
              weight: 400,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
