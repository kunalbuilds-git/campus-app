import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A static film-grain layer that keeps large flat washes from banding.
///
/// The speckle pattern is seeded, so it stays fixed while the page moves
/// instead of shimmering like television static.
class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, this.opacity = 0.13, this.density = 1});

  final double opacity;
  final double density;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GrainPainter(opacity: opacity, density: density),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter({required this.opacity, required this.density});

  final double opacity;
  final double density;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final random = math.Random(20261026);
    final count = (size.width * size.height / 620 * density)
        .clamp(400, 6000)
        .toInt();

    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final dark = random.nextDouble() < 0.62;
      final strength = random.nextDouble() * 0.5 + 0.12;
      paint.color = (dark ? Colors.black : Colors.white).withValues(
        alpha: strength * opacity,
      );
      final dot = random.nextDouble() < 0.25 ? 1.4 : 0.9;
      canvas.drawRect(Rect.fromLTWH(dx, dy, dot, dot), paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.density != density;
}
