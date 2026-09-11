import 'package:flutter_test/flutter_test.dart';
import 'package:codenotch/model/usage_model.dart';
import 'package:codenotch/model/usage_store.dart';
import 'package:codenotch/providers/provider_glyph.dart';
import 'package:codenotch/providers/usage_provider.dart';

class SwitchableProvider implements UsageProvider {
  @override
  final String id = 'claude';
  @override
  final String displayName = 'Claude';
  @override
  final ProviderGlyph glyph = ProviderGlyph.claude;

  Object? outcome;

  SwitchableProvider({this.outcome});

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    if (outcome is UsageProviderError) {
      throw outcome as UsageProviderError;
    }
    return ProviderSnapshot(
      id: id,
      displayName: displayName,
      glyph: glyph,
      fidelity: Fidelity.official,
      status: const ProviderStatusOk(),
      windows: [
        LimitWindow(
          id: 'session',
          label: 'Current session',
          usedFraction: 0.42,
          resetsAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      ],
    );
  }

  @override
  ProviderAccount? account() => null;

  @override
  void presentSignIn() {}

  @override
  void forgetCachedCredential() {}
}

void main() {
  group('ProviderSummaryTests', () {
    test('a refusal reaches the row', () async {
      final provider = SwitchableProvider(outcome: UsageProviderError.accessDenied);
      final store = UsageStore(providers: [provider]);

      await store.refreshNow();

      expect(store.providerSummaries.first.wasRefusedAccess, isTrue);
    });

    test('a refusal reaches the row even with a good reading in hand', () async {
      final provider = SwitchableProvider();
      final store = UsageStore(providers: [provider]);

      await store.refreshNow();
      expect(store.providerSummaries.first.wasRefusedAccess, isFalse);

      provider.outcome = UsageProviderError.accessDenied;
      await store.refreshNow();

      expect(store.snapshots.first.status, isNot(isA<ProviderStatusAccessDenied>()));
      expect(store.providerSummaries.first.wasRefusedAccess, isTrue);
    });

    test('the remedy goes away once access is granted again', () async {
      final provider = SwitchableProvider(outcome: UsageProviderError.accessDenied);
      final store = UsageStore(providers: [provider]);

      await store.refreshNow();
      expect(store.providerSummaries.first.wasRefusedAccess, isTrue);

      provider.outcome = null;
      await store.refreshNow();
      expect(store.providerSummaries.first.wasRefusedAccess, isFalse);
    });

    test('other failures do not offer the access remedy', () async {
      for (final error in [
        UsageProviderError.needsAuth,
        UsageProviderError.unsupported,
      ]) {
        final store = UsageStore(providers: [SwitchableProvider(outcome: error)]);
        await store.refreshNow();
        expect(
          store.providerSummaries.first.wasRefusedAccess,
          isFalse,
          reason: '$error was treated as accessDenied',
        );
      }
    });

    test('without a fetch the row offers nothing', () {
      final store = UsageStore(
        providers: [SwitchableProvider(outcome: UsageProviderError.accessDenied)],
      );
      expect(store.providerSummaries.first.wasRefusedAccess, isFalse);
    });
  });

  group('ProviderAccountTests', () {
    test('summary reads as a sentence', () {
      const account = ProviderAccount(
        label: 'someone@example.com',
        plan: 'free',
        source: 'Cursor',
      );
      expect(account.summary, 'someone@example.com · Free · via Cursor');
    });

    test('summary survives a missing label', () {
      const account = ProviderAccount(
        label: null,
        plan: 'pro',
        source: 'Claude Code',
      );
      expect(account.summary, 'Pro · via Claude Code');
    });

    test('summary survives a missing plan', () {
      const account = ProviderAccount(
        label: 'a@b.c',
        plan: null,
        source: 'Codex',
      );
      expect(account.summary, 'a@b.c · via Codex');
    });
  });
}
