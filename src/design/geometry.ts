import { px, DESIGN_SCALE } from './tokens';
import { NotchEdge } from '../types';

export const NotchLayout = {
  // Proportional scale factor
  scale: DESIGN_SCALE,

  // Notch body
  sideBodyDepth: px(186),
  curlRadius: px(103),
  bezelFillet: px(28),
  cornerRadius: px(78.8),
  padTop: px(69.5),
  padBottom: px(50.1),
  cellSpacing: px(83.5),

  // Resting pill
  pillWidth: px(26),
  pillHeight: px(210),
  pillHotZone: px(90),

  // Provider cell
  ringDiameter: px(117), // 44pt
  trackStroke: px(15.5),
  progressStroke: px(8),
  glyphSize: px(46),
  ringLabelGap: px(26.9),

  // Activity indicator
  activityDiameter: px(72),
  activityStroke: px(5.5),

  // Settings orb
  orbDiameter: px(124),
  orbStroke: px(18),
  orbGap: px(27),
  get orbArcRadius(): number {
    return this.curlRadius - this.orbGap;
  },
  get orbMergeScale(): number {
    return (this.curlRadius + this.orbStroke) / this.orbArcRadius;
  },
  orbHotZone: px(152),
  orbGlyph: px(56),

  // Hover tooltip
  cardWidth: px(600),
  cardCorner: px(49.5),
  cardPadding: px(32),
  tailLength: px(75),
  tailHeight: px(87),
  tailGap: px(28),
  barHeight: px(10.5),
  headerGap: px(17),
  headerToBlock: px(21),
  labelToBar: px(16.8),
  barToUsed: px(17.8),
  blockSpacing: px(20),
  sessionRowGap: px(10),
  statusDot: px(17),
  statusDotStroke: px(3.4),
  statusDotGap: px(11),
  hairline: px(2.5),

  percentLineHeight: 18,
  cardTitleLineHeight: 20,
  cardBodyLineHeight: 16,

  get cellExtent(): number {
    return this.ringDiameter + this.ringLabelGap + this.percentLineHeight;
  },

  isVertical(edge: NotchEdge): boolean {
    return edge === 'right' || edge === 'left';
  },

  bodyDepth(edge: NotchEdge): number {
    return this.isVertical(edge)
      ? this.sideBodyDepth
      : 2 * ((this.sideBodyDepth - this.ringDiameter) / 2) + this.cellExtent;
  },

  cellAlong(edge: NotchEdge): number {
    return this.isVertical(edge) ? this.cellExtent : this.ringDiameter;
  },

  cellPitch(edge: NotchEdge): number {
    return this.cellAlong(edge) + this.cellSpacing;
  },

  padStart(edge: NotchEdge): number {
    return this.isVertical(edge) ? this.padTop : (this.padTop + this.padBottom) / 2;
  },

  padEnd(edge: NotchEdge): number {
    return this.isVertical(edge) ? this.padBottom : (this.padTop + this.padBottom) / 2;
  },

  ringCenter(index: number, edge: NotchEdge = 'right', flare?: number): number {
    const f = flare ?? this.curlRadius;
    return f + this.padStart(edge) + this.ringDiameter / 2 + index * this.cellPitch(edge);
  },

  bodyLength(cellCount: number, edge: NotchEdge = 'right'): number {
    const start = this.padStart(edge);
    const end = this.padEnd(edge);
    if (cellCount <= 0) return start + end;
    return start + cellCount * this.cellAlong(edge) + (cellCount - 1) * this.cellSpacing + end;
  },

  shapeLength(cellCount: number, edge: NotchEdge = 'right', flare?: number): number {
    const f = flare ?? this.curlRadius;
    return this.bodyLength(cellCount, edge) + 2 * f;
  },

  cardHeight(windowCount: number, sessionCount = 0, sessionCap = 4, _statusMessage?: string, blockMessage?: string): number {
    const header = Math.max(this.glyphSize, this.cardTitleLineHeight);
    let height = 2 * this.cardPadding + header;

    if (blockMessage) {
      height += this.headerToBlock + this.cardBodyLineHeight * 1.5;
    }

    if (windowCount > 0) {
      const block = 2 * this.cardBodyLineHeight + this.labelToBar + this.barHeight + this.barToUsed;
      height += this.headerToBlock + windowCount * block + (windowCount - 1) * this.blockSpacing;
    } else {
      height += this.headerToBlock + this.cardBodyLineHeight * 2;
    }

    if (sessionCount > 0) {
      const shown = Math.min(sessionCount, Math.max(0, sessionCap));
      const row = 2 * this.cardBodyLineHeight + this.sessionRowGap;
      height += this.blockSpacing + this.hairline + this.blockSpacing + shown * row + Math.max(0, shown - 1) * this.blockSpacing;
      if (sessionCount > shown) {
        height += this.blockSpacing + this.cardBodyLineHeight;
      }
    }

    return height;
  }
};
