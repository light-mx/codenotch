# macOS Notch Geometry & Transparency in Electron

This document details the exact mathematical formulation, window management, and event-forwarding architecture for building screen-edge notch overlays in Electron that feel identical to native macOS AppKit panels.

---

## 1. Electron Window Configuration

To replicate an `NSPanel` with `.statusBar` level that doesn't steal focus:

```typescript
import { BrowserWindow, screen } from 'electron';

export function createNotchWindow(): BrowserWindow {
  const win = new BrowserWindow({
    type: 'panel',                   // NSPanel underlying style
    transparent: true,               // Transparent background
    frame: false,                     // No title bar or window chrome
    hasShadow: false,                 // No shadow
    focusable: false,                 // Never steal focus from active text editor/app
    skipTaskbar: true,                // Don't show in mission control taskbar
    alwaysOnTop: true,                // Keep elevated
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false,
      backgroundThrottling: false     // Don't pause rendering when unfocused
    }
  });

  // Critical on macOS: keep visible across spaces and above full-screen apps
  win.setAlwaysOnTop(true, 'screen-saver');
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });

  // Initial state: click-through everywhere with event forwarding
  win.setIgnoreMouseEvents(true, { forward: true });

  return win;
}
```

---

## 2. Dynamic Click-Through Toggling (`forward: true`)

On macOS, calling `win.setIgnoreMouseEvents(true)` makes the window click-through, but using `{ forward: true }` ensures the OS keeps sending mouse events (`mouseenter`, `mouseleave`, `mousemove`) to the Chromium renderer process.

### Preload Bridge
```typescript
contextBridge.exposeInMainWorld('codenotch', {
  setIgnoreMouseEvents: (ignore: boolean) => {
    ipcRenderer.send('set-ignore-mouse-events', ignore);
  }
});
```

### Main Process IPC
```typescript
ipcMain.on('set-ignore-mouse-events', (event, ignore: boolean) => {
  const win = BrowserWindow.fromWebContents(event.sender);
  if (win) {
    if (ignore) {
      win.setIgnoreMouseEvents(true, { forward: true });
    } else {
      win.setIgnoreMouseEvents(false);
    }
  }
});
```

### Renderer React Component
```tsx
function InteractiveRegion({ children }) {
  return (
    <div
      onMouseEnter={() => window.codenotch.setIgnoreMouseEvents(false)}
      onMouseLeave={() => window.codenotch.setIgnoreMouseEvents(true)}
    >
      {children}
    </div>
  );
}
```

---

## 3. Mathematical Formulation of Inverse Rounded Flares

A standard rectangle resting against a screen bezel looks like a foreign rectangular tab. A true notch features **inverse rounded corners (flares)** that smoothly curve outward to meet the bezel flush.

```text
                  Screen Edge (Bezel)
───────────────────┬───────────────┬───────────────────
                   │               │
  Inverse Flare ───╯               ╰─── Inverse Flare
   (curlRadius)                         (curlRadius)
                   │               │
                   │               │
                   │   Notch Body  │
                   │               │
                   ╰───────────────╯
                  Convex Outer Corners
                     (cornerRadius)
```

### SVG Path Formulation for Right-Edge Notch
For width `W` and height `H`:
- Start at top-right screen edge: `(W, 0)`
- Arc inward and down to top body edge: `A curl,curl 0 0,0 (W - curl, curl)`
- Line to convex corner: `L (corner, curl)`
- Arc around convex corner: `A corner,corner 0 0,0 (0, curl + corner)`
- Line along body outer edge to bottom corner: `L (0, H - curl - corner)`
- Arc around bottom convex corner: `A corner,corner 0 0,0 (corner, H - curl)`
- Line to bottom flare: `L (W - curl, H - curl)`
- Arc outward to bottom-right screen edge: `A curl,curl 0 0,0 (W, H)`
- Close path along bezel: `Z`

Using this exact path formula guarantees mathematically smooth $C^1$ continuity where the notch connects to the physical screen bezel!
