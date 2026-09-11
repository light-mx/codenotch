class ReleaseChange {
  final String title;
  final String detail;

  const ReleaseChange({required this.title, this.detail = ''});
}

class ReleaseNote {
  final String version;
  final String headline;
  final List<ReleaseChange> changes;

  const ReleaseNote({
    required this.version,
    required this.headline,
    required this.changes,
  });
}

abstract final class ReleaseNotes {
  static const List<ReleaseNote> all = [
    ReleaseNote(
      version: '1.5.0',
      headline: 'Two more providers, and a live account plan that was silently dropped.',
      changes: [
        ReleaseChange(
          title: 'Grok is a new ring',
          detail: "SuperGrok's weekly Grok Build allowance, read from the same billing endpoint the CLI uses, with the session in ~/.grok/auth.json.",
        ),
        ReleaseChange(
          title: "OpenCode's Go plan is a new ring",
          detail: 'Reads the Go plan\'s official usage endpoint with the key OpenCode itself stores on sign-in — no second sign-in.',
        ),
        ReleaseChange(
          title: 'A real Codex account went unmetered',
          detail: 'Codex\'s live reading only recognised a 5-hour and a 7-day window. Free-plan 30-day limits are now tracked.',
        ),
        ReleaseChange(
          title: 'Switching a provider off now really stops it',
          detail: 'Opening Settings stops reading switched-off accounts and drops in-flight updates.',
        ),
      ],
    ),
    ReleaseNote(
      version: '1.4.1',
      headline: 'Waking from sleep no longer erases a reading.',
      changes: [
        ReleaseChange(
          title: 'A ring survives waking your Mac',
          detail: 'Ages numbers instead of throwing them away when keychain is temporarily locked right after waking.',
        ),
      ],
    ),
  ];

  static ReleaseNote? noteFor(String version) {
    for (final note in all) {
      if (note.version == version) return note;
    }
    return all.isNotEmpty ? all.first : null;
  }
}
