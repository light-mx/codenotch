import React, { useState } from 'react';
import { Settings } from 'lucide-react';
import { NotchEdge } from '../../types';
import { NotchLayout } from '../../design/geometry';
import { Palette } from '../../design/tokens';

interface SettingsOrbProps {
  edge?: NotchEdge;
  onClick?: () => void;
}

export const SettingsOrb: React.FC<SettingsOrbProps> = ({
  edge = 'right',
  onClick
}) => {
  const [isHovered, setIsHovered] = useState(false);

  const orbDiameter = NotchLayout.orbDiameter;
  const orbStroke = NotchLayout.orbStroke;
  const arcRadius = NotchLayout.orbArcRadius;

  const rotation = edge === 'right' ? -90 : edge === 'left' ? 90 : edge === 'top' ? 180 : 0;
  const circumference = 2 * Math.PI * arcRadius;
  const arcLength = circumference * 0.25;

  return (
    <div
      className="relative cursor-pointer select-none flex items-center justify-center"
      style={{
        width: arcRadius * 2 + orbStroke,
        height: arcRadius * 2 + orbStroke,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        position: 'relative'
      }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onClick={onClick}
      title="Settings"
    >
      {/* Resting Arc (Concentric with bottom flare) */}
      <svg
        width={arcRadius * 2 + orbStroke}
        height={arcRadius * 2 + orbStroke}
        style={{
          position: 'absolute',
          transform: `rotate(${rotation}deg)`,
          opacity: isHovered ? 0 : 1,
          transformOrigin: 'center',
          transition: 'opacity 0.28s ease, transform 0.35s cubic-bezier(0.36, 0, 0.2, 1)',
          pointerEvents: 'none'
        }}
      >
        <circle
          cx={(arcRadius * 2 + orbStroke) / 2}
          cy={(arcRadius * 2 + orbStroke) / 2}
          r={arcRadius}
          stroke={Palette.notch}
          strokeWidth={orbStroke}
          strokeDasharray={`${arcLength} ${circumference}`}
          strokeLinecap="round"
          fill="none"
        />
      </svg>

      {/* Hovered Gear Circle */}
      <div
        style={{
          width: orbDiameter,
          height: orbDiameter,
          borderRadius: '50%',
          backgroundColor: Palette.notch,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          opacity: isHovered ? 1 : 0,
          transform: isHovered ? 'scale(1)' : 'scale(0.8)',
          transition: 'opacity 0.25s ease, transform 0.32s cubic-bezier(0.34, 1.56, 0.64, 1)',
          color: Palette.textPrimary,
          boxShadow: '0 4px 12px rgba(0,0,0,0.4)'
        }}
      >
        <Settings
          size={NotchLayout.orbGlyph}
          style={{
            transform: isHovered ? 'rotate(0deg)' : 'rotate(-60deg)',
            transition: 'transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)'
          }}
        />
      </div>
    </div>
  );
};
