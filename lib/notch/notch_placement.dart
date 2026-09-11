import 'package:flutter/material.dart';
import 'notch_edge.dart';

/// Stack space: one-dimensional (along, across) mapping to panel coordinates.
class NotchPlacement {
  final NotchEdge edge;
  final Size panelSize;

  const NotchPlacement({required this.edge, required this.panelSize});

  Offset point({required double along, required double across}) {
    switch (edge) {
      case NotchEdge.right:
        return Offset(panelSize.width - across, along);
      case NotchEdge.left:
        return Offset(across, along);
      case NotchEdge.top:
        return Offset(along, across);
      case NotchEdge.bottom:
        return Offset(along, panelSize.height - across);
    }
  }

  Rect rect({
    required double along,
    required double across,
    required double length,
    required double depth,
  }) {
    switch (edge) {
      case NotchEdge.right:
        return Rect.fromLTWH(panelSize.width - across - depth, along, depth, length);
      case NotchEdge.left:
        return Rect.fromLTWH(across, along, depth, length);
      case NotchEdge.top:
        return Rect.fromLTWH(along, across, length, depth);
      case NotchEdge.bottom:
        return Rect.fromLTWH(along, panelSize.height - across - depth, length, depth);
    }
  }

  double alongOf(Offset point) {
    return edge.isVertical ? point.dy : point.dx;
  }

  double acrossOf(Offset point) {
    switch (edge) {
      case NotchEdge.right:
        return panelSize.width - point.dx;
      case NotchEdge.left:
        return point.dx;
      case NotchEdge.top:
        return point.dy;
      case NotchEdge.bottom:
        return panelSize.height - point.dy;
    }
  }
}
