import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/palette.dart';
import '../notch/notch_edge.dart';
import '../notch/notch_layout.dart';

class SettingsOrbPainter extends CustomPainter {
  final NotchEdge edge;
  final bool convex;
  final double arcRadius;

  const SettingsOrbPainter({
    required this.edge,
    this.convex = false,
    required this.arcRadius,
  });

  (double start, double sweep) get angles {
    double startFraction;
    switch (edge) {
      case NotchEdge.right:
        startFraction = 0.75;
        break;
      case NotchEdge.left:
      case NotchEdge.top:
        startFraction = 0.5;
        break;
      case NotchEdge.bottom:
        startFraction = 0.25;
        break;
    }
    if (convex) {
      startFraction = (startFraction + 0.5) % 1.0;
    }
    // 0 in Flutter arc is 3 o'clock. 0.25 is 6 o'clock.
    final startAngle = startFraction * 2 * math.pi;
    const sweepAngle = 0.25 * 2 * math.pi; // quarter circle
    return (startAngle, sweepAngle);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final (startAngle, sweepAngle) = angles;

    final paint = Paint()
      ..color = Palette.notch
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NotchLayout.orbStroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SettingsOrbPainter oldDelegate) =>
      oldDelegate.edge != edge ||
      oldDelegate.convex != convex ||
      oldDelegate.arcRadius != arcRadius;
}

class SettingsOrb extends StatelessWidget {
  final bool isHovered;
  final NotchEdge edge;
  final bool convex;
  final double? arcRadius;
  final Offset arcOffset;

  const SettingsOrb({
    super.key,
    required this.isHovered,
    this.edge = NotchEdge.right,
    this.convex = false,
    this.arcRadius,
    this.arcOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = arcRadius ?? NotchLayout.orbArcRadius;
    final double frameSize = radius * 2 + NotchLayout.orbStroke;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Resting arc
          Transform.translate(
            offset: arcOffset,
            child: AnimatedScale(
              scale: isHovered ? 0.86 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: isHovered ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: CustomPaint(
                  size: Size(radius * 2, radius * 2),
                  painter: SettingsOrbPainter(
                    edge: edge,
                    convex: convex,
                    arcRadius: radius,
                  ),
                ),
              ),
            ),
          ),

          // Hover filled circle
          AnimatedScale(
            scale: isHovered ? 1.0 : 1.1,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: isHovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: NotchLayout.orbDiameter,
                height: NotchLayout.orbDiameter,
                decoration: const BoxDecoration(
                  color: Palette.notch,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Gear icon
          AnimatedRotation(
            turns: isHovered ? 0.0 : -60.0 / 360.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedScale(
              scale: isHovered ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.settings,
                  size: NotchLayout.orbGlyph,
                  color: Palette.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
