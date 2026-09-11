import os from 'os';
import fs from 'fs';
import path from 'path';
import { execFileSync } from 'child_process';
import { ProviderSnapshot, ProviderSummary } from '../../../src/types';

export class CursorProvider {
  static get storePath(): string {
    return path.join(
      os.homedir(),
      'Library/Application Support/Cursor/User/globalStorage/state.vscdb'
    );
  }

  static getCredentials(): { accountId: string; accessToken: string; email?: string; plan?: string } | null {
    const dbPath = this.storePath;
    if (!fs.existsSync(dbPath)) return null;

    try {
      const sql = "SELECT key, value FROM ItemTable WHERE key IN ('cursorAuth/accessToken', 'cursorAuth/stripeMembershipAuthId', 'cursorAuth/cachedEmail', 'cursorAuth/stripeMembershipType');";
      const stdout = execFileSync('/usr/bin/sqlite3', ['-readonly', '-json', dbPath, sql], {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'ignore'],
        timeout: 3000
      });

      const rows: Array<{ key: string; value: string }> = JSON.parse(stdout || '[]');
      const map: Record<string, string> = {};
      for (const r of rows) {
        map[r.key] = r.value;
      }

      if (map['cursorAuth/accessToken'] && map['cursorAuth/stripeMembershipAuthId']) {
        return {
          accessToken: map['cursorAuth/accessToken'],
          accountId: map['cursorAuth/stripeMembershipAuthId'],
          email: map['cursorAuth/cachedEmail'],
          plan: map['cursorAuth/stripeMembershipType']
        };
      }
    } catch {}
    return null;
  }

  static async fetchSnapshot(): Promise<ProviderSnapshot> {
    const creds = this.getCredentials();
    if (!creds) {
      return {
        id: 'cursor',
        displayName: 'Cursor',
        glyph: 'cursor',
        fidelity: 'official',
        status: { type: 'needsAuth', message: 'Sign in to Cursor in the editor' },
        windows: []
      };
    }

    try {
      const cookie = `WorkosCursorSessionToken=${creds.accountId}::${creds.accessToken}`;
      const response = await fetch('https://cursor.com/api/usage-summary', {
        headers: {
          'Cookie': cookie,
          'Accept': 'application/json'
        }
      });

      if (response.status === 401 || response.status === 403) {
        return {
          id: 'cursor',
          displayName: 'Cursor',
          glyph: 'cursor',
          fidelity: 'official',
          status: { type: 'needsAuth', message: 'Sign in to Cursor in the editor' },
          windows: []
        };
      }

      const data = await response.json();
      const windows = [];

      // Parse Cursor usage schema
      if (data.numFastRequests !== undefined && data.maxFastRequests !== undefined) {
        const used = data.numFastRequests;
        const total = data.maxFastRequests;
        windows.push({
          id: 'cursor.fast',
          label: 'Fast requests',
          usedFraction: total > 0 ? used / total : 0,
          used,
          remaining: Math.max(0, total - used)
        });
      }

      return {
        id: 'cursor',
        displayName: 'Cursor',
        glyph: 'cursor',
        fidelity: 'official',
        status: { type: 'ok' },
        windows,
        headlineID: 'cursor.fast'
      };
    } catch (err: any) {
      return {
        id: 'cursor',
        displayName: 'Cursor',
        glyph: 'cursor',
        fidelity: 'official',
        status: { type: 'error', message: err.message || 'Failed to read Cursor usage' },
        windows: []
      };
    }
  }

  static getSummary(): ProviderSummary {
    const creds = this.getCredentials();
    return {
      id: 'cursor',
      name: 'Cursor',
      glyph: 'cursor',
      account: creds ? {
        label: creds.email,
        plan: creds.plan,
        source: 'Cursor',
        manageURL: 'https://cursor.com/dashboard'
      } : undefined,
      signIn: {
        type: 'openApp',
        appName: 'Cursor',
        bundleID: 'com.todesktop.230313mzl4w4u92',
        explanation: 'Open Cursor editor to sign in',
        actionTitle: 'Open Cursor'
      }
    };
  }
}
