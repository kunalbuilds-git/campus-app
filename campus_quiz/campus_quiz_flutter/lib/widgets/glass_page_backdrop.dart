import 'package:flutter/material.dart';

/// The shared backdrop of the dark glass surfaces: the campus photograph with
/// a vignette that keeps the left edge quiet for reading.
class GlassPageBackdrop extends StatelessWidget {
  const GlassPageBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: ColoredBox(
                color: const Color(0xFF041018).withValues(alpha: 0.07),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
