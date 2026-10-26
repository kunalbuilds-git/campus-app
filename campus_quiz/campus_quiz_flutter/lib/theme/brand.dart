import 'package:flutter/material.dart';

/// Brand tokens shared by the three surfaces of the app.
///
/// The app pairs a warm editorial paper tone (landing) with a deep night
/// palette (feed, profile) and a single ember accent that ties them together.
class Brand {
  const Brand._();

  // Editorial landing surface.
  static const paper = Color(0xFFF2F0EC);
  static const ink = Color(0xFF0D0C0B);

  // Night surfaces (feed + profile).
  static const night = Color(0xFF0A0D12);
  static const glassDark = Color(0xFF29292B);
  static const glassLine = Color(0x1AD6E4FF);

  // Accent.
  static const ember = Color(0xFFE8632A);
  static const emberMid = Color(0xFFF49D70);
  static const emberLight = Color(0xFFFBBC94);

  // Type.
  static const text = 'Inter';
  static const display = 'Inter Tight';

  // Motion.
  static const easePrimary = Cubic(0.16, 1, 0.3, 1);
  static const easeSoft = Cubic(0.22, 1, 0.36, 1);
  static const easePen = Cubic(0.37, 0.01, 0.2, 1);
}

/// Text styles built on the bundled variable fonts.
///
/// [Inter] is a variable font with a `wght` axis (100–900) and an `opsz` axis
/// (14–32), so display roles can request optical sizes and the fractional
/// weights the designs call for instead of snapping to 400/500.
class AppType {
  const AppType._();

  static List<FontVariation> _axes(double weight, double? opsz) => [
    FontVariation('wght', weight),
    if (opsz != null) FontVariation('opsz', opsz),
  ];

  static TextStyle inter(
    double size, {
    double weight = 400,
    Color? color,
    double? letterSpacing,
    double? height,
    double? opsz,
  }) {
    return TextStyle(
      fontFamily: Brand.text,
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: _axes(weight, opsz),
    );
  }

  static TextStyle tight(
    double size, {
    double weight = 400,
    Color? color,
    double? letterSpacing,
    double? height,
    double? opsz,
  }) {
    return TextStyle(
      fontFamily: Brand.display,
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: _axes(weight, opsz),
    );
  }
}
