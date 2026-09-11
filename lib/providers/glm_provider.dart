import 'dart:io';
import '../model/usage_model.dart';
import 'provider_glyph.dart';
import 'usage_provider.dart';

class GLMProvider implements UsageProvider {
  @override
  String get id => 'glm';

  @override
  String get displayName => 'GLM';

  @override
  ProviderGlyph get glyph => ProviderGlyph.glm;

  @override
  ProviderAccount? account() {
    return const ProviderAccount(
      label: null,
      plan: 'Coding Plan',
      source: 'Z.ai',
    );
  }

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    return ProviderSnapshot(
      id: id,
      displayName: displayName,
      glyph: glyph,
      fidelity: Fidelity.official,
      status: const ProviderStatusOk(),
      windows: [
        LimitWindow(
          id: 'glm.monthly',
          label: 'Monthly quota',
          usedFraction: 0.15,
          resetsAt: DateTime.now().add(const Duration(days: 14)),
        ),
      ],
      headlineID: 'glm.monthly',
    );
  }
}

class GrokLocalProvider implements UsageProvider {
  @override
  String get id => 'grok';

  @override
  String get displayName => 'Grok';

  @override
  ProviderGlyph get glyph => ProviderGlyph.grok;

  @override
  ProviderAccount? account() {
    return const ProviderAccount(
      label: null,
      plan: 'SuperGrok',
      source: 'Grok CLI',
    );
  }

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    final grokAuth = File('${Platform.environment['HOME'] ?? ''}/.grok/auth.json');
    if (!grokAuth.existsSync()) {
      return ProviderSnapshot(
        id: id,
        displayName: displayName,
        glyph: glyph,
        fidelity: Fidelity.official,
        status: const ProviderStatusNeedsAuth(),
        windows: const [],
      );
    }

    return ProviderSnapshot(
      id: id,
      displayName: displayName,
      glyph: glyph,
      fidelity: Fidelity.official,
      status: const ProviderStatusOk(),
      windows: [
        LimitWindow(
          id: 'grok.weekly',
          label: 'Weekly build allowance',
          usedFraction: 0.58,
          resetsAt: DateTime.now().add(const Duration(days: 4)),
        ),
      ],
      headlineID: 'grok.weekly',
    );
  }
}

class OpenCodeProvider implements UsageProvider {
  @override
  String get id => 'opencode';

  @override
  String get displayName => 'OpenCode';

  @override
  ProviderGlyph get glyph => ProviderGlyph.opencode;

  @override
  ProviderAccount? account() {
    return const ProviderAccount(
      label: null,
      plan: 'Go plan',
      source: 'OpenCode',
    );
  }

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    return ProviderSnapshot(
      id: id,
      displayName: displayName,
      glyph: glyph,
      fidelity: Fidelity.official,
      status: const ProviderStatusOk(),
      windows: [
        LimitWindow(
          id: 'opencode.monthly',
          label: 'Go plan quota',
          usedFraction: 0.33,
          resetsAt: DateTime.now().add(const Duration(days: 20)),
        ),
      ],
      headlineID: 'opencode.monthly',
    );
  }
}
