import { BrowserWindow, screen } from 'electron';
import path from 'path';
import { NotchGeometry } from './geometry';
import { UserPreferences } from '../../src/types';
import { NotchLayout } from '../../src/design/geometry';

export class NotchWindowController {
  private window: BrowserWindow | null = null;
  private preferences: UserPreferences;

  constructor(preferences: UserPreferences) {
    this.preferences = preferences;
  }

  get browserWindow(): BrowserWindow | null {
    return this.window;
  }

  create(): BrowserWindow {
    const display = screen.getPrimaryDisplay();
    const edge = this.preferences.notchEdge;
    const isVertical = NotchLayout.isVertical(edge);

    // Panel size must hold the notch body, settings orb, and tooltip slack
    const panelWidth = isVertical ? NotchLayout.sideBodyDepth + NotchLayout.cardWidth + NotchLayout.tailLength + 60 : 700;
    const panelHeight = isVertical ? 650 : NotchLayout.bodyDepth(edge) + NotchLayout.cardWidth + 60;

    const bounds = NotchGeometry.calculatePanelFrame(display, { width: panelWidth, height: panelHeight }, edge);

    this.window = new BrowserWindow({
      x: bounds.x,
      y: bounds.y,
      width: bounds.width,
      height: bounds.height,
      type: 'panel',
      transparent: true,
      frame: false,
      hasShadow: false,
      focusable: false,
      skipTaskbar: true,
      alwaysOnTop: true,
      webPreferences: {
        preload: path.join(__dirname, '../preload/index.js'),
        contextIsolation: true,
        nodeIntegration: false,
        backgroundThrottling: false
      }
    });

    // macOS native window levels & workspace behavior
    this.window.setAlwaysOnTop(true, 'screen-saver');
    this.window.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });

    // Initial click-through with forward: true
    this.window.setIgnoreMouseEvents(true, { forward: true });

    // Load React renderer
    if (process.env.VITE_DEV_SERVER_URL) {
      this.window.loadURL(process.env.VITE_DEV_SERVER_URL);
    } else {
      this.window.loadFile(path.join(__dirname, '../../dist/index.html'));
    }

    this.window.on('closed', () => {
      this.window = null;
    });

    // Re-anchor when display metrics change
    screen.on('display-metrics-changed', () => {
      this.reposition();
    });

    return this.window;
  }

  reposition(edge = this.preferences.notchEdge) {
    if (!this.window) return;
    this.preferences.notchEdge = edge;
    const display = screen.getPrimaryDisplay();
    const isVertical = NotchLayout.isVertical(edge);

    const panelWidth = isVertical ? NotchLayout.sideBodyDepth + NotchLayout.cardWidth + NotchLayout.tailLength + 60 : 700;
    const panelHeight = isVertical ? 650 : NotchLayout.bodyDepth(edge) + NotchLayout.cardWidth + 60;

    const bounds = NotchGeometry.calculatePanelFrame(display, { width: panelWidth, height: panelHeight }, edge);
    this.window.setBounds(bounds);
  }

  setIgnoreMouseEvents(ignore: boolean) {
    if (this.window && !this.window.isDestroyed()) {
      if (ignore) {
        this.window.setIgnoreMouseEvents(true, { forward: true });
      } else {
        this.window.setIgnoreMouseEvents(false);
      }
    }
  }
}
