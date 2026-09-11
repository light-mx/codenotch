const { app, BrowserWindow, screen, ipcMain } = require('electron');
const path = require('path');

app.whenReady().then(() => {
  const display = screen.getPrimaryDisplay();
  const { width: screenWidth, height: screenHeight } = display.workArea;

  const panelWidth = 320;
  const panelHeight = 400;

  const win = new BrowserWindow({
    x: screenWidth - panelWidth,
    y: Math.round((screenHeight - panelHeight) / 2),
    width: panelWidth,
    height: panelHeight,
    type: 'panel',
    transparent: true,
    frame: false,
    hasShadow: false,
    focusable: false,
    skipTaskbar: true,
    alwaysOnTop: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  win.setAlwaysOnTop(true, 'screen-saver');
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  win.setIgnoreMouseEvents(true, { forward: true });

  ipcMain.on('set-ignore-mouse-events', (event, ignore) => {
    win.setIgnoreMouseEvents(ignore, { forward: true });
  });

  win.loadFile('index.html');
});
