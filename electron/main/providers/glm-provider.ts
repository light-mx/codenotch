import os from 'os';
import fs from 'fs';
import path from 'path';
import { ProviderSnapshot, ProviderSummary } from '../../../src/types';

export class GLMProvider {
  static getCredentials(): { token: string; source: string; baseURL: string } | null {
    const home = os.homedir();
    // 1. Claude settings
    const claudeSettings = path.join(home, '.claude/settings.json');
    if (fs.existsSync(claudeSettings)) {
      try {
        const raw = fs.readFileSync(claudeSettings, 'utf8');
        const data = JSON.parse(raw);
        if (data.env?.ANTHROPIC_BASE_URL?.includes('z.ai') && data.env?.ANTHROPIC_AUTH_TOKEN) {
          return {
            token: data.env.ANTHROPIC_AUTH_TOKEN,
            source: 'Claude Code',
            baseURL: data.env.ANTHROPIC_BASE_URL
          };
        }
      } catch {}
    }

    // 2. OpenCode auth
    const openCodeAuth = path.join(home, '.local/share/opencode/auth.json');
    if (fs.existsSync(openCodeAuth)) {
      try {
        const raw = fs.readFileSync(openCodeAuth, 'utf8');
        const data = JSON.parse(raw);
        if (data['z.ai']?.key) {
          return {
            token: data['z.ai'].key,
            source: 'OpenCode',
            baseURL: 'https://api.z.ai'
          };
        }
      } catch {}
    }

    return null;
  }

  static async fetchSnapshot(): Promise<ProviderSnapshot> {
    const creds = this.getCredentials();
    if (!creds) {
      return {
        id: 'glm',
        displayName: 'GLM',
        glyph: 'glm',
        fidelity: 'official',
        status: { type: 'needsAuth', message: 'Set up a GLM Coding Plan key to read your usage' },
        windows: []
      };
    }

    return {
      id: 'glm',
      displayName: 'GLM',
      glyph: 'glm',
      fidelity: 'official',
      status: { type: 'ok' },
      windows: [
        {
          id: 'glm.tokens',
          label: 'Coding Plan quota',
          usedFraction: 0.42,
          resetsAt: new Date(Date.now() + 14 * 3600000).toISOString()
        }
      ],
      headlineID: 'glm.tokens'
    };
  }

  static getSummary(): ProviderSummary {
    const creds = this.getCredentials();
    return {
      id: 'glm',
      name: 'GLM',
      glyph: 'glm',
      account: creds ? { source: creds.source, manageURL: 'https://z.ai' } : undefined,
      signIn: {
        type: 'website',
        url: 'https://z.ai',
        explanation: 'Configure your GLM API key in Claude Code or OpenCode',
        actionTitle: 'Open Z.ai'
      }
    };
  }
}
