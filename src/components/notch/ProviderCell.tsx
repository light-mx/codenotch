import React from 'react';
import { ProviderSnapshot, ActivitySummary } from '../../types';
import { NotchLayout } from '../../design/geometry';
import { Palette, getUsageBand, Typography } from '../../design/tokens';
import { ProviderGlyph } from '../glyphs/ProviderGlyph';
import { ActivityArc } from './ActivityArc';

interface ProviderCellProps {
  snapshot: ProviderSnapshot;
  activity?: ActivitySummary;
  isRefreshing?: boolean;
  isHovered?: boolean;
  onClick?: () => void;
  onMouseEnter?: () => void;
  onMouseLeave?: () => void;
}

export const ProviderCell: React.FC<ProviderCellProps> = ({
  snapshot,
  activity,
  isRefreshing = false,
  isHovered = false,
  onClick,
  onMouseEnter,
  onMouseLeave
}) => {
  const headline = snapshot.windows.find(w => w.id === snapshot.headlineID) || snapshot.windows[0];
  const usedFraction = headline?.usedFraction;
  const isBlocked = !!snapshot.block;
  const hasReading = snapshot.windows.length > 0;
  const isStale = snapshot.status.type === 'stale' || !hasReading;

  const { band, color: bandColor } = getUsageBand(usedFraction ?? 0, isBlocked);

  const ringDiameter = NotchLayout.ringDiameter;
  const trackStroke = NotchLayout.trackStroke;
  const progressStroke = NotchLayout.progressStroke;

  // SVG circular arc math
  const radius = (ringDiameter - trackStroke) / 2;
  const circumference = 2 * Math.PI * radius;
  const sweep = Math.min(Math.max(usedFraction ?? 0, 0), 1);
  const strokeDashoffset = circumference * (1 - sweep);

  const percentText = hasReading
    ? usedFraction !== undefined
      ? `${Math.round(usedFraction * 100)}%`
      : headline?.remaining !== undefined
      ? `${headline.remaining}`
      : headline?.used !== undefined
      ? `${headline.used}`
      : '—'
    : '—';

  return (
    <div
      className="flex flex-col items-center cursor-pointer select-none transition-transform duration-200"
      style={{
        width: NotchLayout.ringDiameter,
        height: NotchLayout.cellExtent,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: `${NotchLayout.ringLabelGap}px`,
        transform: isRefreshing ? 'scale(0.93)' : isHovered ? 'scale(1.04)' : 'scale(1)'
      }}
      onClick={onClick}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
    >
      {/* 44pt Circular Progress Ring */}
      <div
        className="relative flex items-center justify-center"
        style={{
          width: ringDiameter,
          height: ringDiameter,
          opacity: isStale ? 0.45 : 1
        }}
      >
        <svg
          width={ringDiameter}
          height={ringDiameter}
          viewBox={`0 0 ${ringDiameter} ${ringDiameter}`}
          style={{ transform: 'rotate(-90deg)' }}
        >
          {/* Background track circle */}
          <circle
            cx={ringDiameter / 2}
            cy={ringDiameter / 2}
            r={radius}
            stroke={Palette.ringTrack}
            strokeWidth={trackStroke}
            fill="none"
          />

          {/* Progress arc */}
          {hasReading && usedFraction !== undefined && (
            <circle
              cx={ringDiameter / 2}
              cy={ringDiameter / 2}
              r={radius}
              stroke={bandColor}
              strokeWidth={progressStroke}
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              strokeLinecap="round"
              fill="none"
              style={{
                transition: 'stroke-dashoffset 0.4s cubic-bezier(0.32, 0, 0.14, 1), stroke 0.3s ease'
              }}
            />
          )}
        </svg>

        {/* Center Provider Glyph */}
        <div
          className="absolute inset-0 flex items-center justify-center pointer-events-none"
          style={{
            color: Palette.textPrimary,
            opacity: band === 'exhausted' ? 0.35 : 1
          }}
        >
          <ProviderGlyph glyph={snapshot.glyph} size={NotchLayout.glyphSize} />
        </div>

        {/* Activity Arc (spinner or pulse) */}
        {activity && activity.state !== 'idle' && (
          <ActivityArc summary={activity} />
        )}
      </div>

      {/* Percent Label underneath */}
      <div
        style={{
          color: Palette.textPrimary,
          fontSize: Typography.percent.fontSize,
          fontWeight: Typography.percent.fontWeight,
          lineHeight: `${NotchLayout.percentLineHeight}px`,
          height: `${NotchLayout.percentLineHeight}px`,
          textAlign: 'center',
          fontVariantNumeric: 'tabular-nums'
        }}
      >
        {percentText}
      </div>
    </div>
  );
};
