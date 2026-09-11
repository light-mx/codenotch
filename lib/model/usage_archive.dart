import 'dart:convert';
import 'dart:io';
import 'usage_model.dart';
import '../providers/provider_glyph.dart';

/// Persists the last good snapshot readings and backoff retry times across launches.
class UsageArchive {
  final Directory directory;

  UsageArchive({Directory? directory})
      : directory = directory ??
            Directory(
              '${Platform.environment['HOME'] ?? ''}/Library/Application Support/Codenotch',
            );

  File get _file => File('${directory.path}/archive.json');

  void save(Map<String, ({ProviderSnapshot snapshot, DateTime fetchedAt})> items) {
    try {
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final Map<String, dynamic> jsonMap = {};
      for (final entry in items.entries) {
        final s = entry.value.snapshot;
        jsonMap[entry.key] = {
          'id': s.id,
          'displayName': s.displayName,
          'glyph': s.glyph.rawValue,
          'fidelity': s.fidelity.name,
          'fetchedAt': entry.value.fetchedAt.toIso8601String(),
          'windows': s.windows
              .map((w) => {
                    'id': w.id,
                    'label': w.label,
                    'usedFraction': w.usedFraction,
                    'remaining': w.remaining,
                    'used': w.used,
                    'resetsAt': w.resetsAt?.toIso8601String(),
                  })
              .toList(),
          'headlineID': s.headlineID,
        };
      }
      _file.writeAsStringSync(jsonEncode(jsonMap));
    } catch (_) {}
  }

  Map<String, ({ProviderSnapshot snapshot, DateTime fetchedAt})> load() {
    try {
      if (!_file.existsSync()) return {};
      final content = _file.readAsStringSync();
      final Map<String, dynamic> decoded = jsonDecode(content) as Map<String, dynamic>;
      final Map<String, ({ProviderSnapshot snapshot, DateTime fetchedAt})> result = {};

      for (final entry in decoded.entries) {
        final data = entry.value as Map<String, dynamic>;
        final glyphStr = data['glyph'] as String? ?? 'gemini';
        final glyph = ProviderGlyph.values.firstWhere(
          (g) => g.rawValue == glyphStr,
          orElse: () => ProviderGlyph.antigravity,
        );
        final fidelityStr = data['fidelity'] as String? ?? 'official';
        final fidelity = Fidelity.values.firstWhere(
          (f) => f.name == fidelityStr,
          orElse: () => Fidelity.official,
        );

        final rawWindows = data['windows'] as List<dynamic>? ?? [];
        final windows = rawWindows.map((rw) {
          final w = rw as Map<String, dynamic>;
          return LimitWindow(
            id: w['id'] as String,
            label: w['label'] as String,
            usedFraction: (w['usedFraction'] as num?)?.toDouble(),
            remaining: (w['remaining'] as num?)?.toInt(),
            used: (w['used'] as num?)?.toInt(),
            resetsAt: w['resetsAt'] != null ? DateTime.tryParse(w['resetsAt'] as String) : null,
          );
        }).toList();

        final fetchedAt = DateTime.tryParse(data['fetchedAt'] as String? ?? '') ?? DateTime.now();

        final snapshot = ProviderSnapshot(
          id: data['id'] as String,
          displayName: data['displayName'] as String,
          glyph: glyph,
          fidelity: fidelity,
          status: ProviderStatusStale(fetchedAt),
          windows: windows,
          headlineID: data['headlineID'] as String?,
        );

        result[entry.key] = (snapshot: snapshot, fetchedAt: fetchedAt);
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  DateTime? loadBackoffUntil(String providerID) {
    try {
      final backoffFile = File('${directory.path}/backoff_$providerID.txt');
      if (!backoffFile.existsSync()) return null;
      final text = backoffFile.readAsStringSync().trim();
      return DateTime.tryParse(text);
    } catch (_) {
      return null;
    }
  }

  void saveBackoffUntil(DateTime? date, {required String providerID}) {
    try {
      if (!directory.existsSync()) directory.createSync(recursive: true);
      final backoffFile = File('${directory.path}/backoff_$providerID.txt');
      if (date == null) {
        if (backoffFile.existsSync()) backoffFile.deleteSync();
      } else {
        backoffFile.writeAsStringSync(date.toIso8601String());
      }
    } catch (_) {}
  }
}
