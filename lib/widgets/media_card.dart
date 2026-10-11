import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/media_item.dart';
import '../core/resume_entry.dart';
import '../theme/app_theme.dart';

/// Deterministic accent colour per title, for pleasant placeholder art.
Color _toneFor(String seed) {
  const List<Color> tones = <Color>[
    AppTheme.accent,
    AppTheme.accent2,
    Color(0xFFF472B6),
    Color(0xFF34D399),
    AppTheme.warm,
    Color(0xFF60A5FA),
  ];
  int h = 0;
  for (final int c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return tones[h % tones.length];
}

/// Placeholder "poster" since AniLoom reads no network artwork.
class MediaThumb extends StatelessWidget {
  const MediaThumb({super.key, required this.item, this.progress = 0});

  final MediaItem item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final Color tone = _toneFor(item.title);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    tone.withValues(alpha: 0.30),
                    AppTheme.surfaceAlt,
                  ],
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 44,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            if (item.duration != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    Formatters.duration(item.duration!),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            if (progress > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.accent2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grid tile for the library.
class MediaGridCard extends StatelessWidget {
  const MediaGridCard({
    super.key,
    required this.item,
    required this.onTap,
    this.progress = 0,
  });

  final MediaItem item;
  final VoidCallback onTap;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MediaThumb(item: item, progress: progress),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          const SizedBox(height: 2),
          Text(
            item.folder,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.muted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

/// Row tile for the library list / continue-watching.
class MediaListTile extends StatelessWidget {
  const MediaListTile({
    super.key,
    required this.item,
    required this.onTap,
    this.progress = 0,
    this.subtitle,
    this.trailing,
  });

  final MediaItem item;
  final VoidCallback onTap;
  final double progress;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            SizedBox(width: 132, child: MediaThumb(item: item, progress: progress)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? item.folder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Continue-watching card.
class ResumeCard extends StatelessWidget {
  const ResumeCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onRemove,
  });

  final ResumeEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final int pct = (entry.progress * 100).round();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 120,
              child: MediaThumb(
                item: entry.toMediaItem(),
                progress: entry.progress,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.title.isEmpty ? 'Untitled' : entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$pct% watched · ${Formatters.duration(entry.remaining)} left',
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.play_arrow_rounded,
                        size: 18,
                        color: AppTheme.accent2,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Resume',
                        style: TextStyle(
                          color: AppTheme.accent2,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onRemove,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Remove from Continue Watching',
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
