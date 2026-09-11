import { Tray, Menu, nativeImage, app } from 'electron';
import path from 'path';

interface TrayControllerOptions {
  onOpenSettings: () => void;
  onRefresh: () => void;
  onToggleDemo: () => void;
  isDemoMode: () => boolean;
}

export class TrayController {
  private tray: Tray | null = null;
  private options: TrayControllerOptions;

  constructor(options: TrayControllerOptions) {
    this.options = options;
  }

  create(): Tray {
    const iconPath = path.join(__dirname, '../../public/menubar-codenotch.svg');
    let icon = nativeImage.createFromPath(iconPath);
    if (icon.isEmpty()) {
      icon = nativeImage.createFromPath(path.join(__dirname, '../../public/app-icon.png')).resize({ width: 18, height: 18 });
    } else {
      icon = icon.resize({ width: 18, height: 18 });
      icon.setTemplateImage(true);
    }

    this.tray = new Tray(icon);
    this.tray.setToolTip('Codenotch');
    this.updateMenu();

    return this.tray;
  }

  updateMenu() {
    if (!this.tray) return;

    const contextMenu = Menu.buildFromTemplate([
      {
        label: 'Settings…',
        click: () => this.options.onOpenSettings()
      },
      {
        label: 'Refresh now',
        click: () => this.options.onRefresh()
      },
      {
        label: 'Demo Mode',
        type: 'checkbox',
        checked: this.options.isDemoMode(),
        click: () => this.options.onToggleDemo()
      },
      { type: 'separator' },
      {
        label: 'Quit Codenotch',
        click: () => app.quit()
      }
    ]);

    this.tray.setContextMenu(contextMenu);
  }

  destroy() {
    if (this.tray) {
      this.tray.destroy();
      this.tray = null;
    }
  }
}
