import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:codenotch/notch/notch_edge.dart';
import 'package:codenotch/notch/notch_layout.dart';
import 'package:codenotch/notch/side_notch_painter.dart';

void main() {
  group('SideNotchShapeTests', () {
    Rect bounds(double width, double height) {
      final path = SideNotchShape(edge: NotchEdge.right).createPath(
        Rect.fromLTWH(0, 0, width, height),
      );
      return path.getBounds();
    }

    test('the folded pill keeps its corners and produces non-empty bounds', () {
      final width = NotchLayout.pillWidth;
      final height = NotchLayout.pillHeight;
      final box = bounds(width, height);
      expect(box.isEmpty, isFalse);
      expect(box.width, closeTo(width, 1.0));
      expect(box.height, closeTo(height, 1.0));
    });

    test('the open notch has expected bounds', () {
      final width = NotchLayout.bodyDepth(NotchEdge.right);
      const height = 400.0;
      final box = bounds(width, height);
      expect(box.isEmpty, isFalse);
      expect(box.width, closeTo(width, 1.0));
      expect(box.height, closeTo(height, 1.0));
    });

    test('every intermediate size is drawable without degeneracy', () {
      for (int step = 0; step <= 20; step++) {
        final t = step / 20.0;
        final w = NotchLayout.pillWidth +
            (NotchLayout.bodyDepth(NotchEdge.right) - NotchLayout.pillWidth) * t;
        final h = NotchLayout.pillHeight + (400.0 - NotchLayout.pillHeight) * t;
        final box = bounds(w, h);
        expect(box.isEmpty, isFalse, reason: 'degenerate path at $w x $h');
        expect(box.width, closeTo(w, 1.0));
      }
    });

    test('transforms correctly for all 4 screen edges', () {
      const rect = Rect.fromLTWH(0, 0, 100, 300);
      for (final edge in NotchEdge.values) {
        final path = SideNotchShape(edge: edge).createPath(rect);
        final b = path.getBounds();
        expect(b.isEmpty, isFalse, reason: 'edge $edge produced empty bounds');
      }
    });
  });
}
