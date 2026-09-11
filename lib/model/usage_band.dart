import 'package:flutter/material.dart';
import '../design_system/palette.dart';

/// The colour a ring or bar takes at a given level of use.
///
/// The thresholds come from the mockup, which shows 21% green, 52% yellow and
/// 73% orange. (The prose table in the design spec says 50–79 is yellow, which
/// would make 73% yellow and contradict the frame it claims to describe — the
/// frame wins.)
enum UsageBand {
  ample, // under half (< 0.50)
  watch, // getting close (< 0.70)
  critical, // nearly out (< 1.00)
  exhausted; // limit hit, waiting for reset (>= 1.00)

  static UsageBand bandFor(double usedFraction) {
    if (usedFraction < 0.50) return UsageBand.ample;
    if (usedFraction < 0.70) return UsageBand.watch;
    if (usedFraction < 1.00) return UsageBand.critical;
    return UsageBand.exhausted;
  }

  Color get color {
    switch (this) {
      case UsageBand.ample:
        return Palette.ample;
      case UsageBand.watch:
        return Palette.watch;
      case UsageBand.critical:
      case UsageBand.exhausted:
        return Palette.critical;
    }
  }
}
