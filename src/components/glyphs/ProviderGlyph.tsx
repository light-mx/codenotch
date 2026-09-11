import React, { useMemo } from 'react';
import glyphsData from '../../design/glyphs.json';
import { ProviderGlyphId } from '../../types';
import { NotchLayout } from '../../design/geometry';

interface ProviderGlyphProps {
  glyph: ProviderGlyphId;
  size?: number;
  className?: string;
  style?: React.CSSProperties;
}

const OPTICAL_SCALES: Record<string, number> = {
  claude: 0.97,
  cursor: 0.97,
  openai: 0.94,
  gemini: 1.0,
  antigravity: 1.0,
  glm: 0.95,
  grok: 1.0,
  opencode: 0.95,
  third: 1.0
};

export const ProviderGlyph: React.FC<ProviderGlyphProps> = ({
  glyph,
  size = NotchLayout.glyphSize,
  className = '',
  style = {}
}) => {
  const loops = (glyphsData as Record<string, Array<Array<{ x: number; y: number }>>>)[glyph] ||
                (glyphsData as Record<string, Array<Array<{ x: number; y: number }>>>)['claude'] ||
                [];

  const pathData = useMemo(() => {
    return loops
      .map(loop => {
        if (!loop || loop.length === 0) return '';
        const first = loop[0];
        let d = `M ${first.x} ${first.y}`;
        for (let i = 1; i < loop.length; i++) {
          d += ` L ${loop[i].x} ${loop[i].y}`;
        }
        d += ' Z';
        return d;
      })
      .join(' ');
  }, [loops]);

  const scale = OPTICAL_SCALES[glyph] || 1.0;

  return (
    <div
      className={`inline-flex items-center justify-center ${className}`}
      style={{
        width: size,
        height: size,
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        ...style
      }}
    >
      <svg
        viewBox="0 0 1 1"
        style={{
          width: size * scale,
          height: size * scale,
          overflow: 'visible'
        }}
      >
        <path
          d={pathData}
          fill="currentColor"
          fillRule="evenodd"
          clipRule="evenodd"
        />
      </svg>
    </div>
  );
};
