import { contextBridge, ipcRenderer } from 'electron';
import { UserPreferences, ProviderSnapshot, ActivitySummary, ProviderSummary } from '../../src/types';

export interface CodenotchAPI {
  getPreferences: () => Promise<UserPreferences>;
  updatePreferences: (updates: Partial<UserPreferences>) => Promise<UserPreferences>;
  getSnapshots: () => Promise<ProviderSnapshot[]>;
  getProviderSummaries: () => Promise<ProviderSummary[]>;
  setIgnoreMouseEvents: (ignore: boolean) => void;
  openSettingsWindow: () => void;
  showContextMenu: () => void;
  refreshNow: (providerId?: string) => void;
  signOut: (providerId: string) => void;
  signIn: (providerId: string) => void;
  retry: (providerId: string) => void;
  openExternal: (url: string) => void;

  onSnapshotsUpdate: (callback: (snapshots: ProviderSnapshot[]) => void) => () => void;
  onActivitiesUpdate: (callback: (activities: Record<string, ActivitySummary>) => void) => () => void;
  onPreferencesUpdate: (callback: (preferences: UserPreferences) => void) => () => void;
  onOpenSettings: (callback: () => void) => () => void;
  onOpenWhatsNew: (callback: () => void) => () => void;
}

const api: CodenotchAPI = {
  getPreferences: () => ipcRenderer.invoke('get-preferences'),
  updatePreferences: (updates) => ipcRenderer.invoke('update-preferences', updates),
  getSnapshots: () => ipcRenderer.invoke('get-snapshots'),
  getProviderSummaries: () => ipcRenderer.invoke('get-provider-summaries'),
  setIgnoreMouseEvents: (ignore: boolean) => ipcRenderer.send('set-ignore-mouse-events', ignore),
  openSettingsWindow: () => ipcRenderer.send('open-settings-window'),
  showContextMenu: () => ipcRenderer.send('show-context-menu'),
  refreshNow: (providerId) => ipcRenderer.send('refresh-now', providerId),
  signOut: (providerId) => ipcRenderer.send('sign-out', providerId),
  signIn: (providerId) => ipcRenderer.send('sign-in', providerId),
  retry: (providerId) => ipcRenderer.send('retry-provider', providerId),
  openExternal: (url: string) => ipcRenderer.send('open-external', url),

  onSnapshotsUpdate: (callback) => {
    const handler = (_: any, data: ProviderSnapshot[]) => callback(data);
    ipcRenderer.on('snapshots-updated', handler);
    return () => ipcRenderer.removeListener('snapshots-updated', handler);
  },
  onActivitiesUpdate: (callback) => {
    const handler = (_: any, data: Record<string, ActivitySummary>) => callback(data);
    ipcRenderer.on('activities-updated', handler);
    return () => ipcRenderer.removeListener('activities-updated', handler);
  },
  onPreferencesUpdate: (callback) => {
    const handler = (_: any, data: UserPreferences) => callback(data);
    ipcRenderer.on('preferences-updated', handler);
    return () => ipcRenderer.removeListener('preferences-updated', handler);
  },
  onOpenSettings: (callback) => {
    const handler = () => callback();
    ipcRenderer.on('open-settings', handler);
    return () => ipcRenderer.removeListener('open-settings', handler);
  },
  onOpenWhatsNew: (callback) => {
    const handler = () => callback();
    ipcRenderer.on('open-whats-new', handler);
    return () => ipcRenderer.removeListener('open-whats-new', handler);
  }
};

contextBridge.exposeInMainWorld('codenotch', api);

declare global {
  interface Window {
    codenotch: CodenotchAPI;
  }
}
