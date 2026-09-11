import 'package:flutter/material.dart';
import '../design_system/palette.dart';
import '../model/usage_model.dart';
import '../notch/notch_edge.dart';
import '../providers/provider_glyph.dart';
import 'app_presence.dart';
import 'notch_visibility.dart';
import 'preferences.dart';

class SettingsView extends StatefulWidget {
  final Preferences preferences;
  final List<ProviderSummary> Function() providers;
  final void Function(String id)? onSignOut;
  final bool Function(String id)? onSignIn;
  final void Function(String id)? onRetry;

  const SettingsView({
    super.key,
    required this.preferences,
    required this.providers,
    this.onSignOut,
    this.onSignIn,
    this.onRetry,
  });

  static const double width = 500.0;
  static const double height = 560.0;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late List<ProviderSummary> _accounts;

  @override
  void initState() {
    super.initState();
    _accounts = widget.providers();
  }

  void _reloadAccounts() {
    setState(() {
      _accounts = widget.providers();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.ringTrack),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.preferences;

    return Container(
      width: SettingsView.width,
      height: SettingsView.height,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Integrations ---
                  _buildSectionHeader('Integrations'),
                  _buildCard(
                    children: [
                      for (int i = 0; i < _accounts.length; i++) ...[
                        if (i > 0) const Divider(height: 16, color: Palette.ringTrack),
                        Row(
                          children: [
                            ProviderGlyphView(glyph: _accounts[i].glyph, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _accounts[i].displayName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Palette.textPrimary,
                                    ),
                                  ),
                                  if (_accounts[i].account?.label != null)
                                    Text(
                                      _accounts[i].account!.label!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Palette.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Switch(
                              value: !prefs.disconnectedProviders.contains(_accounts[i].id),
                              onChanged: (val) {
                                prefs.toggleProvider(_accounts[i].id);
                                _reloadAccounts();
                              },
                              activeColor: Palette.ample,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Text(
                        'Codenotch never signs in — each reading is borrowed from the tool that already holds the account. '
                        'Signing out here stops the credential being read, but leaves you signed in to that tool.',
                        style: TextStyle(fontSize: 11, color: Palette.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- Appearance ---
                  _buildSectionHeader('Appearance'),
                  _buildCard(
                    children: [
                      const Text('Show', style: TextStyle(color: Palette.textPrimary, fontSize: 13)),
                      const SizedBox(height: 6),
                      SegmentedButton<NotchVisibility>(
                        segments: [
                          for (final v in NotchVisibility.values)
                            ButtonSegment(value: v, label: Text(v.title)),
                        ],
                        selected: {prefs.notchVisibility},
                        onSelectionChanged: (set) => prefs.setNotchVisibility(set.first),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        prefs.notchVisibility.explanation,
                        style: const TextStyle(fontSize: 11, color: Palette.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      const Text('Edge', style: TextStyle(color: Palette.textPrimary, fontSize: 13)),
                      const SizedBox(height: 6),
                      SegmentedButton<NotchEdge>(
                        segments: [
                          for (final e in NotchEdge.values)
                            ButtonSegment(value: e, label: Text(e.title)),
                        ],
                        selected: {prefs.notchEdge},
                        onSelectionChanged: (set) => prefs.setNotchEdge(set.first),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        prefs.notchEdge.explanation,
                        style: const TextStyle(fontSize: 11, color: Palette.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      const Text('App icon', style: TextStyle(color: Palette.textPrimary, fontSize: 13)),
                      const SizedBox(height: 6),
                      SegmentedButton<AppPresence>(
                        segments: [
                          for (final p in AppPresence.values)
                            ButtonSegment(value: p, label: Text(p.title)),
                        ],
                        selected: {prefs.appPresence},
                        onSelectionChanged: (set) => prefs.setAppPresence(set.first),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        prefs.appPresence.explanation,
                        style: const TextStyle(fontSize: 11, color: Palette.textSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- General ---
                  _buildSectionHeader('General'),
                  _buildCard(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Open Codenotch at login',
                            style: TextStyle(color: Palette.textPrimary, fontSize: 13),
                          ),
                          Switch(
                            value: prefs.launchAtLogin,
                            onChanged: (val) => prefs.setLaunchAtLogin(val),
                            activeColor: Palette.ample,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom credit
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF181818),
              border: Border(top: BorderSide(color: Palette.ringTrack)),
            ),
            child: const Center(
              child: Text(
                'App designed and developed by @hivinz_',
                style: TextStyle(fontSize: 11, color: Palette.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
