import 'package:flutter/animation.dart';

abstract final class NotchMotion {
  static const Duration unfoldDuration = Duration(milliseconds: 380);
  static const Curve unfoldCurve = Curves.easeOutCubic;

  static const Duration glideDuration = Duration(milliseconds: 280);
  static const Curve glideCurve = Curves.easeOutQuad;

  static const Duration readingDuration = Duration(milliseconds: 500);
  static const Curve readingCurve = Curves.easeOutCubic;

  static const Duration crossfadeDuration = Duration(milliseconds: 160);
  static const Curve crossfadeCurve = Curves.easeInOut;

  static const Duration mergeDuration = Duration(milliseconds: 160);

  static Duration staggerDelay(int index) {
    return Duration(milliseconds: 40 + index * 20);
  }
}
