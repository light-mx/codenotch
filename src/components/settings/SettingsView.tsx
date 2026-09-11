import React from 'react';
import { UserPreferences, ProviderSummary } from '../../types';
import { ProviderGlyph } from '../glyphs/ProviderGlyph';
import { Sparkles, ExternalLink, X } from 'lucide-react';

interface SettingsViewProps {
  preferences: UserPreferences;
  providers: ProviderSummary[];
  onUpdatePreferences: (updates: Partial<UserPreferences>) => void;
  onSignOut: (id: string) => void;
  onSignIn: (id: string) => void;
  onRetry: (id: string) => void;
  onClose?: () => void;
}

export const SettingsView: React.FC<SettingsViewProps> = ({
  preferences,
  providers,
  onUpdatePreferences,
  onSignOut,
  onSignIn,
  onRetry,
  onClose
}) => {
  const needsSetup = providers.every(p => !p.account);

  return (
    <div
      className="flex flex-col select-none text-[#E0E0E0]"
      style={{
        width: '500px',
        height: '560px',
        backgroundColor: '#1E1E1E',
        borderRadius: '12px',
        overflow: 'hidden',
        display: 'flex',
        flexDirection: 'column',
        boxShadow: '0 16px 40px rgba(0, 0, 0, 0.6)',
        border: '1px solid rgba(255, 255, 255, 0.12)',
        fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif'
      }}
    >
      {/* Title Bar */}
      <div
        className="flex items-center justify-between px-4 py-3 border-b border-[#2C2C2C]"
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '12px 16px',
          borderBottom: '1px solid #2C2C2C',
          backgroundColor: '#252525'
        }}
      >
        <span style={{ fontSize: '13px', fontWeight: 600, color: '#FFFFFF' }}>Codenotch Settings</span>
        {onClose && (
          <button
            onClick={onClose}
            className="text-[#888888] hover:text-white transition-colors"
            style={{ background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center' }}
          >
            <X size={16} />
          </button>
        )}
      </div>

      {/* Scrollable Form Body */}
      <div
        className="flex-1 overflow-y-auto px-6 py-4 space-y-6"
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: '16px 24px',
          display: 'flex',
          flexDirection: 'column',
          gap: '20px'
        }}
      >
        {/* Section 1: Integrations */}
        <div>
          <div style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', color: '#888888', marginBottom: '8px' }}>
            Integrations
          </div>

          {needsSetup && (
            <div
              className="flex items-start gap-3 p-3 rounded-lg mb-3"
              style={{
                backgroundColor: 'rgba(255, 149, 0, 0.12)',
                border: '1px solid rgba(255, 149, 0, 0.25)',
                borderRadius: '8px',
                padding: '12px',
                marginBottom: '12px',
                display: 'flex',
                gap: '10px'
              }}
            >
              <Sparkles size={18} style={{ color: '#FF9500', flexShrink: 0, marginTop: '2px' }} />
              <div style={{ fontSize: '12px', lineHeight: '1.4' }}>
                <div style={{ fontWeight: 600, color: '#FF9500', marginBottom: '2px' }}>Connect an assistant to get started</div>
                <div style={{ color: '#CCCCCC' }}>
                  Codenotch reads usage from tools already signed in on this Mac — install and sign in to Claude Code, Cursor, Codex, Antigravity, GLM, Grok, or OpenCode.
                </div>
              </div>
            </div>
          )}

          <div
            className="rounded-lg divide-y divide-[#2C2C2C]"
            style={{
              backgroundColor: '#262626',
              borderRadius: '8px',
              border: '1px solid #333333',
              overflow: 'hidden'
            }}
          >
            {providers.map(p => {
              const isConnected = !preferences.disconnectedProviders.includes(p.id);

              return (
                <div
                  key={p.id}
                  className="flex items-center justify-between px-3 py-2.5"
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '10px 14px',
                    borderBottom: '1px solid #303030'
                  }}
                >
                  <div className="flex items-center gap-3" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <ProviderGlyph glyph={p.glyph} size={20} style={{ color: isConnected ? '#FFFFFF' : '#666666' }} />
                    <div>
                      <div style={{ fontSize: '13px', fontWeight: 500, color: isConnected ? '#FFFFFF' : '#888888' }}>
                        {p.name}
                      </div>
                      <div style={{ fontSize: '11px', color: '#777777' }}>
                        {isConnected ? p.account?.label || p.account?.plan || 'Connected' : 'Signed out'}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    {isConnected && p.wasRefusedAccess && (
                      <button
                        onClick={() => onRetry(p.id)}
                        className="px-2 py-1 text-xs rounded bg-[#FF9500] text-black font-medium hover:bg-opacity-90"
                        style={{ padding: '4px 8px', fontSize: '11px', borderRadius: '4px', border: 'none', cursor: 'pointer', background: '#FF9500', color: '#000' }}
                      >
                        Allow access…
                      </button>
                    )}

                    {/* Toggle Switch */}
                    <input
                      type="checkbox"
                      checked={isConnected}
                      onChange={(e) => {
                        const checked = e.target.checked;
                        const disconnected = new Set(preferences.disconnectedProviders);
                        if (checked) {
                          disconnected.delete(p.id);
                          onSignIn(p.id);
                        } else {
                          disconnected.add(p.id);
                          onSignOut(p.id);
                        }
                        onUpdatePreferences({ disconnectedProviders: Array.from(disconnected) });
                      }}
                      style={{ cursor: 'pointer' }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Section 2: Appearance */}
        <div>
          <div style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', color: '#888888', marginBottom: '8px' }}>
            Appearance
          </div>

          <div
            className="p-3.5 rounded-lg space-y-4"
            style={{
              backgroundColor: '#262626',
              borderRadius: '8px',
              border: '1px solid #333333',
              display: 'flex',
              flexDirection: 'column',
              gap: '14px',
              padding: '14px'
            }}
          >
            {/* Show Visibility */}
            <div className="flex items-center justify-between" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '13px' }}>Show</span>
              <div className="flex rounded bg-[#1A1A1A] p-0.5 border border-[#3A3A3A]" style={{ display: 'flex', borderRadius: '6px', background: '#1A1A1A', padding: '2px' }}>
                {(['always', 'hover', 'never'] as const).map(mode => (
                  <button
                    key={mode}
                    onClick={() => onUpdatePreferences({ notchVisibility: mode })}
                    style={{
                      padding: '4px 10px',
                      fontSize: '11px',
                      borderRadius: '4px',
                      border: 'none',
                      cursor: 'pointer',
                      background: preferences.notchVisibility === mode ? '#3A3A3A' : 'transparent',
                      color: preferences.notchVisibility === mode ? '#FFFFFF' : '#888888'
                    }}
                  >
                    {mode === 'always' ? 'Always' : mode === 'hover' ? 'On hover' : 'Never'}
                  </button>
                ))}
              </div>
            </div>

            {/* Edge Pinning */}
            <div className="flex items-center justify-between" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '13px' }}>Edge</span>
              <div className="flex rounded bg-[#1A1A1A] p-0.5 border border-[#3A3A3A]" style={{ display: 'flex', borderRadius: '6px', background: '#1A1A1A', padding: '2px' }}>
                {(['right', 'left', 'top', 'bottom'] as const).map(edge => (
                  <button
                    key={edge}
                    onClick={() => onUpdatePreferences({ notchEdge: edge })}
                    style={{
                      padding: '4px 8px',
                      fontSize: '11px',
                      borderRadius: '4px',
                      border: 'none',
                      cursor: 'pointer',
                      background: preferences.notchEdge === edge ? '#3A3A3A' : 'transparent',
                      color: preferences.notchEdge === edge ? '#FFFFFF' : '#888888'
                    }}
                  >
                    {edge.charAt(0).toUpperCase() + edge.slice(1)}
                  </button>
                ))}
              </div>
            </div>

            {/* App Icon Presence */}
            <div className="flex items-center justify-between" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '13px' }}>App icon</span>
              <div className="flex rounded bg-[#1A1A1A] p-0.5 border border-[#3A3A3A]" style={{ display: 'flex', borderRadius: '6px', background: '#1A1A1A', padding: '2px' }}>
                {(['nowhere', 'menubar', 'dock', 'both'] as const).map(pres => (
                  <button
                    key={pres}
                    onClick={() => onUpdatePreferences({ appPresence: pres })}
                    style={{
                      padding: '4px 8px',
                      fontSize: '11px',
                      borderRadius: '4px',
                      border: 'none',
                      cursor: 'pointer',
                      background: preferences.appPresence === pres ? '#3A3A3A' : 'transparent',
                      color: preferences.appPresence === pres ? '#FFFFFF' : '#888888'
                    }}
                  >
                    {pres === 'nowhere' ? 'None' : pres === 'menubar' ? 'Menu' : pres === 'dock' ? 'Dock' : 'Both'}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Section 3: General & Demo Mode */}
        <div>
          <div style={{ fontSize: '11px', fontWeight: 600, textTransform: 'uppercase', color: '#888888', marginBottom: '8px' }}>
            General
          </div>

          <div
            className="p-3.5 rounded-lg space-y-3"
            style={{
              backgroundColor: '#262626',
              borderRadius: '8px',
              border: '1px solid #333333',
              display: 'flex',
              flexDirection: 'column',
              gap: '12px',
              padding: '14px'
            }}
          >
            <div className="flex items-center justify-between" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: '13px' }}>Launch at login</div>
                <div style={{ fontSize: '11px', color: '#777777' }}>Open Codenotch automatically when your Mac starts</div>
              </div>
              <input
                type="checkbox"
                checked={preferences.launchAtLogin}
                onChange={(e) => onUpdatePreferences({ launchAtLogin: e.target.checked })}
                style={{ cursor: 'pointer' }}
              />
            </div>

            <div className="flex items-center justify-between" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: '13px' }}>Demo Mode (Figma Mock Data)</div>
                <div style={{ fontSize: '11px', color: '#777777' }}>Shows Claude 73%, OpenAI 21%, Perplexity 52%</div>
              </div>
              <input
                type="checkbox"
                checked={preferences.demoMode}
                onChange={(e) => onUpdatePreferences({ demoMode: e.target.checked })}
                style={{ cursor: 'pointer' }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* Footer Credit */}
      <div
        className="px-6 py-3 border-t border-[#2C2C2C] flex items-center justify-center text-xs text-[#888888]"
        style={{
          borderTop: '1px solid #2C2C2C',
          padding: '10px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '4px',
          backgroundColor: '#202020',
          fontSize: '11px'
        }}
      >
        <span>App designed and developed by</span>
        <a
          href="https://x.com/hivinz_"
          target="_blank"
          rel="noreferrer"
          className="text-[#FFFFFF] hover:underline flex items-center gap-1"
          style={{ color: '#FFFFFF', textDecoration: 'none', fontWeight: 500 }}
        >
          @hivinz_ <ExternalLink size={10} />
        </a>
      </div>
    </div>
  );
};
