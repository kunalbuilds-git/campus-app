import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/brand.dart';

/// The four-pointed spark that marks the app.
///
/// The same glyph appears in the landing header, the feed navigation and the
/// profile rail, so the three surfaces read as one product.
class BrandSpark extends StatelessWidget {
  const BrandSpark({
    super.key,
    this.size = 16,
    this.color = const Color(0xFF0D0C0B),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparkPainter(color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2;
    final waist = r * 0.19;

    final path = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx + waist, cy - waist, cx + r, cy)
      ..quadraticBezierTo(cx + waist, cy + waist, cx, cy + r)
      ..quadraticBezierTo(cx - waist, cy + waist, cx - r, cy)
      ..quadraticBezierTo(cx - waist, cy - waist, cx, cy - r)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) => oldDelegate.color != color;
}

/// The app logo: three concentric rings.
///
/// It is the mark used in every navigation surface, so the landing page, the
/// feed and the profile rail all carry the same identity.
class TargetMark extends StatelessWidget {
  const TargetMark({
    super.key,
    this.size = 34,
    this.outer = Brand.ember,
    this.middle = Colors.white,
    this.core = const Color(0xFF151519),
  });

  final double size;
  final Color outer;
  final Color middle;
  final Color core;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TargetPainter(outer: outer, middle: middle, core: core),
      ),
    );
  }
}

class _TargetPainter extends CustomPainter {
  const _TargetPainter({
    required this.outer,
    required this.middle,
    required this.core,
  });

  final Color outer;
  final Color middle;
  final Color core;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(centre, r, Paint()..color = outer);
    canvas.drawCircle(centre, r * 0.506, Paint()..color = middle);
    canvas.drawCircle(centre, r * 0.218, Paint()..color = core);
  }

  @override
  bool shouldRepaint(_TargetPainter oldDelegate) =>
      oldDelegate.outer != outer ||
      oldDelegate.middle != middle ||
      oldDelegate.core != core;
}

/// The app logo: the spark inside a rounded square.
class QuadLogo extends StatelessWidget {
  const QuadLogo({
    super.key,
    this.size = 40,
    this.color = Colors.white,
    this.strokeWidth = 1.6,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _QuadLogoPainter(color, strokeWidth)),
    );
  }
}

class _QuadLogoPainter extends CustomPainter {
  const _QuadLogoPainter(this.color, this.strokeWidth);

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.3),
    );

    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = color.withValues(alpha: 0.9),
    );

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.24;
    final waist = r * 0.19;

    final path = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx + waist, cy - waist, cx + r, cy)
      ..quadraticBezierTo(cx + waist, cy + waist, cx, cy + r)
      ..quadraticBezierTo(cx - waist, cy + waist, cx - r, cy)
      ..quadraticBezierTo(cx - waist, cy - waist, cx, cy - r)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_QuadLogoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
