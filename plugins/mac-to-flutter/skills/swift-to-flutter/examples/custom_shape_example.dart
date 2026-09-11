import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Example showing how a SwiftUI Shape with inverse corner flares
/// translates into a Flutter CustomPainter & CustomClipper.
class NotchedCardPainter extends CustomPainter {
  final double cornerRadius;
  final double flareRadius;
  final Color color;

  const NotchedCardPainter({
    this.cornerRadius = 16.0,
    this.flareRadius = 24.0,
    this.color = Colors.black,
  });

  Path createPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at top right screen edge
    path.moveTo(w, 0);

    // Flare inward and down
    path.arcToPoint(
      Offset(w - flareRadius, flareRadius),
      radius: Radius.circular(flareRadius),
      clockwise: false,
    );

    // Along the top edge to left corner
    path.lineTo(cornerRadius, flareRadius);
    path.arcToPoint(
      Offset(0, flareRadius + cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Down the body to bottom corner
    path.lineTo(0, h - flareRadius - cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, h - flareRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Flare back out to screen edge
    path.lineTo(w - flareRadius, h - flareRadius);
    path.arcToPoint(
      Offset(w, h),
      radius: Radius.circular(flareRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(createPath(size), paint);
  }

  @override
  bool shouldRepaint(covariant NotchedCardPainter oldDelegate) =>
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.flareRadius != flareRadius ||
      oldDelegate.color != color;
}
