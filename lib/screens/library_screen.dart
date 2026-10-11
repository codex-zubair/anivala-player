import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/media_item.dart';
import '../core/media_library.dart';
import '../state/library_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/media_card.dart';
import 'player_screen.dart';

/// The local media library: scan, search, and browse scanned video files.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  void _open(BuildContext context, MediaItem item) {
    final LibraryState state = context.read<LibraryState>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(
          item: item,
          startAt: state.positionFor(item.id)?.position,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LibraryState state = context.watch<LibraryState>();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  onChanged: state.setQuery,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search your library',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: state.toggleView,
                tooltip: state.gridView ? 'List view' : 'Grid view',
                icon: Icon(
                  state.gridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                onPressed: state.scanning ? null : state.rescan,
                tooltip: 'Scan device',
                icon: state.scanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        if (state.lastError != null && state.library.isEmpty)
          _Notice(text: state.lastError!),
        Expanded(child: _body(context, state)),
      ],
    );
  }

  Widget _body(BuildContext context, LibraryState state) {
    if (state.scanning && state.library.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent2),
      );
    }
    if (state.library.isEmpty) {
      return EmptyState(
        icon: Icons.video_library_outlined,
        title: 'No videos yet',
        message:
            'Tap the scan button to find video files stored on this device. '
            'AniLoom only reads local files — nothing is uploaded.',
        action: FilledButton.icon(
          onPressed: state.rescan,
          icon: const Icon(Icons.search_rounded),
          label: const Text('Scan device'),
        ),
      );
    }

    final List<MediaItem> items = state.visibleLibrary;
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matches',
        message: 'Try a different search term.',
      );
    }

    if (state.gridView) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 1.18,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int i) {
          final MediaItem item = items[i];
          final double progress =
              state.positionFor(item.id)?.progress ?? 0;
          return MediaGridCard(
            item: item,
            progress: progress,
            onTap: () => _open(context, item),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppTheme.divider),
      itemBuilder: (BuildContext context, int i) {
        final MediaItem item = items[i];
        final double progress = state.positionFor(item.id)?.progress ?? 0;
        final String subtitle = item.duration == null
            ? item.folder
            : '${item.folder} · ${Formatters.duration(item.duration!)}';
        return MediaListTile(
          item: item,
          progress: progress,
          subtitle: subtitle,
          onTap: () => _open(context, item),
          trailing: MediaLibrary.looksLikeAnime(item.title)
              ? const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Pill(label: 'Anime', color: AppTheme.warm),
                )
              : null,
        );
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppTheme.warm),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
