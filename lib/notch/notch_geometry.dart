import 'package:flutter/material.dart';
import 'notch_edge.dart';

class HardwareNotch {
  final double width;
  final double height;

  const HardwareNotch({required this.width, required this.height});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HardwareNotch &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}

abstract class ScreenDescribing {
  Rect get frameValue;
  Rect get visibleFrameValue;
  HardwareNotch? get hardwareNotch => null;
}

class SimpleScreen implements ScreenDescribing {
  @override
  final Rect frameValue;
  @override
  final Rect visibleFrameValue;
  @override
  final HardwareNotch? hardwareNotch;

  const SimpleScreen({
    required this.frameValue,
    required this.visibleFrameValue,
    this.hardwareNotch,
  });
}

abstract final class NotchGeometry {
  static Rect panelFrame({
    required ScreenDescribing screen,
    required Size panelSize,
    NotchEdge edge = NotchEdge.right,
  }) {
    final Rect full = screen.frameValue;
    final Rect usable = screen.visibleFrameValue;
    final double width = panelSize.width.ceilToDouble();
    final double height = panelSize.height.ceilToDouble();

    Offset origin;
    switch (edge) {
      case NotchEdge.right:
        origin = Offset(usable.right - width, full.center.dy - height / 2);
        break;
      case NotchEdge.left:
        origin = Offset(usable.left, full.center.dy - height / 2);
        break;
      case NotchEdge.top:
        // In AppKit, y grows upwards, but in Flutter screen coordinates y grows downwards.
        // On macOS AppKit: origin.y = top - height.
        // In Flutter, screen origin is top-left:
        final double top = screen.hardwareNotch == null ? usable.top : full.top;
        origin = Offset(full.center.dx - width / 2, top);
        break;
      case NotchEdge.bottom:
        origin = Offset(full.center.dx - width / 2, usable.bottom - height);
        break;
    }

    return Rect.fromLTWH(
      origin.dx.roundToDouble(),
      origin.dy.roundToDouble(),
      width,
      height,
    );
  }
}
