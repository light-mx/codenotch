import { app, BrowserWindow, ipcMain, Menu, shell } from 'electron';
import { PreferencesManager } from './preferences';
import { UsageStore } from './providers/usage-store';
import { ClaudeSessionMonitor } from './sessions/claude-session-monitor';
import { NotchWindowController } from './notch-window';
import { SettingsWindowController, WhatsNewWindowController } from './settings-window';
import { TrayController } from './tray';

// Ensure single instance
const gotTheLock = app.requestSingleInstanceLock();
if (!gotTheLock) {
  app.quit();
}

let notchController: NotchWindowController | null = null;
let settingsController: SettingsWindowController | null = null;
let whatsNewController: WhatsNewWindowController | null = null;
let trayController: TrayController | null = null;
let usageStore: UsageStore | null = null;
let sessionMonitor: ClaudeSessionMonitor | null = null;
let preferencesManager: PreferencesManager | null = null;

app.whenReady().then(() => {
  preferencesManager = new PreferencesManager();
  const prefs = preferencesManager.preferences;

  // Configure Dock icon visibility based on appPresence
  if (process.platform === 'darwin') {
    if (prefs.appPresence === 'dock' || prefs.appPresence === 'both') {
      app.dock.show();
    } else {
      app.dock.hide();
    }
  }

  // Initialize UsageStore
  usageStore = new UsageStore(() => preferencesManager!.preferences);

  // Initialize Controllers
  notchController = new NotchWindowController(prefs);
  const notchWindow = notchController.create();

  settingsController = new SettingsWindowController();
  whatsNewController = new WhatsNewWindowController();

  // Initialize Tray
  if (prefs.appPresence === 'menubar' || prefs.appPresence === 'both') {
    trayController = new TrayController({
      onOpenSettings: () => settingsController?.show(),
      onRefresh: () => usageStore?.poll(),
      onToggleDemo: () => {
        const newDemo = !preferencesManager!.preferences.demoMode;
        preferencesManager!.save({ demoMode: newDemo });
        broadcastPreferences();
        usageStore?.poll();
      },
      isDemoMode: () => preferencesManager!.preferences.demoMode
    });
    trayController.create();
  }

  // Hook usage store updates to notch window
  usageStore.onUpdate(snapshots => {
    if (notchWindow && !notchWindow.isDestroyed()) {
      notchWindow.webContents.send('snapshots-updated', snapshots);
    }
  });

  // Start polling
  usageStore.startPolling(60000);

  // Initialize Claude session monitor
  sessionMonitor = new ClaudeSessionMonitor();
  sessionMonitor.onUpdate(summary => {
    if (notchWindow && !notchWindow.isDestroyed()) {
      notchWindow.webContents.send('activities-updated', { [summary.providerId]: summary });
    }
  });
  sessionMonitor.start(5000);

  // Show What's New if first time or version changed
  const currentVersion = app.getVersion();
  if (prefs.lastSeenVersion !== currentVersion) {
    preferencesManager.save({ lastSeenVersion: currentVersion });
    whatsNewController.show();
  }
});

function broadcastPreferences() {
  if (!preferencesManager) return;
  const prefs = preferencesManager.preferences;
  const windows = BrowserWindow.getAllWindows();
  for (const win of windows) {
    if (!win.isDestroyed()) {
      win.webContents.send('preferences-updated', prefs);
    }
  }
}

// IPC Handlers
ipcMain.handle('get-preferences', () => {
  return preferencesManager?.preferences;
});

ipcMain.handle('update-preferences', (_, updates) => {
  const newPrefs = preferencesManager?.save(updates);
  if (updates.notchEdge && notchController) {
    notchController.reposition(updates.notchEdge);
  }
  if (updates.appPresence && process.platform === 'darwin') {
    if (updates.appPresence === 'dock' || updates.appPresence === 'both') {
      app.dock.show();
    } else {
      app.dock.hide();
    }
  }
  broadcastPreferences();
  trayController?.updateMenu();
  return newPrefs;
});

ipcMain.handle('get-snapshots', () => {
  return usageStore?.getSnapshots() || [];
});

ipcMain.handle('get-provider-summaries', () => {
  return usageStore?.getSummaries() || [];
});

ipcMain.on('set-ignore-mouse-events', (_, ignore) => {
  notchController?.setIgnoreMouseEvents(ignore);
});

ipcMain.on('open-settings-window', () => {
  settingsController?.show();
});

ipcMain.on('refresh-now', (_, providerId) => {
  usageStore?.poll(providerId);
});

ipcMain.on('sign-out', (_, providerId) => {
  if (preferencesManager) {
    const disconnected = new Set(preferencesManager.preferences.disconnectedProviders);
    disconnected.add(providerId);
    preferencesManager.save({ disconnectedProviders: Array.from(disconnected) });
    broadcastPreferences();
    usageStore?.poll();
  }
});

ipcMain.on('sign-in', (_, providerId) => {
  if (preferencesManager) {
    const disconnected = new Set(preferencesManager.preferences.disconnectedProviders);
    disconnected.delete(providerId);
    preferencesManager.save({ disconnectedProviders: Array.from(disconnected) });
    broadcastPreferences();
    usageStore?.poll();
  }
});

ipcMain.on('retry-provider', (_, providerId) => {
  usageStore?.poll(providerId);
});

ipcMain.on('open-external', (_, url) => {
  if (url) shell.openExternal(url);
});

ipcMain.on('show-context-menu', () => {
  const menu = Menu.buildFromTemplate([
    {
      label: 'Settings…',
      click: () => settingsController?.show()
    },
    {
      label: 'Refresh now',
      click: () => usageStore?.poll()
    },
    {
      label: 'Demo Mode',
      type: 'checkbox',
      checked: preferencesManager?.preferences.demoMode ?? false,
      click: () => {
        const newDemo = !preferencesManager!.preferences.demoMode;
        preferencesManager!.save({ demoMode: newDemo });
        broadcastPreferences();
        usageStore?.poll();
        trayController?.updateMenu();
      }
    },
    { type: 'separator' },
    {
      label: 'Quit Codenotch',
      click: () => app.quit()
    }
  ]);

  menu.popup();
});

app.on('window-all-closed', () => {
  // Agent / Notch apps remain running even when settings or dialog windows close
});
