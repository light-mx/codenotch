/**
 * Sampled directly from docs/design/frame-124-hover-tooltip.png.
 * Preserves exact color codes from Palette.swift.
 */
export const Palette = {
  notch: '#000000',
  card: '#000000',
  ringTrack: '#303030',
  barTrack: '#2D2D2D',

  ample: '#00FF88', // Green (0-49%)
  watch: '#F2FF00', // Yellow (50-79%)
  critical: '#FF3F00', // Orange (80-100%)

  textPrimary: '#FFFFFF',
  textSecondary: '#808080'
} as const;

export type UsageBand = 'ample' | 'watch' | 'critical' | 'exhausted';

export function getUsageBand(fraction: number, isBlocked = false): { band: UsageBand; color: string } {
  if (isBlocked || fraction >= 1.0) {
    return { band: 'exhausted', color: Palette.critical };
  }
  if (fraction >= 0.8) {
    return { band: 'critical', color: Palette.critical };
  }
  if (fraction >= 0.5) {
    return { band: 'watch', color: Palette.watch };
  }
  return { band: 'ample', color: Palette.ample };
}

/**
 * Design scale matching Design.swift:
 * 44pt ring across 117px in frame -> scale = 44 / 117
 */
export const DESIGN_SCALE = 44.0 / 117.0;

export function px(pixels: number): number {
  return pixels * DESIGN_SCALE;
}

export const Typography = {
  percent: {
    fontSize: `${px(27) / 0.714}px`, // cap ratio ~0.714 -> ~14.2px
    fontWeight: 600,
    lineHeight: 1.1
  },
  cardTitle: {
    fontSize: `${px(26) / 0.714}px`,
    fontWeight: 600,
    lineHeight: 1.2
  },
  cardBody: {
    fontSize: `${px(18) / 0.714}px`,
    fontWeight: 400,
    lineHeight: 1.35
  }
} as const;
