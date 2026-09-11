import React, { useState, useEffect } from 'react';
import { ProviderSnapshot, ActivitySummary, UserPreferences, ProviderSummary } from './types';
import { NotchRoot } from './components/notch/NotchRoot';
import { SettingsView } from './components/settings/SettingsView';
import { WhatsNewView } from './components/whats-new/WhatsNewView';

// Default preferences
const defaultPreferences: UserPreferences = {
  disconnectedProviders: [],
  notchVisibility: 'always',
  notchEdge: 'right',
  appPresence: 'menubar',
  launchAtLogin: false,
  demoMode: false
};

// Default fallback fixtures matching Figma frame-124
const defaultSnapshots: ProviderSnapshot[] = [
  {
    id: 'claude',
    displayName: 'Claude',
    glyph: 'claude',
    fidelity: 'derived',
    status: { type: 'ok' },
    windows: [
      {
        id: 'claude.session',
        label: 'Current session',
        usedFraction: 0.73,
        resetsAt: new Date(Date.now() + 51 * 60000).toISOString()
      },
      {
        id: 'claude.all',
        label: 'All models',
        usedFraction: 0.07,
        resetsAt: new Date(Date.now() + 24 * 3600000).toISOString()
      }
    ]
  },
  {
    id: 'openai',
    displayName: 'OpenAI',
    glyph: 'openai',
    fidelity: 'manual',
    status: { type: 'ok' },
    windows: [
      {
        id: 'openai.session',
        label: 'Current session',
        usedFraction: 0.21,
        resetsAt: new Date(Date.now() + 3 * 3600000).toISOString()
      }
    ]
  },
  {
    id: 'third',
    displayName: 'Perplexity',
    glyph: 'third',
    fidelity: 'manual',
    status: { type: 'ok' },
    windows: [
      {
        id: 'third.daily',
        label: 'Daily quota',
        usedFraction: 0.52,
        resetsAt: new Date(Date.now() + 18 * 3600000).toISOString()
      }
    ]
  }
];

export const App: React.FC = () => {
  const [snapshots, setSnapshots] = useState<ProviderSnapshot[]>(defaultSnapshots);
  const [activities, setActivities] = useState<Record<string, ActivitySummary>>({});
  const [preferences, setPreferences] = useState<UserPreferences>(defaultPreferences);
  const [providers, setProviders] = useState<ProviderSummary[]>([]);
  const [showSettingsModal, setShowSettingsModal] = useState(false);
  const [showWhatsNewModal, setShowWhatsNewModal] = useState(false);

  // Check URL query parameters to see if this window is dedicated to settings or what's new
  const params = new URLSearchParams(window.location.search);
  const viewMode = params.get('view');

  useEffect(() => {
    // If running inside Electron, subscribe to IPC bridges
    if (window.codenotch) {
      window.codenotch.getPreferences().then(prefs => {
        if (prefs) setPreferences(prefs);
      });

      window.codenotch.getSnapshots().then(snaps => {
        if (snaps && snaps.length > 0) setSnapshots(snaps);
      });

      window.codenotch.getProviderSummaries().then(sums => {
        if (sums) setProviders(sums);
      });

      const unsubSnaps = window.codenotch.onSnapshotsUpdate(newSnaps => {
        setSnapshots(newSnaps);
      });

      const unsubActivities = window.codenotch.onActivitiesUpdate(newActs => {
        setActivities(newActs);
      });

      const unsubPrefs = window.codenotch.onPreferencesUpdate(newPrefs => {
        setPreferences(newPrefs);
      });

      const unsubOpenSettings = window.codenotch.onOpenSettings(() => {
        setShowSettingsModal(true);
      });

      const unsubOpenWhatsNew = window.codenotch.onOpenWhatsNew(() => {
        setShowWhatsNewModal(true);
      });

      return () => {
        unsubSnaps();
        unsubActivities();
        unsubPrefs();
        unsubOpenSettings();
        unsubOpenWhatsNew();
      };
    }
  }, []);

  const handleUpdatePreferences = (partial: Partial<UserPreferences>) => {
    const updated = { ...preferences, ...partial };
    setPreferences(updated);
    if (window.codenotch) {
      window.codenotch.updatePreferences(partial);
    }
  };

  const handleRefresh = (id?: string) => {
    if (window.codenotch) {
      window.codenotch.refreshNow(id);
    }
  };

  const handleContextMenu = (e: React.MouseEvent) => {
    e.preventDefault();
    if (window.codenotch) {
      window.codenotch.showContextMenu();
    }
  };

  // Dedicated Settings Window View
  if (viewMode === 'settings') {
    return (
      <div className="w-full h-full flex items-center justify-center bg-transparent">
        <SettingsView
          preferences={preferences}
          providers={providers}
          onUpdatePreferences={handleUpdatePreferences}
          onSignOut={id => window.codenotch?.signOut(id)}
          onSignIn={id => window.codenotch?.signIn(id)}
          onRetry={id => window.codenotch?.retry(id)}
        />
      </div>
    );
  }

  // Dedicated What's New Window View
  if (viewMode === 'whats-new') {
    return (
      <div className="w-full h-full flex items-center justify-center bg-transparent">
        <WhatsNewView onContinue={() => window.close()} />
      </div>
    );
  }

  // Main Notch Overlay View
  return (
    <div className="relative w-screen h-screen overflow-hidden bg-transparent">
      <NotchRoot
        snapshots={snapshots}
        activities={activities}
        preferences={preferences}
        onOpenSettings={() => {
          if (window.codenotch) {
            window.codenotch.openSettingsWindow();
          } else {
            setShowSettingsModal(true);
          }
        }}
        onRefresh={handleRefresh}
        onContextMenu={handleContextMenu}
      />

      {/* In-page Settings Modal Fallback */}
      {showSettingsModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
          onClick={() => setShowSettingsModal(false)}
        >
          <div onClick={e => e.stopPropagation()}>
            <SettingsView
              preferences={preferences}
              providers={providers}
              onUpdatePreferences={handleUpdatePreferences}
              onSignOut={id => window.codenotch?.signOut(id)}
              onSignIn={id => window.codenotch?.signIn(id)}
              onRetry={id => window.codenotch?.retry(id)}
              onClose={() => setShowSettingsModal(false)}
            />
          </div>
        </div>
      )}

      {/* In-page What's New Modal Fallback */}
      {showWhatsNewModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
          onClick={() => setShowWhatsNewModal(false)}
        >
          <div onClick={e => e.stopPropagation()}>
            <WhatsNewView onContinue={() => setShowWhatsNewModal(false)} />
          </div>
        </div>
      )}
    </div>
  );
};
