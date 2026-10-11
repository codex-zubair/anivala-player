import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/resume_entry.dart';
import '../state/library_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/media_card.dart';
import 'player_screen.dart';

/// The automated Continue Watching dashboard, driven entirely by local
/// playback positions.
class ContinueWatchingScreen extends StatelessWidget {
  const ContinueWatchingScreen({super.key, this.onOpenLibrary});

  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final LibraryState state = context.watch<LibraryState>();
    final List<ResumeEntry> entries = state.continueWatching;

    if (entries.isEmpty) {
      return EmptyState(
        icon: Icons.play_circle_outline_rounded,
        title: 'Nothing in progress',
        message:
            'Start watching any local video and AniLoom will remember where '
            'you stopped — right here, on your device.',
        action: FilledButton.icon(
          onPressed: onOpenLibrary,
          icon: const Icon(Icons.video_library_outlined),
          label: const Text('Open library'),
        ),
      );
    }

    final DateTime now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'Continue Watching',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Pill(label: '${entries.length} in progress', color: AppTheme.accent2),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Resumes exactly where you left off. Stored only on this device.',
          style: TextStyle(color: AppTheme.muted, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        for (final ResumeEntry entry in entries) ...<Widget>[
          ResumeCard(
            entry: entry,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PlayerScreen(
                  item: entry.toMediaItem(),
                  startAt: entry.position,
                ),
              ),
            ),
            onRemove: () => state.removeResume(entry.mediaId),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Last watched ${Formatters.relativeTime(entry.updatedAt, now)}',
              style: const TextStyle(color: AppTheme.muted, fontSize: 11.5),
            ),
          ),
        ],
      ],
    );
  }
}
