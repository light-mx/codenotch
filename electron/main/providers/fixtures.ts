import { ProviderSnapshot } from '../../../src/types';

export function getFixtureSnapshots(): ProviderSnapshot[] {
  const now = new Date();
  const sessionReset = new Date(now.getTime() + 51 * 60000).toISOString();
  const midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 0).toISOString();
  const threeHours = new Date(now.getTime() + 3 * 3600000).toISOString();

  return [
    {
      id: 'claude',
      displayName: 'Claude',
      glyph: 'claude',
      fidelity: 'derived',
      status: { type: 'ok' },
      windows: [
        {
          id: 'claude.session',
          label: 'Current session',
          usedFraction: 0.73,
          resetsAt: sessionReset
        },
        {
          id: 'claude.all',
          label: 'All models',
          usedFraction: 0.07,
          resetsAt: midnight
        }
      ],
      headlineID: 'claude.session'
    },
    {
      id: 'openai',
      displayName: 'OpenAI',
      glyph: 'openai',
      fidelity: 'manual',
      status: { type: 'ok' },
      windows: [
        {
          id: 'openai.session',
          label: 'Current session',
          usedFraction: 0.21,
          resetsAt: threeHours
        }
      ],
      headlineID: 'openai.session'
    },
    {
      id: 'third',
      displayName: 'Perplexity',
      glyph: 'third',
      fidelity: 'manual',
      status: { type: 'ok' },
      windows: [
        {
          id: 'third.daily',
          label: 'Daily quota',
          usedFraction: 0.52,
          resetsAt: midnight
        }
      ],
      headlineID: 'third.daily'
    }
  ];
}
