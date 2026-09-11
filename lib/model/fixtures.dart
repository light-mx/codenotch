import 'usage_model.dart';
import '../providers/provider_glyph.dart';

/// The three providers from the design frame, at the levels it shows.
abstract final class Fixtures {
  static List<ProviderSnapshot> snapshots({DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final DateTime sessionReset = current.add(const Duration(minutes: 51));
    final DateTime tomorrow = current.add(const Duration(days: 1));
    final DateTime midnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    return [
      ProviderSnapshot(
        id: 'claude',
        displayName: 'Claude',
        glyph: ProviderGlyph.claude,
        fidelity: Fidelity.derived,
        status: const ProviderStatusOk(),
        headlineID: 'claude.session',
        windows: [
          LimitWindow(
            id: 'claude.session',
            label: 'Current session',
            usedFraction: 0.73,
            resetsAt: sessionReset,
          ),
          LimitWindow(
            id: 'claude.all',
            label: 'All models',
            usedFraction: 0.07,
            resetsAt: midnight,
          ),
        ],
      ),
      ProviderSnapshot(
        id: 'openai',
        displayName: 'OpenAI',
        glyph: ProviderGlyph.openai,
        fidelity: Fidelity.manual,
        status: const ProviderStatusOk(),
        headlineID: 'openai.session',
        windows: [
          LimitWindow(
            id: 'openai.session',
            label: 'Current session',
            usedFraction: 0.21,
            resetsAt: current.add(const Duration(hours: 3)),
          ),
        ],
      ),
      ProviderSnapshot(
        id: 'third',
        displayName: 'Perplexity',
        glyph: ProviderGlyph.third,
        fidelity: Fidelity.manual,
        status: const ProviderStatusOk(),
        headlineID: 'third.daily',
        windows: [
          LimitWindow(
            id: 'third.daily',
            label: 'Daily quota',
            usedFraction: 0.52,
            resetsAt: midnight,
          ),
        ],
      ),
    ];
  }
}
