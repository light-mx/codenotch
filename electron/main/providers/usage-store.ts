import { ProviderSnapshot, ProviderSummary, UserPreferences } from '../../../src/types';
import { getFixtureSnapshots } from './fixtures';
import { ClaudeProvider } from './claude-provider';
import { CursorProvider } from './cursor-provider';
import { CodexProvider } from './codex-provider';
import { AntigravityProvider } from './antigravity-provider';
import { GLMProvider } from './glm-provider';
import { GrokProvider, OpenCodeProvider } from './grok-provider';

export class UsageStore {
  private snapshots: Map<string, ProviderSnapshot> = new Map();
  private pollTimer: NodeJS.Timeout | null = null;
  private onUpdateCallback?: (snapshots: ProviderSnapshot[]) => void;
  private getPreferences: () => UserPreferences;

  constructor(getPreferences: () => UserPreferences) {
    this.getPreferences = getPreferences;
  }

  onUpdate(callback: (snapshots: ProviderSnapshot[]) => void) {
    this.onUpdateCallback = callback;
  }

  getSnapshots(): ProviderSnapshot[] {
    const prefs = this.getPreferences();
    if (prefs.demoMode) {
      return getFixtureSnapshots();
    }

    const disconnected = new Set(prefs.disconnectedProviders);
    return Array.from(this.snapshots.values()).filter(s => !disconnected.has(s.id));
  }

  getSummaries(): ProviderSummary[] {
    const summaries: ProviderSummary[] = [];
    const claudeProfiles = ClaudeProvider.discoverProfiles();
    for (const p of claudeProfiles) {
      summaries.push(ClaudeProvider.getSummary(p));
    }
    summaries.push(CursorProvider.getSummary());
    summaries.push(CodexProvider.getSummary());
    summaries.push(AntigravityProvider.getSummary());
    summaries.push(GLMProvider.getSummary());
    summaries.push(GrokProvider.getSummary());
    summaries.push(OpenCodeProvider.getSummary());
    return summaries;
  }

  startPolling(intervalMs = 60000) {
    this.poll();
    this.pollTimer = setInterval(() => this.poll(), intervalMs);
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer);
      this.pollTimer = null;
    }
  }

  async poll(specificId?: string) {
    const prefs = this.getPreferences();
    if (prefs.demoMode) {
      this.onUpdateCallback?.(getFixtureSnapshots());
      return;
    }

    const disconnected = new Set(prefs.disconnectedProviders);
    const claudeProfiles = ClaudeProvider.discoverProfiles();

    const tasks: Array<Promise<ProviderSnapshot>> = [];

    // Claude
    for (const profile of claudeProfiles) {
      if (!disconnected.has(profile.id) && (!specificId || specificId === profile.id)) {
        tasks.push(ClaudeProvider.fetchSnapshot(profile));
      }
    }

    // Cursor
    if (!disconnected.has('cursor') && (!specificId || specificId === 'cursor')) {
      tasks.push(CursorProvider.fetchSnapshot());
    }

    // Codex
    if (!disconnected.has('codex') && (!specificId || specificId === 'codex')) {
      tasks.push(CodexProvider.fetchSnapshot());
    }

    // Antigravity
    if (!disconnected.has('gemini') && (!specificId || specificId === 'gemini')) {
      tasks.push(AntigravityProvider.fetchSnapshot());
    }

    // GLM
    if (!disconnected.has('glm') && (!specificId || specificId === 'glm')) {
      tasks.push(GLMProvider.fetchSnapshot());
    }

    // Grok
    if (!disconnected.has('grok') && (!specificId || specificId === 'grok')) {
      tasks.push(GrokProvider.fetchSnapshot());
    }

    // OpenCode
    if (!disconnected.has('opencode') && (!specificId || specificId === 'opencode')) {
      tasks.push(OpenCodeProvider.fetchSnapshot());
    }

    const results = await Promise.allSettled(tasks);
    for (const res of results) {
      if (res.status === 'fulfilled') {
        this.snapshots.set(res.value.id, res.value);
      }
    }

    this.onUpdateCallback?.(this.getSnapshots());
  }
}
