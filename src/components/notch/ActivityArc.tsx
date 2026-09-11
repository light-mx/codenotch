import React from 'react';
import { ActivitySummary } from '../../types';
import { NotchLayout } from '../../design/geometry';

interface ActivityArcProps {
  summary: ActivitySummary;
}

export const ActivityArc: React.FC<ActivityArcProps> = ({ summary }) => {
  if (!summary || summary.state === 'idle') return null;

  const diameter = NotchLayout.ringDiameter;
  const actDiameter = NotchLayout.activityDiameter;
  const stroke = NotchLayout.activityStroke;
  const radius = (actDiameter - stroke) / 2;
  const circumference = 2 * Math.PI * radius;
  const color = summary.color;

  if (summary.state === 'busy') {
    // 25% arc spinning continuously
    const arcLength = circumference * 0.25;
    return (
      <div
        className="absolute inset-0 flex items-center justify-center pointer-events-none"
        style={{ width: diameter, height: diameter }}
      >
        <svg
          width={actDiameter}
          height={actDiameter}
          viewBox={`0 0 ${actDiameter} ${actDiameter}`}
          style={{ animation: 'spin 1.1s linear infinite' }}
        >
          <circle
            cx={actDiameter / 2}
            cy={actDiameter / 2}
            r={radius}
            stroke={color}
            strokeWidth={stroke}
            strokeDasharray={`${arcLength} ${circumference}`}
            strokeLinecap="round"
            fill="none"
          />
        </svg>
        <style>{`
          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  // Pulsing ring for waiting
  return (
    <div
      className="absolute inset-0 flex items-center justify-center pointer-events-none"
      style={{ width: diameter, height: diameter }}
    >
      <svg
        width={actDiameter}
        height={actDiameter}
        viewBox={`0 0 ${actDiameter} ${actDiameter}`}
        style={{ animation: 'pulse 0.9s ease-in-out infinite alternate' }}
      >
        <circle
          cx={actDiameter / 2}
          cy={actDiameter / 2}
          r={radius}
          stroke={color}
          strokeWidth={stroke}
          fill="none"
        />
      </svg>
      <style>{`
        @keyframes pulse {
          from { opacity: 1; }
          to { opacity: 0.3; }
        }
      `}</style>
    </div>
  );
};
