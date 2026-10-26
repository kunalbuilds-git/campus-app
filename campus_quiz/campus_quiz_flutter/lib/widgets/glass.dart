import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/brand.dart';

/// A frosted glass panel.
///
/// The recipe is deliberately translucent — a vertical white gradient over a
/// blurred, saturated backdrop — so whatever sits behind the panel stays
/// visible through it. A single specular sweep runs across the surface once,
/// shortly after the panel appears.
class GlassSurface extends StatefulWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding = EdgeInsets.zero,
    this.blur = 26,
    this.saturation = 118,
    this.tint = const Color(0x33FFFFFF),
    this.tintTop = const Color(0x33FFFFFF),
    this.border,
    this.sheen = true,
    this.sheenDelay = const Duration(milliseconds: 2550),
    this.sheenDuration = const Duration(milliseconds: 1150),
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double saturation;
  final Color tint;
  final Color tintTop;
  final Color? border;
  final bool sheen;
  final Duration sheenDelay;
  final Duration sheenDuration;

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheenController = AnimationController(
    vsync: this,
    duration: widget.sheenDuration,
  );

  Timer? _sheenTimer;

  @override
  void initState() {
    super.initState();
    if (widget.sheen) {
      _sheenTimer = Timer(widget.sheenDelay, () {
        if (mounted) _sheenController.forward();
      });
    }
  }

  @override
  void dispose() {
    _sheenTimer?.cancel();
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
          tileMode: TileMode.decal,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.tintTop,
                widget.tint,
              ],
            ),
            borderRadius: BorderRadius.circular(widget.radius),
            border: widget.border == null
                ? null
                : Border.all(color: widget.border!, width: 1),
          ),
          padding: widget.padding,
          child: Stack(
            children: [
              widget.child,
              if (widget.sheen) _buildSheen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheen() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _sheenController,
          builder: (context, child) {
            final t = Curves.easeOut.transform(_sheenController.value);
            return Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..translateByDouble(-1.5 + 4.1 * t, 0, 0, 1)
                ..setEntry(3, 2, 0.001)
                ..rotateZ(0),
              child: child,
            );
          },
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.38,
            child: Transform(
              transform: Matrix4.skewX(-0.314),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.17),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small circular glass button, used by the header tool clusters.
class GlassToolButton extends StatefulWidget {
  const GlassToolButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 52,
    this.iconSize = 20,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  State<GlassToolButton> createState() => _GlassToolButtonState();
}

class _GlassToolButtonState extends State<GlassToolButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Brand.easeSoft,
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: _hovered ? 0.24 : 0.15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(widget.icon, size: widget.iconSize, color: Colors.white),
        ),
      ),
    );

    if (widget.tooltip == null) return button;
    return Tooltip(message: widget.tooltip!, child: button);
  }
}
