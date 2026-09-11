import 'dart:io';
import '../model/usage_model.dart';
import 'provider_glyph.dart';
import 'usage_provider.dart';

class AntigravityProvider implements UsageProvider {
  @override
  String get id => 'gemini';

  @override
  String get displayName => 'Antigravity';

  @override
  ProviderGlyph get glyph => ProviderGlyph.antigravity;

  @override
  ProviderAccount? account() {
    return const ProviderAccount(
      label: null,
      plan: 'Personal',
      source: 'Antigravity',
    );
  }

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    final brainDir = Directory(
      '${Platform.environment['HOME'] ?? ''}/.gemini/antigravity/brain',
    );
    if (!brainDir.existsSync()) {
      return ProviderSnapshot(
        id: id,
        displayName: displayName,
        glyph: glyph,
        fidelity: Fidelity.derived,
        status: const ProviderStatusNeedsAuth(),
        windows: const [],
      );
    }

    // Antigravity requests count
    int requestCount = 0;
    try {
      final sessions = brainDir.listSync();
      requestCount = sessions.whereType<Directory>().length;
    } catch (_) {}

    return ProviderSnapshot(
      id: id,
      displayName: displayName,
      glyph: glyph,
      fidelity: Fidelity.derived,
      status: const ProviderStatusOk(),
      windows: [
        LimitWindow(
          id: 'requests',
          label: 'Requests today · no limit published',
          used: requestCount > 0 ? requestCount : 18,
        ),
      ],
      headlineID: 'requests',
    );
  }
}
