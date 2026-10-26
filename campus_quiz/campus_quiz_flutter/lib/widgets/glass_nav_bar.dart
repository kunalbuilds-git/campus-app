import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/brand.dart';
import 'brand_mark.dart';

/// The floating liquid-glass head bar shared by the landing page and the
/// event finder.
///
/// A frosted pill — backdrop blur, a faint tint gradient and a hairline
/// border — that hovers over whatever is playing behind it. On dark surfaces
/// it can carry a small pulse dot to show the campus guide is live.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.dark,
    required this.brand,
    required this.links,
    required this.trailing,
    this.linkRoutes = const [],
    this.statusDot = false,
    this.height = 56,
  });

  final bool dark;
  final String brand;
  final List<String> links;

  /// Push routes for [links]; a link without a route is inert.
  final List<String> linkRoutes;

  /// The control on the right edge: a call to action, or the burger on
  /// compact screens.
  final Widget trailing;

  final bool statusDot;
  final double height;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : Brand.ink;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.055),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.62),
                      Colors.white.withValues(alpha: 0.38),
                    ],
            ),
            border: Border.all(
              color: (dark ? Colors.white : Colors.black).withValues(
                alpha: dark ? 0.14 : 0.08,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // The links only appear when there is genuinely room for them:
                // the brand sits on the left, the control on the right, and
                // the links claim what is left in the middle.
                final gap = constraints.maxWidth > 1360
                    ? 26.0
                    : constraints.maxWidth > 1180
                    ? 20.0
                    : 15.0;
                final linksWidth =
                    links.fold<double>(
                      0,
                      (sum, label) => sum + label.length * 7.9,
                    ) +
                    gap * (links.length - 1);
                final reserved = 196 /* brand */ + 150 /* trailing */ + 36;
                final showLinks =
                    links.isNotEmpty &&
                    constraints.maxWidth > 640 &&
                    linksWidth + reserved <= constraints.maxWidth;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TargetMark(size: 30, outer: Brand.ember),
                        const SizedBox(width: 10),
                        Text(
                          brand,
                          style: AppType.inter(
                            16.5,
                            weight: 500,
                            color: foreground,
                            letterSpacing: -0.0154 * 16.5,
                          ),
                        ),
                        if (statusDot) ...[
                          const SizedBox(width: 9),
                          _PulseDot().animate(onPlay: (c) => c.repeat()),
                        ],
                      ],
                    ),
                    if (showLinks)
                      Positioned(
                        left: 0,
                        right: 96,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < links.length; i++) ...[
                                if (i > 0) SizedBox(width: gap),
                                _NavLink(
                                  label: links[i],
                                  color: foreground,
                                  route: i < linkRoutes.length
                                      ? linkRoutes[i]
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      right: 0,
                      child: trailing,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.color, this.route});

  final String label;
  final Color color;
  final String? route;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.route == null
            ? null
            : () => Navigator.of(context).pushNamed(widget.route!),
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _hovered ? 1 : 0.86,
          child: Text(
            widget.label,
            style: AppType.inter(
              14.5,
              color: widget.color,
              letterSpacing: -0.0115 * 14.5,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// The live dot: an ember core with a slow breathing halo.
class _PulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Brand.ember.withValues(alpha: 0.35),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1.5, 1.5),
                duration: 1600.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1600.ms),
          Container(
            width: 5.5,
            height: 5.5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Brand.ember,
            ),
          ),
        ],
      ),
    );
  }
}
