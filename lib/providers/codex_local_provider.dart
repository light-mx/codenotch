import 'dart:io';
import '../model/usage_model.dart';
import 'provider_glyph.dart';
import 'usage_provider.dart';

class CodexLocalProvider implements UsageProvider {
  @override
  String get id => 'codex';

  @override
  String get displayName => 'Codex';

  @override
  ProviderGlyph get glyph => ProviderGlyph.openai;

  @override
  ProviderAccount? account() {
    return const ProviderAccount(
      label: null,
      plan: 'ChatGPT Plus',
      source: 'Codex',
    );
  }

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    final codexDir = Directory('${Platform.environment['HOME'] ?? ''}/.codex');
    if (!codexDir.existsSync()) {
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
          id: '5hour',
          label: '5-hour limit',
          usedFraction: 0.28,
          resetsAt: DateTime.now().add(const Duration(hours: 3)),
        ),
      ],
      headlineID: '5hour',
    );
  }
}
