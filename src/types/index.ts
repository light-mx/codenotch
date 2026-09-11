export type Fidelity = 'official' | 'derived' | 'manual';

export type NotchEdge = 'right' | 'left' | 'top' | 'bottom';

export type NotchVisibility = 'always' | 'hover' | 'never';

export type AppPresence = 'nowhere' | 'menubar' | 'dock' | 'both';

export type ProviderGlyphId =
  | 'claude'
  | 'openai'
  | 'third'
  | 'cursor'
  | 'gemini'
  | 'glm'
  | 'grok'
  | 'opencode';

export interface LimitWindow {
  id: string;
  label: string;
  usedFraction?: number;
  remaining?: number;
  used?: number;
  resetsAt?: string; // ISO string
}

export interface UsageBlock {
  reason: string;
  resetsAt?: string;
}

export type ProviderStatusType =
  | 'ok'
  | 'stale'
  | 'needsAuth'
  | 'accessDenied'
  | 'unsupported'
  | 'error';

export interface ProviderStatus {
  type: ProviderStatusType;
  staleSince?: string;
  message?: string;
}

export interface AgentSession {
  id: string;
  name: string;
  detail: string;
  state: 'busy' | 'waiting' | 'idle';
  since: string; // ISO string
  waitingFor?: string;
}

export interface ActivitySummary {
  providerId: string;
  state: 'busy' | 'waiting' | 'idle';
  sessions: AgentSession[];
  color: string;
}

export interface ProviderSnapshot {
  id: string;
  displayName: string;
  glyph: ProviderGlyphId;
  fidelity: Fidelity;
  status: ProviderStatus;
  windows: LimitWindow[];
  headlineID?: string;
  block?: UsageBlock;
}

export interface ProviderSummary {
  id: string;
  name: string;
  glyph: ProviderGlyphId;
  account?: {
    label?: string;
    plan?: string;
    source: string;
    manageURL?: string;
  };
  wasRefusedAccess?: boolean;
  signIn: {
    type: 'openApp' | 'website' | 'guidance' | 'modal';
    appName?: string;
    bundleID?: string;
    url?: string;
    explanation?: string;
    actionTitle?: string;
    switchHint?: string;
    signOutCaveat?: string;
  };
}

export interface UserPreferences {
  disconnectedProviders: string[];
  notchVisibility: NotchVisibility;
  notchEdge: NotchEdge;
  appPresence: AppPresence;
  launchAtLogin: boolean;
  lastSeenVersion?: string;
  demoMode: boolean;
}
