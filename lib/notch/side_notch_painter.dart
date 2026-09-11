import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../design_system/palette.dart';
import 'notch_edge.dart';
import 'notch_geometry.dart';
import 'notch_layout.dart';

/// The notch body: a pill welded to one edge of the screen, with inverse
/// rounded corners at each end that flare back out to the edge so it reads as
/// part of the bezel rather than a floating panel.
class SideNotchShape {
  final NotchEdge edge;
  final HardwareNotch? joining;
  final double curlRadius;
  final double cornerRadius;

  SideNotchShape({
    this.edge = NotchEdge.right,
    this.joining,
    double? curlRadius,
    double? cornerRadius,
  })  : curlRadius = curlRadius ?? NotchLayout.curlRadius,
        cornerRadius = cornerRadius ?? NotchLayout.cornerRadius;

  Path createPath(Rect rect) {
    final double depth = edge.isVertical ? rect.width : rect.height;
    final double length = edge.isVertical ? rect.height : rect.width;
    final double flare = joining == null ? curlRadius : NotchLayout.bezelFillet;
    final double cornerCap = joining != null ? joining!.height / 2 : double.infinity;

    final Path canonical = canonicalPath(
      depth: depth,
      length: length,
      flare: flare,
      cornerCap: cornerCap,
    );

    final Matrix4 matrix = transformFor(edge, depth);
    final Path transformed = canonical.transform(matrix.storage);
    return transformed.shift(rect.topLeft);
  }

  static Matrix4 transformFor(NotchEdge edge, double depth) {
    switch (edge) {
      case NotchEdge.right:
        return Matrix4.identity();
      case NotchEdge.left:
        // x' = -x + depth, y' = y
        return Matrix4(
          -1, 0, 0, 0,
          0, 1, 0, 0,
          0, 0, 1, 0,
          depth, 0, 0, 1,
        );
      case NotchEdge.top:
        // x' = y, y' = depth - x
        return Matrix4(
          0, -1, 0, 0,
          1, 0, 0, 0,
          0, 0, 1, 0,
          0, depth, 0, 1,
        );
      case NotchEdge.bottom:
        // x' = y, y' = x
        return Matrix4(
          0, 1, 0, 0,
          1, 0, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1,
        );
    }
  }

  Path canonicalPath({
    required double depth,
    required double length,
    required double flare,
    double cornerCap = double.infinity,
  }) {
    final double wanted = math.max(0.0, math.min(cornerRadius, math.min(cornerCap, depth / 2)));
    final double curl = math.max(0.0, math.min(flare, math.min(length / 2, depth - wanted)));
    final double corner = math.max(0.0, math.min(wanted, (length - 2 * curl) / 2));
    final double bodyTop = curl;
    final double bodyBottom = length - curl;

    final Path path = Path();
    path.moveTo(depth, 0);

    if (curl > 0) {
      path.arcTo(
        Rect.fromCircle(center: Offset(depth - curl, 0), radius: curl),
        0,
        math.pi / 2,
        false,
      );
    }

    path.lineTo(corner, bodyTop);

    path.arcTo(
      Rect.fromCircle(center: Offset(corner, bodyTop + corner), radius: corner),
      -math.pi / 2,
      -math.pi / 2,
      false,
    );

    path.lineTo(0, bodyBottom - corner);

    path.arcTo(
      Rect.fromCircle(center: Offset(corner, bodyBottom - corner), radius: corner),
      math.pi,
      -math.pi / 2,
      false,
    );

    path.lineTo(depth - curl, bodyBottom);

    if (curl > 0) {
      path.arcTo(
        Rect.fromCircle(center: Offset(depth - curl, length), radius: curl),
        -math.pi / 2,
        math.pi / 2,
        false,
      );
    }

    path.close();
    return path;
  }
}

class SideNotchPainter extends CustomPainter {
  final NotchEdge edge;
  final HardwareNotch? joining;
  final Color color;

  const SideNotchPainter({
    this.edge = NotchEdge.right,
    this.joining,
    this.color = Palette.notch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shape = SideNotchShape(edge: edge, joining: joining);
    final path = shape.createPath(Offset.zero & size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SideNotchPainter oldDelegate) =>
      oldDelegate.edge != edge ||
      oldDelegate.joining != joining ||
      oldDelegate.color != color;
}

class SideNotchClipper extends CustomClipper<Path> {
  final NotchEdge edge;
  final HardwareNotch? joining;

  const SideNotchClipper({
    this.edge = NotchEdge.right,
    this.joining,
  });

  @override
  Path getClip(Size size) {
    final shape = SideNotchShape(edge: edge, joining: joining);
    return shape.createPath(Offset.zero & size);
  }

  @override
  bool shouldReclip(covariant SideNotchClipper oldClipper) =>
      oldClipper.edge != edge || oldClipper.joining != joining;
}
