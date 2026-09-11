import React from 'react';
import { Palette } from '../../design/tokens';

interface ChangeItem {
  title: string;
  detail: string;
}

interface WhatsNewViewProps {
  version?: string;
  headline?: string;
  changes?: ChangeItem[];
  onContinue: () => void;
}

export const WhatsNewView: React.FC<WhatsNewViewProps> = ({
  version = '1.0.0',
  headline = 'Welcome to Codenotch for Electron!',
  changes = [
    {
      title: 'Converted to Modern Electron + React',
      detail: 'Complete architectural migration to React 19, TypeScript, and high-performance Electron with 100% design fidelity.'
    },
    {
      title: 'Pixel-Perfect Screen-Edge Notch',
      detail: 'Mathematically exact inverse rounded flares, smooth resting pill hover expansion, and concentric settings orb.'
    },
    {
      title: 'Unified Coding Assistant Monitoring',
      detail: 'Tracks limits and live sessions for Claude Code, Cursor, Codex, Antigravity, GLM, Grok, and OpenCode.'
    },
    {
      title: 'Instant Demo Mode',
      detail: 'Easily preview the design spec from Figma Frame 124 at any time via Settings or right-click menu.'
    }
  ],
  onContinue
}) => {
  return (
    <div
      className="flex flex-col select-none text-[#E0E0E0]"
      style={{
        width: '420px',
        height: '440px',
        backgroundColor: '#1E1E1E',
        borderRadius: '12px',
        overflow: 'hidden',
        display: 'flex',
        flexDirection: 'column',
        boxShadow: '0 16px 40px rgba(0, 0, 0, 0.6)',
        border: '1px solid rgba(255, 255, 255, 0.12)',
        fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif'
      }}
    >
      {/* Header */}
      <div
        style={{
          padding: '26px 28px 16px',
          textAlign: 'center',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: '6px'
        }}
      >
        <img
          src="/app-icon.png"
          alt="Codenotch"
          style={{ width: '60px', height: '60px', borderRadius: '14px', marginBottom: '8px' }}
        />
        <div style={{ fontSize: '19px', fontWeight: 600, color: '#FFFFFF' }}>
          What's new in Codenotch
        </div>
        <div style={{ fontSize: '12px', color: '#888888' }}>
          Version {version}
        </div>
        <div style={{ fontSize: '13px', color: '#BBBBBB', marginTop: '4px' }}>
          {headline}
        </div>
      </div>

      {/* Changes list */}
      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: '8px 28px',
          display: 'flex',
          flexDirection: 'column',
          gap: '14px'
        }}
      >
        {changes.map((c, idx) => (
          <div key={idx} style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
            <span
              style={{
                width: '6px',
                height: '6px',
                borderRadius: '50%',
                backgroundColor: Palette.ample,
                marginTop: '6px',
                flexShrink: 0
              }}
            />
            <div>
              <div style={{ fontSize: '13px', fontWeight: 500, color: '#FFFFFF' }}>{c.title}</div>
              <div style={{ fontSize: '12px', color: '#888888', lineHeight: '1.35', marginTop: '2px' }}>
                {c.detail}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Footer */}
      <div
        style={{
          padding: '16px 24px',
          borderTop: '1px solid #2C2C2C',
          display: 'flex',
          justifyContent: 'flex-end',
          backgroundColor: '#242424'
        }}
      >
        <button
          onClick={onContinue}
          style={{
            padding: '6px 16px',
            fontSize: '13px',
            fontWeight: 500,
            borderRadius: '6px',
            backgroundColor: '#007AFF',
            color: '#FFFFFF',
            border: 'none',
            cursor: 'pointer'
          }}
        >
          Continue
        </button>
      </div>
    </div>
  );
};
