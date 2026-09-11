import React from 'react';
import { ProviderSnapshot, ActivitySummary, LimitWindow, AgentSession } from '../../types';
import { NotchLayout } from '../../design/geometry';
import { Palette, getUsageBand, Typography } from '../../design/tokens';
import { ProviderGlyph } from '../glyphs/ProviderGlyph';
import { PauseCircle } from 'lucide-react';

interface TooltipCardProps {
  snapshot: ProviderSnapshot;
  activity?: ActivitySummary;
  direction?: 'leading' | 'trailing' | 'up' | 'down';
  className?: string;
  style?: React.CSSProperties;
}

function formatResetCopy(resetsAtStr?: string): string {
  if (!resetsAtStr) return '';
  const date = new Date(resetsAtStr);
  const now = new Date();
  const diffMs = date.getTime() - now.getTime();
  if (diffMs <= 0) return 'Resetting now';

  const diffMin = Math.round(diffMs / 60000);
  if (diffMin < 60) {
    return `Resets in ${diffMin} min`;
  }
  const diffHours = Math.round(diffMin / 60);
  if (diffHours < 24) {
    const timeStr = date.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    return `Resets at ${timeStr}`;
  }
  const dayStr = date.toLocaleDateString([], { weekday: 'short', hour: 'numeric', minute: '2-digit' });
  return `Resets ${dayStr}`;
}

function formatElapsed(sinceStr: string): string {
  const date = new Date(sinceStr);
  const now = new Date();
  const diffSec = Math.max(0, Math.floor((now.getTime() - date.getTime()) / 1000));
  if (diffSec < 60) return `${diffSec}s`;
  const diffMin = Math.floor(diffSec / 60);
  if (diffMin < 60) return `${diffMin}m`;
  const diffHours = Math.floor(diffMin / 60);
  return `${diffHours}h`;
}

export const TooltipCard: React.FC<TooltipCardProps> = ({
  snapshot,
  activity,
  direction = 'leading',
  className = '',
  style = {}
}) => {
  const cardWidth = NotchLayout.cardWidth;
  const cardCorner = NotchLayout.cardCorner;
  const cardPadding = NotchLayout.cardPadding;
  const tailLength = NotchLayout.tailLength;
  const tailHeight = NotchLayout.tailHeight;

  // Build SVG tail triangle
  const renderTail = () => {
    // For 'leading', card is on left, tail points to the right (towards notch)
    return (
      <svg
        width={tailLength}
        height={tailHeight}
        viewBox={`0 0 ${tailLength} ${tailHeight}`}
        style={{ flexShrink: 0 }}
      >
        <path
          d={`M 0 0 L ${tailLength} ${tailHeight / 2} L 0 ${tailHeight} Z`}
          fill={Palette.card}
        />
      </svg>
    );
  };

  return (
    <div
      className={`flex items-center select-none pointer-events-auto ${className}`}
      style={{
        display: 'inline-flex',
        flexDirection: 'row',
        alignItems: 'center',
        ...style
      }}
    >
      {/* Main Card Body */}
      <div
        style={{
          width: cardWidth,
          backgroundColor: Palette.card,
          borderRadius: cardCorner,
          padding: cardPadding,
          color: Palette.textPrimary,
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.7)',
          border: '1px solid rgba(255, 255, 255, 0.08)'
        }}
      >
        {/* Header */}
        <div
          className="flex items-center justify-between"
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: `${NotchLayout.headerToBlock}px`
          }}
        >
          <div className="flex items-center gap-2" style={{ display: 'flex', alignItems: 'center', gap: `${NotchLayout.headerGap}px` }}>
            <ProviderGlyph glyph={snapshot.glyph} size={NotchLayout.glyphSize} />
            <span
              style={{
                fontSize: Typography.cardTitle.fontSize,
                fontWeight: Typography.cardTitle.fontWeight,
                color: Palette.textPrimary
              }}
            >
              {snapshot.displayName} Usage
            </span>
          </div>

          {snapshot.status.type === 'stale' && snapshot.status.staleSince && (
            <span
              style={{
                fontSize: Typography.cardBody.fontSize,
                color: Palette.textSecondary
              }}
            >
              {formatElapsed(snapshot.status.staleSince)} ago
            </span>
          )}
        </div>

        {/* Blocked row if any */}
        {snapshot.block && (
          <div
            className="flex items-center gap-2 mb-3"
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              color: Palette.critical,
              fontSize: Typography.cardBody.fontSize,
              marginBottom: '10px'
            }}
          >
            <PauseCircle size={NotchLayout.statusDot} />
            <span>{snapshot.block.reason}</span>
          </div>
        )}

        {/* Status message or Limit Windows */}
        {snapshot.windows.length === 0 ? (
          <div
            style={{
              color: Palette.textSecondary,
              fontSize: Typography.cardBody.fontSize,
              padding: '6px 0'
            }}
          >
            {snapshot.status.message || 'Waiting for the first reading…'}
          </div>
        ) : (
          <div className="flex flex-col gap-3" style={{ display: 'flex', flexDirection: 'column', gap: `${NotchLayout.blockSpacing}px` }}>
            {snapshot.windows.map((window: LimitWindow) => {
              const { color: bandColor } = getUsageBand(window.usedFraction ?? 0, !!snapshot.block);
              const usedPercent = window.usedFraction !== undefined ? Math.round(window.usedFraction * 100) : undefined;
              const resetCopy = formatResetCopy(window.resetsAt);

              const trackWidth = cardWidth - 2 * cardPadding;
              const fillWidth = window.usedFraction !== undefined
                ? Math.max(NotchLayout.barHeight, trackWidth * Math.min(Math.max(window.usedFraction, 0), 1))
                : 0;

              return (
                <div key={window.id} className="flex flex-col" style={{ display: 'flex', flexDirection: 'column' }}>
                  {/* Top row: Label & Resets At */}
                  <div
                    className="flex justify-between items-center"
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      fontSize: Typography.cardBody.fontSize,
                      marginBottom: `${NotchLayout.labelToBar}px`
                    }}
                  >
                    <span style={{ color: Palette.textPrimary }}>{window.label}</span>
                    <span style={{ color: Palette.textSecondary }}>{resetCopy}</span>
                  </div>

                  {/* Progress track bar */}
                  {window.usedFraction !== undefined && (
                    <div
                      style={{
                        width: '100%',
                        height: NotchLayout.barHeight,
                        backgroundColor: Palette.barTrack,
                        borderRadius: NotchLayout.barHeight / 2,
                        overflow: 'hidden',
                        position: 'relative'
                      }}
                    >
                      <div
                        style={{
                          width: `${fillWidth}px`,
                          height: '100%',
                          backgroundColor: bandColor,
                          borderRadius: NotchLayout.barHeight / 2,
                          transition: 'width 0.35s ease, background-color 0.3s ease'
                        }}
                      />
                    </div>
                  )}

                  {/* Summary below bar */}
                  <div
                    style={{
                      fontSize: Typography.cardBody.fontSize,
                      color: Palette.textPrimary,
                      marginTop: `${NotchLayout.barToUsed}px`
                    }}
                  >
                    {usedPercent !== undefined
                      ? `${usedPercent}% Used · ${Math.max(0, 100 - usedPercent)}% left`
                      : window.remaining !== undefined
                      ? `${window.remaining} left`
                      : window.used !== undefined
                      ? `${window.used} used`
                      : 'No reading'}
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Live Sessions List */}
        {activity && activity.sessions && activity.sessions.length > 0 && (
          <div style={{ marginTop: `${NotchLayout.blockSpacing}px` }}>
            {/* Hairline Divider */}
            <div
              style={{
                width: '100%',
                height: `${NotchLayout.hairline}px`,
                backgroundColor: Palette.ringTrack,
                marginBottom: `${NotchLayout.blockSpacing}px`
              }}
            />

            <div className="flex flex-col gap-2.5" style={{ display: 'flex', flexDirection: 'column', gap: `${NotchLayout.sessionRowGap}px` }}>
              {activity.sessions.slice(0, 4).map((session: AgentSession) => {
                const sessionColor =
                  session.state === 'busy'
                    ? Palette.ample
                    : session.state === 'waiting'
                    ? Palette.watch
                    : Palette.textSecondary;

                return (
                  <div key={session.id} className="flex flex-col" style={{ display: 'flex', flexDirection: 'column' }}>
                    <div
                      className="flex justify-between items-center"
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        fontSize: Typography.cardBody.fontSize
                      }}
                    >
                      <span style={{ color: Palette.textPrimary }}>{session.name}</span>
                      <div className="flex items-center gap-1.5" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <span
                          style={{
                            width: '6px',
                            height: '6px',
                            borderRadius: '50%',
                            backgroundColor: sessionColor
                          }}
                        />
                        <span style={{ color: sessionColor }}>
                          {session.state === 'busy' ? 'working' : session.state === 'waiting' ? 'waiting' : 'idle'}
                        </span>
                      </div>
                    </div>

                    <div
                      className="flex justify-between items-center"
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        fontSize: Typography.cardBody.fontSize,
                        color: Palette.textSecondary,
                        marginTop: '2px'
                      }}
                    >
                      <span>{session.waitingFor || session.detail}</span>
                      <span>{formatElapsed(session.since)}</span>
                    </div>
                  </div>
                );
              })}

              {activity.sessions.length > 4 && (
                <div
                  style={{
                    fontSize: Typography.cardBody.fontSize,
                    color: Palette.textSecondary,
                    marginTop: '4px'
                  }}
                >
                  and {activity.sessions.length - 4} more
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Speech-bubble Tail */}
      {direction === 'leading' && renderTail()}
    </div>
  );
};
