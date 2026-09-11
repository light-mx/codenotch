import React, { useState, useRef, useEffect } from 'react';
import { ProviderSnapshot, ActivitySummary, UserPreferences } from '../../types';
import { NotchLayout } from '../../design/geometry';
import { SideNotchShape } from './SideNotchShape';
import { ProviderCell } from './ProviderCell';
import { SettingsOrb } from './SettingsOrb';
import { TooltipCard } from './TooltipCard';

interface NotchRootProps {
  snapshots: ProviderSnapshot[];
  activities: Record<string, ActivitySummary>;
  preferences: UserPreferences;
  onOpenSettings: () => void;
  onRefresh: (id?: string) => void;
  onContextMenu: (e: React.MouseEvent) => void;
}

export const NotchRoot: React.FC<NotchRootProps> = ({
  snapshots,
  activities,
  preferences,
  onOpenSettings,
  onRefresh,
  onContextMenu
}) => {
  const edge = preferences.notchEdge;
  const isVertical = NotchLayout.isVertical(edge);

  // State
  const [isHovered, setIsHovered] = useState(false);
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);
  const [refreshingIds, setRefreshingIds] = useState<Set<string>>(new Set());

  const hoverTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Expanded condition:
  // - If visibility is 'always', always true.
  // - If visibility is 'never', always false (or hidden).
  // - If visibility is 'hover', true when isHovered or hoveredIndex !== null.
  const isExpanded = preferences.notchVisibility === 'always' || (preferences.notchVisibility === 'hover' && isHovered);

  const cellCount = snapshots.length;
  const bodyDepth = NotchLayout.bodyDepth(edge);
  const shapeLength = NotchLayout.shapeLength(cellCount, edge);

  // When folded at rest, notch shrinks to pill
  const currentDepth = isExpanded ? bodyDepth : NotchLayout.pillWidth;
  const currentLength = isExpanded ? shapeLength : NotchLayout.pillHeight;

  // Window bounds: ensure mouse events forward properly
  const handleMouseEnterContainer = () => {
    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
      hoverTimeoutRef.current = null;
    }
    setIsHovered(true);
    if (window.codenotch) {
      window.codenotch.setIgnoreMouseEvents(false);
    }
  };

  const handleMouseLeaveContainer = () => {
    hoverTimeoutRef.current = setTimeout(() => {
      setIsHovered(false);
      setHoveredIndex(null);
      if (window.codenotch) {
        window.codenotch.setIgnoreMouseEvents(true);
      }
    }, 250); // 250ms grace period matching Swift spec
  };

  const handleCellHover = (index: number) => {
    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
      hoverTimeoutRef.current = null;
    }
    setHoveredIndex(index);
    if (window.codenotch) {
      window.codenotch.setIgnoreMouseEvents(false);
    }
  };

  const handleCellClick = (snapshot: ProviderSnapshot) => {
    setRefreshingIds(prev => new Set(prev).add(snapshot.id));
    onRefresh(snapshot.id);
    setTimeout(() => {
      setRefreshingIds(prev => {
        const next = new Set(prev);
        next.delete(snapshot.id);
        return next;
      });
    }, 1200);
  };

  useEffect(() => {
    return () => {
      if (hoverTimeoutRef.current) clearTimeout(hoverTimeoutRef.current);
    };
  }, []);

  const activeSnapshot = hoveredIndex !== null ? snapshots[hoveredIndex] : null;

  return (
    <div
      className="relative w-full h-full flex items-center justify-end overflow-visible select-none"
      style={{
        width: '100vw',
        height: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: edge === 'right' ? 'flex-end' : edge === 'left' ? 'flex-start' : 'center',
        pointerEvents: 'none'
      }}
      onContextMenu={onContextMenu}
    >
      {/* Container holding Notch, Orb, and Tooltip */}
      <div
        className="relative flex items-center"
        style={{
          display: 'flex',
          flexDirection: isVertical ? 'column' : 'row',
          alignItems: 'center',
          pointerEvents: 'auto'
        }}
        onMouseEnter={handleMouseEnterContainer}
        onMouseLeave={handleMouseLeaveContainer}
      >
        {/* Tooltip Card (positioned to the left on right edge) */}
        {isExpanded && activeSnapshot && hoveredIndex !== null && (
          <div
            style={{
              position: 'absolute',
              right: `${bodyDepth + NotchLayout.tailGap}px`,
              top: `${NotchLayout.ringCenter(hoveredIndex, edge) - NotchLayout.tailHeight / 2}px`,
              zIndex: 100,
              pointerEvents: 'auto',
              animation: 'fadeInSlide 0.22s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <TooltipCard
              snapshot={activeSnapshot}
              activity={activities[activeSnapshot.id]}
              direction="leading"
            />
          </div>
        )}

        {/* Notch Shape */}
        <SideNotchShape
          width={isVertical ? currentDepth : currentLength}
          height={isVertical ? currentLength : currentDepth}
          edge={edge}
          style={{
            transition: 'width 0.35s cubic-bezier(0.36, 0, 0.2, 1), height 0.35s cubic-bezier(0.36, 0, 0.2, 1)',
            overflow: 'hidden'
          }}
        >
          {/* Provider Cells Stack */}
          <div
            style={{
              width: '100%',
              height: '100%',
              display: 'flex',
              flexDirection: isVertical ? 'column' : 'row',
              alignItems: 'center',
              justifyContent: 'flex-start',
              paddingTop: isVertical ? `${NotchLayout.padStart(edge) + NotchLayout.curlRadius}px` : 0,
              paddingLeft: !isVertical ? `${NotchLayout.padStart(edge) + NotchLayout.curlRadius}px` : 0,
              gap: `${NotchLayout.cellSpacing}px`,
              opacity: isExpanded ? 1 : 0,
              transform: isExpanded ? 'translate(0, 0)' : 'translate(16px, 0)',
              transition: 'opacity 0.28s ease, transform 0.32s cubic-bezier(0.36, 0, 0.2, 1)',
              pointerEvents: isExpanded ? 'auto' : 'none'
            }}
          >
            {snapshots.map((snapshot, idx) => (
              <ProviderCell
                key={snapshot.id}
                snapshot={snapshot}
                activity={activities[snapshot.id]}
                isHovered={hoveredIndex === idx}
                isRefreshing={refreshingIds.has(snapshot.id)}
                onClick={() => handleCellClick(snapshot)}
                onMouseEnter={() => handleCellHover(idx)}
                onMouseLeave={() => setHoveredIndex(null)}
              />
            ))}
          </div>
        </SideNotchShape>

        {/* Settings Orb below the Notch */}
        {snapshots.length > 0 && isExpanded && (
          <div
            style={{
              position: 'absolute',
              bottom: `-${NotchLayout.orbDiameter / 2}px`,
              right: `${NotchLayout.curlRadius / 2}px`,
              zIndex: 10,
              pointerEvents: 'auto',
              transition: 'opacity 0.25s ease, transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <SettingsOrb edge={edge} onClick={onOpenSettings} />
          </div>
        )}
      </div>

      <style>{`
        @keyframes fadeInSlide {
          from { opacity: 0; transform: translateX(12px); }
          to { opacity: 1; transform: translateX(0); }
        }
      `}</style>
    </div>
  );
};
