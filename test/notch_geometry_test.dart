import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:codenotch/notch/notch_edge.dart';
import 'package:codenotch/notch/notch_geometry.dart';

void main() {
  group('NotchGeometryTests', () {
    const screen = SimpleScreen(
      frameValue: Rect.fromLTWH(0, 0, 1800, 1169),
      visibleFrameValue: Rect.fromLTWH(0, 0, 1800, 1132),
    );

    test('panel hugs the right edge and is vertically centred', () {
      const size = Size(334, 484);
      final frame = NotchGeometry.panelFrame(
        screen: screen,
        panelSize: size,
        edge: NotchEdge.right,
      );

      expect(frame.right, closeTo(1800, 0.001));
      expect(frame.center.dy, closeTo(screen.frameValue.center.dy, 0.5));
      expect(frame.size, size);
    });

    test('panel follows a screen with a non-zero origin', () {
      const secondary = SimpleScreen(
        frameValue: Rect.fromLTWH(-2560, 200, 2560, 1440),
        visibleFrameValue: Rect.fromLTWH(-2560, 200, 2560, 1415),
      );
      final frame = NotchGeometry.panelFrame(
        screen: secondary,
        panelSize: const Size(334, 484),
        edge: NotchEdge.right,
      );

      expect(frame.right, closeTo(0, 0.001));
      expect(frame.center.dy, closeTo(secondary.frameValue.center.dy, 0.5));
    });

    test('a fractional size still lands flush on the edge', () {
      const fractional = Size(334.3247863247863, 205.182905982906);
      final frame = NotchGeometry.panelFrame(
        screen: screen,
        panelSize: fractional,
        edge: NotchEdge.right,
      );

      expect(frame.right, closeTo(1800, 0.0001));
    });

    test('the frame is integral', () {
      const fractional = Size(334.3247863247863, 205.182905982906);
      final frame = NotchGeometry.panelFrame(
        screen: screen,
        panelSize: fractional,
        edge: NotchEdge.right,
      );

      for (final value in [frame.left, frame.top, frame.width, frame.height]) {
        expect(value, value.roundToDouble(), reason: '$value is not integral');
      }
    });

    test('it never rounds below the requested size', () {
      const requested = Size(334.325, 205.183);
      final frame = NotchGeometry.panelFrame(
        screen: screen,
        panelSize: requested,
        edge: NotchEdge.right,
      );

      expect(frame.width, greaterThanOrEqualTo(requested.width));
      expect(frame.height, greaterThanOrEqualTo(requested.height));
    });
  });
}
