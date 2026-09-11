import 'package:flutter/material.dart';

/// Sampled from `docs/design/frame-124-hover-tooltip.png`, not invented.
///
/// Note these differ slightly from the hexes written in the design spec — the
/// frame is the source of truth, so the sampled values win.
abstract final class Palette {
  static const Color notch = Color(0xFF000000);
  static const Color card = Color(0xFF000000);
  static const Color ringTrack = Color(0xFF303030);
  static const Color barTrack = Color(0xFF2D2D2D);

  static const Color ample = Color(0xFF00FF88); // green
  static const Color watch = Color(0xFFF2FF00); // yellow
  static const Color critical = Color(0xFFFF3F00); // orange

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF808080);
}
