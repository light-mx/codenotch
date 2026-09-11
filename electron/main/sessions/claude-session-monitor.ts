import fs from 'fs';
import path from 'path';
import os from 'os';
import { AgentSession, ActivitySummary } from '../../../src/types';
import { Palette } from '../../../src/design/tokens';

export class ClaudeSessionMonitor {
  private sessionsDir: string;
  private timer: NodeJS.Timeout | null = null;
  private onUpdateCallback?: (activity: ActivitySummary) => void;

  constructor(profileDir = path.join(os.homedir(), '.claude')) {
    this.sessionsDir = path.join(profileDir, 'sessions');
  }

  onUpdate(callback: (activity: ActivitySummary) => void) {
    this.onUpdateCallback = callback;
  }

  start(intervalMs = 5000) {
    this.scan();
    this.timer = setInterval(() => this.scan(), intervalMs);

    if (fs.existsSync(this.sessionsDir)) {
      try {
        fs.watch(this.sessionsDir, () => {
          setTimeout(() => this.scan(), 150);
        });
      } catch {}
    }
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  scan() {
    const sessions = this.readSessions();
    let state: 'busy' | 'waiting' | 'idle' = 'idle';
    let color: string = Palette.textSecondary;

    if (sessions.some(s => s.state === 'waiting')) {
      state = 'waiting';
      color = Palette.watch;
    } else if (sessions.some(s => s.state === 'busy')) {
      state = 'busy';
      color = Palette.ample;
    }

    const summary: ActivitySummary = {
      providerId: 'claude',
      state,
      sessions,
      color
    };

    this.onUpdateCallback?.(summary);
  }

  private readSessions(): AgentSession[] {
    if (!fs.existsSync(this.sessionsDir)) return [];

    try {
      const files = fs.readdirSync(this.sessionsDir).filter(f => f.endsWith('.json'));
      const active: AgentSession[] = [];

      for (const file of files) {
        try {
          const filePath = path.join(this.sessionsDir, file);
          const raw = fs.readFileSync(filePath, 'utf8');
          const data = JSON.parse(raw);

          // Check process liveness
          if (data.pid && this.isAlive(data.pid)) {
            active.push({
              id: data.id || file,
              name: data.name || data.title || 'Claude Session',
              detail: data.current_tool || data.command || 'Thinking…',
              state: data.waiting_for_user ? 'waiting' : 'busy',
              since: data.started_at || new Date().toISOString(),
              waitingFor: data.waiting_for_user ? data.prompt || 'Waiting on user input' : undefined
            });
          }
        } catch {}
      }

      return active;
    } catch {
      return [];
    }
  }

  private isAlive(pid: number): boolean {
    try {
      process.kill(pid, 0);
      return true;
    } catch (err: any) {
      return err.code === 'EPERM';
    }
  }
}
