import React, { useMemo } from 'react';
import { NotchEdge } from '../../types';
import { NotchLayout } from '../../design/geometry';
import { Palette } from '../../design/tokens';

interface SideNotchShapeProps {
  width: number;
  height: number;
  edge: NotchEdge;
  curlRadius?: number;
  cornerRadius?: number;
  className?: string;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}

export const SideNotchShape: React.FC<SideNotchShapeProps> = ({
  width,
  height,
  edge,
  curlRadius = NotchLayout.curlRadius,
  cornerRadius = NotchLayout.cornerRadius,
  className = '',
  style = {},
  children
}) => {
  const pathData = useMemo(() => {
    // Canonical space:
    // depth across the shape, length along it.
    // For right/left: depth = width, length = height.
    // For top/bottom: depth = height, length = width.
    const isVertical = edge === 'right' || edge === 'left';
    const depth = isVertical ? width : height;
    const length = isVertical ? height : width;

    const wanted = Math.max(0, Math.min(cornerRadius, depth / 2));
    const curl = Math.max(0, Math.min(curlRadius, length / 2, depth - wanted));
    const corner = Math.max(0, Math.min(wanted, (length - 2 * curl) / 2));

    const bodyTop = curl;
    const bodyBottom = length - curl;

    // Canonical points (bezel at x = depth, flat edge from y = 0 to length)
    // In SVG:
    // M depth 0
    // Flare into body: A curl curl 0 0 0 (depth - curl) curl
    // L (depth - wanted) bodyTop -> L corner bodyTop
    // A corner corner 0 0 0 0 (bodyTop + corner)
    // L 0 (bodyBottom - corner)
    // A corner corner 0 0 0 corner bodyBottom
    // L (depth - curl) bodyBottom
    // Flare back out: A curl curl 0 0 0 depth length
    // Z

    // Build path directly for each orientation
    switch (edge) {
      case 'right': {
        // Bezel is at x = width (right)
        return [
          `M ${width} 0`,
          curl > 0 ? `A ${curl} ${curl} 0 0 0 ${width - curl} ${bodyTop}` : `L ${width} ${bodyTop}`,
          `L ${corner} ${bodyTop}`,
          corner > 0 ? `A ${corner} ${corner} 0 0 0 0 ${bodyTop + corner}` : `L 0 ${bodyTop}`,
          `L 0 ${bodyBottom - corner}`,
          corner > 0 ? `A ${corner} ${corner} 0 0 0 ${corner} ${bodyBottom}` : `L 0 ${bodyBottom}`,
          `L ${width - curl} ${bodyBottom}`,
          curl > 0 ? `A ${curl} ${curl} 0 0 0 ${width} ${length}` : `L ${width} ${length}`,
          'Z'
        ].join(' ');
      }
      case 'left': {
        // Bezel is at x = 0 (left)
        return [
          `M 0 0`,
          curl > 0 ? `A ${curl} ${curl} 0 0 1 ${curl} ${bodyTop}` : `L 0 ${bodyTop}`,
          `L ${width - corner} ${bodyTop}`,
          corner > 0 ? `A ${corner} ${corner} 0 0 1 ${width} ${bodyTop + corner}` : `L ${width} ${bodyTop}`,
          `L ${width} ${bodyBottom - corner}`,
          corner > 0 ? `A ${corner} ${corner} 0 0 1 ${width - corner} ${bodyBottom}` : `L ${width} ${bodyBottom}`,
          `L ${curl} ${bodyBottom}`,
          curl > 0 ? `A ${curl} ${curl} 0 0 1 0 ${length}` : `L 0 ${length}`,
          'Z'
        ].join(' ');
      }
      case 'top': {
        // Bezel is at y = 0 (top)
        return [
          `M 0 0`,
          curl > 0 ? `A ${curl} ${curl} 0 0 0 ${curl} ${height - corner}` : `L 0 ${height}`,
          `L ${length - curl} ${height}`,
          curl > 0 ? `A ${curl} ${curl} 0 0 0 ${length} 0` : `L ${length} 0`,
          'Z'
        ].join(' ');
      }
      case 'bottom': {
        // Bezel is at y = height (bottom)
        return [
          `M 0 ${height}`,
          curl > 0 ? `A ${curl} ${curl} 0 0 0 ${curl} ${corner}` : `L 0 0`,
          `L ${length - curl} 0`,
          curl > 0 ? `A ${curl} ${curl} 0 0 0 ${length} ${height}` : `L ${length} ${height}`,
          'Z'
        ].join(' ');
      }
    }
  }, [width, height, edge, curlRadius, cornerRadius]);

  return (
    <div
      className={`relative ${className}`}
      style={{
        width,
        height,
        ...style
      }}
    >
      <svg
        width={width}
        height={height}
        viewBox={`0 0 ${width} ${height}`}
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          pointerEvents: 'none'
        }}
      >
        <path d={pathData} fill={Palette.notch} />
      </svg>
      {children && (
        <div
          style={{
            position: 'relative',
            width: '100%',
            height: '100%',
            zIndex: 1
          }}
        >
          {children}
        </div>
      )}
    </div>
  );
};
