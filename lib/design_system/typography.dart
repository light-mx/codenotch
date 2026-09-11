import 'package:flutter/material.dart';
import 'design.dart';

/// Sizes are derived from cap heights measured in the design frame, so they
/// track `Design.scale` along with everything else.
abstract final class Typography {
  /// The percent under each provider ring. Cap height 27px in the frame.
  static TextStyle get percent => TextStyle(
        fontSize: Design.fontSize(capPixels: 27),
        fontWeight: FontWeight.w600,
        fontFamily: '.AppleSystemUIFont',
        letterSpacing: -0.2,
      );

  /// "Claude Usage". Cap height 26px.
  static TextStyle get cardTitle => TextStyle(
        fontSize: Design.fontSize(capPixels: 26),
        fontWeight: FontWeight.w600,
        fontFamily: '.AppleSystemUIFont',
        letterSpacing: -0.2,
      );

  /// "Current session", "73% Used", "Resets in 51 min". Cap height 18px.
  static TextStyle get cardBody => TextStyle(
        fontSize: Design.fontSize(capPixels: 18),
        fontWeight: FontWeight.w400,
        fontFamily: '.AppleSystemUIFont',
        letterSpacing: -0.1,
      );
}
