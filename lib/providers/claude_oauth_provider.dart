import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/usage_model.dart';
import 'provider_glyph.dart';
import 'usage_provider.dart';

class ClaudeOAuthProvider implements UsageProvider {
  final String profileSlug;

  ClaudeOAuthProvider({this.profileSlug = ''});

  @override
  String get id => profileSlug.isEmpty ? 'claude' : 'claude-$profileSlug';

  @override
  String get displayName => profileSlug.isEmpty ? 'Claude' : 'Claude ($profileSlug)';

  @override
  ProviderGlyph get glyph => ProviderGlyph.claude;

  String? _cachedToken;

  @override
  void forgetCachedCredential() {
    _cachedToken = null;
  }

  @override
  ProviderAccount? account() {
    return const ProviderAccount(
      label: null,
      plan: 'Claude Pro/Max',
      source: 'Claude Code',
    );
  }

  String? _readKeychainToken() {
    if (_cachedToken != null) return _cachedToken;
    try {
      final service = profileSlug.isEmpty ? 'Claude Code' : 'Claude Code ($profileSlug)';
      final result = Process.runSync('/usr/bin/security', [
        'find-generic-password',
        '-s',
        service,
        '-w',
      ]);
      if (result.exitCode == 0 && result.stdout != null) {
        final token = (result.stdout as String).trim();
        if (token.isNotEmpty) {
          _cachedToken = token;
          return token;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<ProviderSnapshot> fetchSnapshot() async {
    final token = _readKeychainToken();
    if (token == null) {
      return ProviderSnapshot(
        id: id,
        displayName: displayName,
        glyph: glyph,
        fidelity: Fidelity.official,
        status: const ProviderStatusNeedsAuth(),
        windows: const [],
      );
    }

    try {
      final uri = Uri.parse('https://api.anthropic.com/api/oauth/usage');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'anthropic-beta': 'oauth-2025-04-20',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401 || response.statusCode == 403) {
        forgetCachedCredential();
        return ProviderSnapshot(
          id: id,
          displayName: displayName,
          glyph: glyph,
          fidelity: Fidelity.official,
          status: const ProviderStatusNeedsAuth(),
          windows: const [],
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<LimitWindow> windows = [];

        final fiveHour = data['five_hour'] as Map<String, dynamic>?;
        if (fiveHour != null) {
          final resetsAt = fiveHour['resets_at'] != null
              ? DateTime.tryParse(fiveHour['resets_at'] as String)
              : null;
          final util = (fiveHour['utilization'] as num?)?.toDouble() ?? 0.0;
          windows.add(
            LimitWindow(
              id: 'session',
              label: 'Current session',
              usedFraction: util / 100.0,
              resetsAt: resetsAt,
            ),
          );
        }

        final sevenDay = data['seven_day'] as Map<String, dynamic>?;
        if (sevenDay != null) {
          final resetsAt = sevenDay['resets_at'] != null
              ? DateTime.tryParse(sevenDay['resets_at'] as String)
              : null;
          final util = (sevenDay['utilization'] as num?)?.toDouble() ?? 0.0;
          windows.add(
            LimitWindow(
              id: 'weekly_all',
              label: 'All models',
              usedFraction: util / 100.0,
              resetsAt: resetsAt,
            ),
          );
        }

        return ProviderSnapshot(
          id: id,
          displayName: displayName,
          glyph: glyph,
          fidelity: Fidelity.official,
          status: const ProviderStatusOk(),
          windows: windows,
          headlineID: 'session',
        );
      }
    } catch (_) {}

    return ProviderSnapshot(
      id: id,
      displayName: displayName,
      glyph: glyph,
      fidelity: Fidelity.official,
      status: const ProviderStatusError('Failed to reach endpoint'),
      windows: const [],
    );
  }
}
