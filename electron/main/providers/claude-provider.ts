import os from 'os';
import fs from 'fs';
import path from 'path';
import { ProviderSnapshot, ProviderSummary } from '../../../src/types';
import { Keychain } from './keychain';

export interface ClaudeProfileInfo {
  id: string;
  displayName: string;
  configDir: string;
  keychainService: string;
}

export class ClaudeProvider {
  static discoverProfiles(): ClaudeProfileInfo[] {
    const home = os.homedir();
    const profiles: ClaudeProfileInfo[] = [];

    // Default profile ~/.claude
    const defaultDir = path.join(home, '.claude');
    if (fs.existsSync(defaultDir)) {
      profiles.push({
        id: 'claude',
        displayName: 'Claude',
        configDir: defaultDir,
        keychainService: 'claude'
      });
    }

    // Additional profiles ~/.claude-*
    try {
      const files = fs.readdirSync(home);
      for (const f of files) {
        if (f.startsWith('.claude-')) {
          const slug = f.slice(8);
          profiles.push({
            id: `claude-${slug}`,
            displayName: `Claude (${slug})`,
            configDir: path.join(home, f),
            keychainService: `claude-${slug}`
          });
        }
      }
    } catch {}

    if (profiles.length === 0) {
      profiles.push({
        id: 'claude',
        displayName: 'Claude',
        configDir: defaultDir,
        keychainService: 'claude'
      });
    }

    return profiles;
  }

  static async fetchSnapshot(profile: ClaudeProfileInfo): Promise<ProviderSnapshot> {
    // 1. Read token from Keychain
    let token = Keychain.readGenericPassword(profile.keychainService);

    // If keychain returned a JSON payload (as Claude Code stores)
    if (token && token.includes('{')) {
      try {
        const parsed = JSON.parse(token);
        if (parsed.claudeAiOauth?.accessToken) {
          token = parsed.claudeAiOauth.accessToken;
        }
      } catch {}
    }

    // Fallback: check config file if keychain was not accessible
    if (!token) {
      const configPath = path.join(profile.configDir, 'auth.json');
      if (fs.existsSync(configPath)) {
        try {
          const authData = JSON.parse(fs.readFileSync(configPath, 'utf8'));
          token = authData.access_token || authData.token;
        } catch {}
      }
    }

    if (!token) {
      return {
        id: profile.id,
        displayName: profile.displayName,
        glyph: 'claude',
        fidelity: 'derived',
        status: { type: 'needsAuth', message: 'Sign in to Claude Code to read your usage' },
        windows: []
      };
    }

    // Call official Anthropic usage endpoint
    try {
      const response = await fetch('https://api.anthropic.com/api/oauth/usage', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'anthropic-beta': 'oauth-2025-04-20',
          'Accept': 'application/json'
        }
      });

      if (response.status === 401 || response.status === 403) {
        return {
          id: profile.id,
          displayName: profile.displayName,
          glyph: 'claude',
          fidelity: 'official',
          status: { type: 'needsAuth', message: 'Sign in to Claude Code to read your usage' },
          windows: []
        };
      }

      if (response.status === 429) {
        return {
          id: profile.id,
          displayName: profile.displayName,
          glyph: 'claude',
          fidelity: 'official',
          status: { type: 'stale', message: 'Rate limited by Anthropic API' },
          windows: []
        };
      }

      const data = await response.json();
      const windows = [];

      if (data.session_used_fraction !== undefined) {
        windows.push({
          id: `${profile.id}.session`,
          label: 'Current session',
          usedFraction: data.session_used_fraction,
          resetsAt: data.session_resets_at
        });
      }

      if (data.weekly_used_fraction !== undefined) {
        windows.push({
          id: `${profile.id}.all`,
          label: 'All models',
          usedFraction: data.weekly_used_fraction,
          resetsAt: data.weekly_resets_at
        });
      }

      return {
        id: profile.id,
        displayName: profile.displayName,
        glyph: 'claude',
        fidelity: 'official',
        status: { type: 'ok' },
        windows,
        headlineID: `${profile.id}.session`
      };
    } catch (err: any) {
      return {
        id: profile.id,
        displayName: profile.displayName,
        glyph: 'claude',
        fidelity: 'official',
        status: { type: 'error', message: err.message || 'Failed to fetch Claude usage' },
        windows: []
      };
    }
  }

  static getSummary(profile: ClaudeProfileInfo): ProviderSummary {
    return {
      id: profile.id,
      name: profile.displayName,
      glyph: 'claude',
      signIn: {
        type: 'website',
        url: 'https://claude.ai/settings/usage',
        explanation: 'Run `claude` in your terminal to sign in',
        actionTitle: 'Open claude.ai'
      }
    };
  }
}
