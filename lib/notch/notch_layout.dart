import 'dart:math' as math;
import '../design_system/design.dart';
import 'notch_edge.dart';

/// Every measurement is quoted in design-frame pixels so it can be checked
/// against `docs/design/frame-124-hover-tooltip.png` directly.
abstract final class NotchLayout {
  // --- The notch body ---
  static final double sideBodyDepth = Design.px(186);

  static double bodyDepth(NotchEdge edge) {
    return edge.isVertical ? sideBodyDepth : 2 * sideRingMargin + cellExtent;
  }

  static double get sideRingMargin => (sideBodyDepth - ringDiameter) / 2;

  static double ringMargin(NotchEdge edge) => sideRingMargin;

  static final double curlRadius = Design.px(103);
  static final double bezelFillet = Design.px(28);
  static final double cornerRadius = Design.px(78.8);
  static final double padTop = Design.px(69.5);
  static final double padBottom = Design.px(50.1);
  static final double cellSpacing = Design.px(83.5);

  // --- Resting pill ---
  static final double pillWidth = Design.px(26);
  static final double pillHeight = Design.px(210);
  static final double pillHotZone = Design.px(90);

  // --- Provider cell ---
  static final double ringDiameter = Design.px(117); // 44pt anchor
  static final double trackStroke = Design.px(15.5);
  static final double progressStroke = Design.px(8);
  static final double glyphSize = Design.px(46);
  static final double ringLabelGap = Design.px(26.9);

  // --- Activity indicator ---
  static final double activityDiameter = Design.px(72);
  static final double activityStroke = Design.px(5.5);

  // --- Settings orb ---
  static final double orbDiameter = Design.px(124);
  static final double orbStroke = Design.px(18);
  static final double orbGap = Design.px(27);
  static double get orbArcRadius => curlRadius - orbGap;

  static double orbConvexArcRadius(double corner) => corner + orbGap;

  static double orbCornerOffset(double corner) {
    return (corner + orbGap + orbDiameter / 2) / math.sqrt(2.0);
  }

  static final double orbGlyph = Design.px(56);
  static double get orbMergeScale => (curlRadius + orbStroke) / orbArcRadius;
  static final double orbHotZone = Design.px(152);

  // --- Hover tooltip ---
  static final double cardWidth = Design.px(600);
  static final double cardCorner = Design.px(49.5);
  static final double cardPadding = Design.px(32);
  static final double tailLength = Design.px(75);
  static final double tailHeight = Design.px(87);
  static final double tailGap = Design.px(28);
  static final double barHeight = Design.px(10.5);
  static final double headerGap = Design.px(17);
  static final double headerToBlock = Design.px(21);
  static final double labelToBar = Design.px(16.8);
  static final double barToUsed = Design.px(17.8);
  static final double blockSpacing = Design.px(20);
  static final double sessionRowGap = Design.px(10);
  static final double statusDot = Design.px(17);
  static final double statusDotStroke = Design.px(3.4);
  static final double statusDotGap = Design.px(11);
  static final double hairline = Design.px(2.5);

  // Font line heights
  static const double percentLineHeight = 18.0;
  static const double cardTitleLineHeight = 17.0;
  static const double cardBodyLineHeight = 12.0;

  static double get cardTextWidth => cardWidth - 2 * cardPadding;

  static double bodyTextHeight(String text) {
    if (text.isEmpty) return cardBodyLineHeight;
    // Approximated line budget: average ~42 chars per line at cardTextWidth
    final int lines = math.max(1, (text.length / 40.0).ceil());
    return lines * cardBodyLineHeight;
  }

  static double get cellExtent => ringDiameter + ringLabelGap + percentLineHeight;

  static double cellAlong(NotchEdge edge) {
    return edge.isVertical ? cellExtent : ringDiameter;
  }

  static double cellPitch(NotchEdge edge) {
    return cellAlong(edge) + cellSpacing;
  }

  static double padStart(NotchEdge edge) {
    return edge.isVertical ? padTop : (padTop + padBottom) / 2;
  }

  static double padEnd(NotchEdge edge) {
    return edge.isVertical ? padBottom : (padTop + padBottom) / 2;
  }

  static double ringCenter({
    required int index,
    NotchEdge edge = NotchEdge.right,
    double? flare,
  }) {
    final f = flare ?? curlRadius;
    return f + padStart(edge) + ringDiameter / 2 + index * cellPitch(edge);
  }

  static double bodyLength({
    required int cellCount,
    NotchEdge edge = NotchEdge.right,
  }) {
    final start = padStart(edge);
    final end = padEnd(edge);
    if (cellCount <= 0) return start + end;
    return start +
        cellCount * cellAlong(edge) +
        (cellCount - 1) * cellSpacing +
        end;
  }

  static double orbCenterAlong({
    required int cellCount,
    NotchEdge edge = NotchEdge.right,
  }) {
    return shapeLength(cellCount: cellCount, edge: edge);
  }

  static double get orbInsetFromEdge => curlRadius;

  static double shapeLength({
    required int cellCount,
    NotchEdge edge = NotchEdge.right,
    double? flare,
  }) {
    final f = flare ?? curlRadius;
    return bodyLength(cellCount: cellCount, edge: edge) + 2 * f;
  }

  static double cardHeight({
    required int windowCount,
    int sessionCount = 0,
    int sessionCap = defaultSessionCap,
    String? statusMessage,
    String? blockMessage,
  }) {
    final header = math.max(glyphSize, cardTitleLineHeight);
    double height = 2 * cardPadding + header;

    if (blockMessage != null && blockMessage.isNotEmpty) {
      height += headerToBlock + bodyTextHeight(blockMessage);
    }

    if (windowCount > 0) {
      final block = 2 * cardBodyLineHeight + labelToBar + barHeight + barToUsed;
      height += headerToBlock +
          windowCount * block +
          (windowCount - 1) * blockSpacing;
    } else {
      height += headerToBlock + bodyTextHeight(statusMessage ?? '');
    }

    if (sessionCount > 0) {
      final shown = math.min(sessionCount, math.max(0, sessionCap));
      final row = 2 * cardBodyLineHeight + sessionRowGap;
      height += blockSpacing +
          hairline +
          blockSpacing +
          shown * row +
          math.max(0, shown - 1) * blockSpacing;
      if (sessionCount > shown) {
        height += blockSpacing + cardBodyLineHeight;
      }
    }
    return height;
  }

  static double slack({
    required NotchEdge edge,
    double maxCardHeight = defaultMaxCardHeight,
  }) {
    return edge.isVertical
        ? math.max(endSlack, maxCardHeight / 2 + cardCorner)
        : math.max(endSlack, cardWidth / 2 + cardCorner);
  }

  static final double endSlack = Design.px(190);
  static const int maxWindowCount = 4;
  static const int defaultSessionCap = 4;
  static const int sessionCeiling = 12;

  static double maxCardHeightFor({required int sessionCap}) {
    return cardHeight(
      windowCount: maxWindowCount,
      sessionCount: sessionCap + 1,
      sessionCap: sessionCap,
    );
  }

  static final double defaultMaxCardHeight = maxCardHeightFor(sessionCap: defaultSessionCap);

  static double tooltipDepth({
    required NotchEdge edge,
    double maxCardHeight = defaultMaxCardHeight,
  }) {
    return (edge.isVertical ? cardWidth : maxCardHeight) + tailLength + tailGap;
  }

  static int sessionsFitting({
    required double cardBudget,
    required int windowCount,
  }) {
    int fits = 0;
    for (int n = 1; n <= sessionCeiling; n++) {
      final height = cardHeight(
        windowCount: windowCount,
        sessionCount: n + 1,
        sessionCap: n,
      );
      if (height <= cardBudget) {
        fits = n;
      } else {
        break;
      }
    }
    return fits;
  }
}
