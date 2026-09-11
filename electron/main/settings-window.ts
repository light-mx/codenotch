import { BrowserWindow } from 'electron';
import path from 'path';

export class SettingsWindowController {
  private window: BrowserWindow | null = null;

  show() {
    if (this.window && !this.window.isDestroyed()) {
      this.window.show();
      this.window.focus();
      return;
    }

    this.window = new BrowserWindow({
      width: 500,
      height: 560,
      title: 'Codenotch Settings',
      resizable: false,
      minimizable: false,
      maximizable: false,
      fullscreenable: false,
      titleBarStyle: 'hiddenInset',
      backgroundColor: '#1E1E1E',
      webPreferences: {
        preload: path.join(__dirname, '../preload/index.js'),
        contextIsolation: true,
        nodeIntegration: false
      }
    });

    if (process.env.VITE_DEV_SERVER_URL) {
      this.window.loadURL(`${process.env.VITE_DEV_SERVER_URL}?view=settings`);
    } else {
      this.window.loadFile(path.join(__dirname, '../../dist/index.html'), { query: { view: 'settings' } });
    }

    this.window.on('closed', () => {
      this.window = null;
    });
  }
}

export class WhatsNewWindowController {
  private window: BrowserWindow | null = null;

  show() {
    if (this.window && !this.window.isDestroyed()) {
      this.window.show();
      this.window.focus();
      return;
    }

    this.window = new BrowserWindow({
      width: 420,
      height: 440,
      title: "What's New in Codenotch",
      resizable: false,
      minimizable: false,
      maximizable: false,
      fullscreenable: false,
      titleBarStyle: 'hiddenInset',
      backgroundColor: '#1E1E1E',
      webPreferences: {
        preload: path.join(__dirname, '../preload/index.js'),
        contextIsolation: true,
        nodeIntegration: false
      }
    });

    if (process.env.VITE_DEV_SERVER_URL) {
      this.window.loadURL(`${process.env.VITE_DEV_SERVER_URL}?view=whats-new`);
    } else {
      this.window.loadFile(path.join(__dirname, '../../dist/index.html'), { query: { view: 'whats-new' } });
    }

    this.window.on('closed', () => {
      this.window = null;
    });
  }
}
