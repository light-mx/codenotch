import { app } from 'electron';
import fs from 'fs';
import path from 'path';
import { UserPreferences } from '../../src/types';

const PREFERENCES_FILE = 'preferences.json';

const defaultPreferences: UserPreferences = {
  disconnectedProviders: [],
  notchVisibility: 'always',
  notchEdge: 'right',
  appPresence: 'menubar',
  launchAtLogin: false,
  demoMode: process.env.CODENOTCH_DEMO === '1'
};

export class PreferencesManager {
  private filePath: string;
  private currentPreferences: UserPreferences;

  constructor() {
    const userData = app.getPath('userData');
    this.filePath = path.join(userData, PREFERENCES_FILE);
    this.currentPreferences = this.load();
  }

  get preferences(): UserPreferences {
    return this.currentPreferences;
  }

  load(): UserPreferences {
    try {
      if (fs.existsSync(this.filePath)) {
        const raw = fs.readFileSync(this.filePath, 'utf8');
        const parsed = JSON.parse(raw);
        return { ...defaultPreferences, ...parsed };
      }
    } catch (err) {
      console.error('Failed to read preferences file:', err);
    }
    return { ...defaultPreferences };
  }

  save(partial: Partial<UserPreferences>): UserPreferences {
    this.currentPreferences = { ...this.currentPreferences, ...partial };
    try {
      const dir = path.dirname(this.filePath);
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
      fs.writeFileSync(this.filePath, JSON.stringify(this.currentPreferences, null, 2), 'utf8');

      if (partial.launchAtLogin !== undefined) {
        app.setLoginItemSettings({
          openAtLogin: partial.launchAtLogin,
          openAsHidden: true
        });
      }
    } catch (err) {
      console.error('Failed to save preferences:', err);
    }
    return this.currentPreferences;
  }
}
