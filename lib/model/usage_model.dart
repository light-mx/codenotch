import 'package:intl/intl.dart';
import '../providers/provider_glyph.dart';
import 'reset_copy.dart';

/// How much to trust a provider's numbers. The UI never presents a derived or
/// manual figure as if a vendor had published it.
enum Fidelity {
  official,
  derived,
  manual;

  /// Prefix shown in front of a percentage that we worked out ourselves.
  String get qualifier => this == Fidelity.official ? '' : '~';
}

/// Status of a provider's credentials or connection.
sealed class ProviderStatus {
  const ProviderStatus();

  bool get isStale => false;
  DateTime? get staleSince => null;
}

final class ProviderStatusOk extends ProviderStatus {
  const ProviderStatusOk();
}

final class ProviderStatusStale extends ProviderStatus {
  final DateTime since;
  const ProviderStatusStale(this.since);

  @override
  bool get isStale => true;

  @override
  DateTime? get staleSince => since;
}

final class ProviderStatusNeedsAuth extends ProviderStatus {
  const ProviderStatusNeedsAuth();
}

final class ProviderStatusAccessDenied extends ProviderStatus {
  const ProviderStatusAccessDenied();
}

final class ProviderStatusUnsupported extends ProviderStatus {
  final String why;
  const ProviderStatusUnsupported(this.why);
}

final class ProviderStatusError extends ProviderStatus {
  final String why;
  const ProviderStatusError(this.why);
}

/// One metered window a provider exposes.
class LimitWindow {
  final String id;
  final String label;
  final double? usedFraction;
  final int? remaining;
  final int? used;
  final DateTime? resetsAt;

  const LimitWindow({
    required this.id,
    required this.label,
    this.usedFraction,
    this.remaining,
    this.used,
    this.resetsAt,
  });

  /// What the tooltip says on the line under the bar.
  String get summary {
    if (usedFraction != null) {
      final int usedPercent = (usedFraction! * 100).round();
      final int leftPercent = (100 - usedPercent).clamp(0, 100);
      return '$usedPercent% Used · $leftPercent% left';
    }
    if (remaining != null) {
      return remaining == 1 ? '1 left' : '$remaining left';
    }
    if (used != null) {
      return used == 1 ? '1 used' : '$used used';
    }
    return 'No reading';
  }
}

/// A limit that has been reached, even where the headline still shows room.
class UsageBlock {
  final String reason;
  final DateTime? resetsAt;

  const UsageBlock({required this.reason, this.resetsAt});

  String summary({DateTime? now}) {
    final current = now ?? DateTime.now();
    if (resetsAt == null || resetsAt!.isBefore(current)) return reason;
    final int days = ResetCopy.daysApart(current, resetsAt!);
    final formatter = days >= 1 ? DateFormat('E h:mm a') : DateFormat('h:mm a');
    return '$reason until ${formatter.format(resetsAt!)}';
  }
}

/// One snapshot of a provider's usage readings.
class ProviderSnapshot {
  final String id;
  final String displayName;
  final ProviderGlyph glyph;
  final Fidelity fidelity;
  final ProviderStatus status;
  final List<LimitWindow> windows;
  final String? headlineID;
  final UsageBlock? block;

  const ProviderSnapshot({
    required this.id,
    required this.displayName,
    required this.glyph,
    required this.fidelity,
    required this.status,
    required this.windows,
    this.headlineID,
    this.block,
  });

  LimitWindow? get headline {
    if (headlineID != null) {
      for (final w in windows) {
        if (w.id == headlineID) return w;
      }
    }
    return windows.isNotEmpty ? windows.first : null;
  }

  double? get usedFraction => headline?.usedFraction;

  String get headlineText {
    if (usedFraction != null) {
      return '${(usedFraction! * 100).round()}%';
    }
    if (headline?.remaining != null) return '${headline!.remaining}';
    if (headline?.used != null) return '${headline!.used}';
    return '—';
  }

  bool get hasReading => windows.isNotEmpty;

  double? get ringFraction => usedFraction;

  String get authPrompt {
    switch (id) {
      case 'claude':
        return 'Sign in to Claude Code to read your usage';
      case 'cursor':
        return 'Sign in to Cursor in the editor';
      case 'codex':
        return 'Sign in to Codex to read your usage';
      case 'gemini':
        return 'Sign in to Antigravity to read your usage';
      case 'glm':
        return 'Set up a GLM Coding Plan key for a coding tool to read your usage';
      case 'opencode':
        return 'Connect the Go plan in OpenCode to read your usage';
      default:
        if (id.startsWith('claude-')) {
          final slug = id.substring(7);
          return 'Sign in to Claude Code in ~/.claude-$slug to read your usage';
        }
        return 'Sign in to $displayName to read your usage';
    }
  }

  String? get statusMessage {
    if (hasReading) return null;
    return switch (status) {
      ProviderStatusNeedsAuth() => authPrompt,
      ProviderStatusAccessDenied() =>
        "Codenotch was refused access to $displayName's saved login. Click this ring to ask again, and choose Always Allow.",
      ProviderStatusUnsupported(why: final why) => why,
      ProviderStatusError(why: final why) => "Couldn't read usage — $why",
      ProviderStatusStale() || ProviderStatusOk() => 'Waiting for the first reading…',
    };
  }
}

class ProviderAccount {
  final String? label;
  final String? plan;
  final String source;
  final Uri? manageURL;

  const ProviderAccount({
    this.label,
    this.plan,
    required this.source,
    this.manageURL,
  });

  String get summary {
    final parts = <String>[];
    if (label != null && label!.isNotEmpty) parts.add(label!);
    if (plan != null && plan!.isNotEmpty) {
      parts.add(plan![0].toUpperCase() + plan!.substring(1));
    }
    parts.add('via $source');
    return parts.join(' · ');
  }
}

class ProviderSummary {
  final String id;
  final String displayName;
  final ProviderGlyph glyph;
  final ProviderAccount? account;
  final ProviderStatus status;
  final bool isConnected;
  final bool wasRefusedAccess;

  const ProviderSummary({
    required this.id,
    required this.displayName,
    required this.glyph,
    this.account,
    required this.status,
    required this.isConnected,
    this.wasRefusedAccess = false,
  });
}
