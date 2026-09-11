import 'package:flutter_test/flutter_test.dart';
import 'package:codenotch/notch/notch_edge.dart';
import 'package:codenotch/notch/notch_layout.dart';
import 'package:codenotch/notch/notch_view_model.dart';

void main() {
  group('NotchLayoutTests', () {
    test('ring is the spec anchor', () {
      expect(NotchLayout.ringDiameter, closeTo(44, 0.001));
    });

    test('proportions match the frame', () {
      // 186px body against a 117px ring.
      expect(
        NotchLayout.bodyDepth(NotchEdge.right) / NotchLayout.ringDiameter,
        closeTo(186.0 / 117.0, 0.001),
      );
      // Cell centre to cell centre is ~275px in the frame
      expect(
        NotchLayout.cellPitch(NotchEdge.right) / NotchLayout.ringDiameter,
        closeTo(275.0 / 117.0, 0.05),
      );
      // The card is 600px wide.
      expect(
        NotchLayout.cardWidth / NotchLayout.ringDiameter,
        closeTo(600.0 / 117.0, 0.001),
      );
    });

    test('shape grows one cell at a time', () {
      final cell = NotchLayout.cellExtent;
      final one = NotchLayout.shapeLength(cellCount: 1);
      final two = NotchLayout.shapeLength(cellCount: 2);
      expect(two - one, closeTo(cell + NotchLayout.cellSpacing, 0.001));
    });

    test('ring centres are evenly spaced inside the body', () {
      final first = NotchLayout.ringCenter(index: 0);
      expect(
        first,
        closeTo(
          NotchLayout.curlRadius + NotchLayout.padTop + NotchLayout.ringDiameter / 2,
          0.001,
        ),
      );
      expect(
        NotchLayout.ringCenter(index: 2) - NotchLayout.ringCenter(index: 1),
        closeTo(NotchLayout.cellPitch(NotchEdge.right), 0.001),
      );
    });

    test('card grows with the session list', () {
      final bare = NotchLayout.cardHeight(windowCount: 2);
      final one = NotchLayout.cardHeight(windowCount: 2, sessionCount: 1);
      final two = NotchLayout.cardHeight(windowCount: 2, sessionCount: 2);
      expect(one, greaterThan(bare));
      expect(
        two - one,
        closeTo(
          2 * NotchLayout.cardBodyLineHeight + NotchLayout.sessionRowGap + NotchLayout.blockSpacing,
          0.001,
        ),
      );
    });

    test('activity ring clears the glyph and the track', () {
      final outerEdge = NotchLayout.activityDiameter / 2 + NotchLayout.activityStroke / 2;
      final innerEdge = NotchLayout.activityDiameter / 2 - NotchLayout.activityStroke / 2;
      final trackInnerEdge = NotchLayout.ringDiameter / 2 - NotchLayout.trackStroke;
      expect(outerEdge, lessThan(trackInnerEdge));
      expect(innerEdge, greaterThan(NotchLayout.glyphSize / 2));
    });

    test('tooltip fits the panel for every cell', () {
      const cells = 3;
      final cardHalf = NotchLayout.cardHeight(windowCount: 2) / 2;
      final panelHeight = NotchLayout.shapeLength(cellCount: cells) +
          2 * NotchLayout.slack(edge: NotchEdge.right);
      for (int index = 0; index < cells; index++) {
        final centre = NotchLayout.slack(edge: NotchEdge.right) +
            NotchLayout.ringCenter(index: index);
        expect(centre - cardHalf, greaterThanOrEqualTo(0));
        expect(centre + cardHalf, lessThanOrEqualTo(panelHeight));
      }
    });
  });

  group('PanelSizingTests', () {
    test('panel grows with the provider count', () {
      final model = NotchViewModel();
      final empty = model.panelSize(cellCount: 0).height;
      final one = model.panelSize(cellCount: 1).height;
      final two = model.panelSize(cellCount: 2).height;
      expect(one, greaterThan(empty));
      expect(two, greaterThan(one));
    });

    test('the panel always fits the whole shape', () {
      final model = NotchViewModel();
      for (int count = 0; count <= 5; count++) {
        final panel = model.panelSize(cellCount: count).height;
        final shape = NotchLayout.shapeLength(cellCount: count);
        expect(panel, greaterThanOrEqualTo(shape));
      }
    });
  });

  group('FoldedNotchTests', () {
    test('folded is far smaller than open', () {
      final m = NotchViewModel();
      m.setExpanded(false);
      final folded = m.notchSize;
      m.setExpanded(true);
      final open = m.notchSize;
      expect(folded.width, lessThan(open.width / 2));
      expect(folded.height, lessThan(open.height / 2));
    });

    test('the wake region is larger than the pill', () {
      expect(NotchLayout.pillHotZone, greaterThan(NotchLayout.pillWidth));
    });
  });

  group('SettingsOrbTests', () {
    test('it shares the flares centre of curvature', () {
      expect(NotchLayout.orbInsetFromEdge, closeTo(NotchLayout.curlRadius, 0.001));
      for (int count = 1; count <= 4; count++) {
        expect(
          NotchLayout.orbCenterAlong(cellCount: count),
          closeTo(NotchLayout.shapeLength(cellCount: count), 0.001),
        );
      }
    });

    test('the arc sits inside the flare with a gap', () {
      expect(NotchLayout.orbArcRadius, lessThan(NotchLayout.curlRadius));
      final gap = NotchLayout.curlRadius - NotchLayout.orbArcRadius;
      expect(gap, greaterThan(NotchLayout.orbStroke / 2));
    });

    test('the disc fits within the arc', () {
      expect(NotchLayout.orbDiameter / 2, lessThan(NotchLayout.orbArcRadius));
    });

    test('the hit region is larger than the orb', () {
      expect(NotchLayout.orbHotZone, greaterThan(NotchLayout.orbDiameter));
    });
  });
}
