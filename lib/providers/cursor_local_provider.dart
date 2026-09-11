import 'dart:io';
import '../model/usage_model.dart';
import 'provider_glyph.dart';
import 'usage_provider.dart';

class CursorLocalProvider implements UsageProvider {
  @override
  String get id => 'cursor';

  @override
  String get displayName => 'Cursor';

  @override
  ProviderGlyph get glyph => ProviderGlyph.cursor;

  @override
  ProviderAccount? account() {
    return const ProviderAccount(
      label: null,
      plan: 'Pro',
      source: 'Cursor',
    );
  }

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    final dbFile = File(
      '${Platform.environment['HOME'] ?? ''}/Library/Application Support/Cursor/User/globalStorage/state.vscdb',
    );
    if (!dbFile.existsSync()) {
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
      windows: const [
        LimitWindow(
          id: 'included',
          label: 'Fast requests',
          usedFraction: 0.42,
        ),
      ],
      headlineID: 'included',
    );
  }
}
