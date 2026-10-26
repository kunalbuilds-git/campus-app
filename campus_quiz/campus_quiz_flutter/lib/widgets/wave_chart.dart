import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/brand.dart';

/// The weekly activity curve.
///
/// The pen draws the line first; the fill then wipes in behind it, roughly a
/// fifth of a second later, so the chart reads as being written rather than
/// appearing all at once.
class WaveChart extends StatefulWidget {
  const WaveChart({
    super.key,
    required this.values,
    this.height = 230,
    this.strokeWidth = 3.4,
    this.visiblePoints,
  });

  final List<double> values;
  final double height;
  final double strokeWidth;

  /// How many points of [values] are drawn. The rest of the week still
  /// claims its space on the axis, so the line stops where the week really
  /// is instead of diving to zero for a day that has not happened yet.
  final int? visiblePoints;

  @override
  State<WaveChart> createState() => _WaveChartState();
}

class _WaveChartState extends State<WaveChart> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  late final Animation<double> _draw = CurvedAnimation(
    parent: _controller,
    curve: const Interval(1500 / 3200, 3100 / 3200, curve: Brand.easePen),
  );

  late final Animation<double> _fill = CurvedAnimation(
    parent: _controller,
    curve: const Interval(1720 / 3200, 3140 / 3200, curve: Brand.easePen),
  );

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _WavePainter(
              values: widget.values,
              visiblePoints: widget.visiblePoints,
              draw: _draw.value,
              fill: _fill.value,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.values,
    required this.draw,
    required this.fill,
    required this.strokeWidth,
    this.visiblePoints,
  });

  final List<double> values;
  final int? visiblePoints;
  final double draw;
  final double fill;
  final double strokeWidth;

  // The reference canvas for the curve.
  static const double _w = 835;
  static const double _h = 230;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.isEmpty) return;

    final scaleX = size.width / _w;
    final scaleY = size.height / _h;

    final path = _buildPath(scaleX, scaleY);
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Fill: a vertical wash that fades out towards the bottom of the chart.
    if (fill > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * fill, size.height));
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.07),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(Offset.zero & size),
      );
      canvas.restore();
    }

    if (draw <= 0) return;

    final partial = _partialPath(path, draw);
    final strokeShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.55),
        Colors.white.withValues(alpha: 0.92),
        Colors.white.withValues(alpha: 0.30),
      ],
      stops: const [0, 0.35, 0.7, 1],
    ).createShader(Offset.zero & size);

    // Three passes: a soft halo, a mid glow, and the crisp line itself.
    for (final pass in [
      (width: 6.2, opacity: 0.17),
      (width: 4.6, opacity: 0.26),
      (width: strokeWidth, opacity: 1.0),
    ]) {
      canvas.drawPath(
        partial,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = pass.width * scaleY
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = strokeShader
          ..color = Colors.white.withValues(alpha: pass.opacity)
          ..blendMode = BlendMode.plus,
      );
    }
  }

  Path _buildPath(double scaleX, double scaleY) {
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final span = (maxValue - minValue).abs() < 0.001 ? 1 : maxValue - minValue;

    final visible = visiblePoints ?? values.length;
    final points = <Offset>[];
    for (var i = 0; i < values.length && i < visible; i++) {
      final x = _w * (i / (values.length - 1));
      // Leave headroom at the top and rest the low point near the baseline.
      final normalised = (values[i] - minValue) / span;
      final y = 186 - normalised * 124;
      points.add(Offset(x * scaleX, y * scaleY));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    // Catmull-Rom style smoothing, converted to cubic segments.
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[0] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    return path;
  }

  Path _partialPath(Path source, double fraction) {
    final output = Path();
    for (final metric in source.computeMetrics()) {
      output.addPath(
        metric.extractPath(0, metric.length * fraction.clamp(0, 1)),
        Offset.zero,
      );
    }
    return output;
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.draw != draw ||
      oldDelegate.fill != fill ||
      oldDelegate.values != values ||
      oldDelegate.visiblePoints != visiblePoints ||
      oldDelegate.strokeWidth != strokeWidth;
}
