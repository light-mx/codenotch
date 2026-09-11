import 'package:flutter/material.dart';
import '../design_system/palette.dart';
import 'release_notes.dart';

class WhatsNewView extends StatelessWidget {
  final ReleaseNote note;
  final VoidCallback onContinue;

  const WhatsNewView({
    super.key,
    required this.note,
    required this.onContinue,
  });

  static const double width = 420.0;
  static const double height = 440.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 28, right: 28, top: 26, bottom: 20),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Palette.notch,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Palette.ringTrack),
                  ),
                  child: const Center(
                    child: Icon(Icons.code, color: Palette.ample, size: 28),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "What's new in Codenotch",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Palette.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${note.version}',
                  style: const TextStyle(fontSize: 12, color: Palette.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  note.headline,
                  style: const TextStyle(fontSize: 13, color: Palette.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Changes list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: note.changes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final change = note.changes[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Palette.ample,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            change.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Palette.textPrimary,
                            ),
                          ),
                          if (change.detail.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              change.detail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Palette.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1, color: Palette.ringTrack),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.textPrimary,
                    foregroundColor: Palette.notch,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
