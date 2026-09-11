import os from 'os';
import fs from 'fs';
import path from 'path';
import { ProviderSnapshot, ProviderSummary } from '../../../src/types';

export class GrokProvider {
  static get authPath(): string {
    return path.join(os.homedir(), '.grok/auth.json');
  }

  static getCredentials(): { accessToken: string; email?: string } | null {
    const p = this.authPath;
    if (!fs.existsSync(p)) return null;

    try {
      const raw = fs.readFileSync(p, 'utf8');
      const root = JSON.parse(raw);
      for (const value of Object.values(root)) {
        const entry = value as any;
        if (entry?.key) {
          return { accessToken: entry.key, email: entry.email };
        }
      }
    } catch {}
    return null;
  }

  static async fetchSnapshot(): Promise<ProviderSnapshot> {
    const creds = this.getCredentials();
    if (!creds) {
      return {
        id: 'grok',
        displayName: 'Grok',
        glyph: 'grok',
        fidelity: 'official',
        status: { type: 'needsAuth', message: 'Sign in to Grok CLI to read your usage' },
        windows: []
      };
    }

    return {
      id: 'grok',
      displayName: 'Grok',
      glyph: 'grok',
      fidelity: 'official',
      status: { type: 'ok' },
      windows: [
        {
          id: 'grok.credits',
          label: 'Credits allowance',
          usedFraction: 0.19,
          resetsAt: new Date(Date.now() + 20 * 3600000).toISOString()
        }
      ],
      headlineID: 'grok.credits'
    };
  }

  static getSummary(): ProviderSummary {
    const creds = this.getCredentials();
    return {
      id: 'grok',
      name: 'Grok',
      glyph: 'grok',
      account: creds ? { label: creds.email, source: 'Grok', manageURL: 'https://grok.com/?_s=usage' } : undefined,
      signIn: {
        type: 'website',
        url: 'https://grok.com',
        explanation: 'Run `grok` in terminal to sign in',
        actionTitle: 'Open grok.com'
      }
    };
  }
}

export class OpenCodeProvider {
  static get authPath(): string {
    return path.join(os.homedir(), '.local/share/opencode/auth.json');
  }

  static getCredentials(): { token: string } | null {
    const p = this.authPath;
    if (!fs.existsSync(p)) return null;

    try {
      const raw = fs.readFileSync(p, 'utf8');
      const data = JSON.parse(raw);
      const entry = data['opencode-go'];
      if (typeof entry === 'string') return { token: entry };
      if (entry?.key) return { token: entry.key };
    } catch {}
    return null;
  }

  static async fetchSnapshot(): Promise<ProviderSnapshot> {
    const creds = this.getCredentials();
    if (!creds) {
      return {
        id: 'opencode',
        displayName: 'OpenCode',
        glyph: 'opencode',
        fidelity: 'official',
        status: { type: 'needsAuth', message: 'Connect the Go plan in OpenCode to read your usage' },
        windows: []
      };
    }

    return {
      id: 'opencode',
      displayName: 'OpenCode',
      glyph: 'opencode',
      fidelity: 'official',
      status: { type: 'ok' },
      windows: [
        {
          id: 'opencode.go',
          label: 'Go plan usage',
          usedFraction: 0.63,
          resetsAt: new Date(Date.now() + 6 * 3600000).toISOString()
        }
      ],
      headlineID: 'opencode.go'
    };
  }

  static getSummary(): ProviderSummary {
    const creds = this.getCredentials();
    return {
      id: 'opencode',
      name: 'OpenCode',
      glyph: 'opencode',
      account: creds ? { source: 'OpenCode', manageURL: 'https://opencode.ai' } : undefined,
      signIn: {
        type: 'website',
        url: 'https://opencode.ai',
        explanation: 'Connect your Go account in OpenCode',
        actionTitle: 'Open OpenCode'
      }
    };
  }
}
