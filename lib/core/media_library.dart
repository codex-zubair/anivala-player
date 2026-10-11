import 'media_item.dart';

/// Pure-Dart logic that decides which files are playable media and how the
/// library is grouped and searched. Kept free of Flutter/plugin imports so it
/// is fully unit-testable.
class MediaLibrary {
  /// Video container extensions AniLoom recognises.
  static const Set<String> videoExtensions = <String>{
    'mp4', 'mkv', 'webm', 'avi', 'mov', 'm4v', '3gp', 'ts', 'm2ts',
    'flv', 'wmv', 'mpg', 'mpeg', 'ogv', 'vob', 'mts', 'divx', 'rmvb',
  };

  /// Anime-friendly filename markers used for a light "looks like anime" hint.
  static const List<String> _animeHints = <String>[
    'anime', 'sub', 'subbed', 'dub', 'dubbed', 'episode', 'ep ', 'ep.',
    'ova', 'ona', 'movie', 'season', 's01', 's02', 's03',
  ];

  const MediaLibrary._();

  /// Lowercased extension of a path or file name, without the dot.
  static String extensionOf(String path) {
    final String name = fileNameOf(path).toLowerCase();
    final int dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1);
  }

  static String fileNameOf(String path) {
    final String normalised = path.replaceAll('\\', '/');
    final int slash = normalised.lastIndexOf('/');
    return slash == -1 ? normalised : normalised.substring(slash + 1);
  }

  static String _withoutExtension(String name) {
    final int dot = name.lastIndexOf('.');
    return dot <= 0 ? name : name.substring(0, dot);
  }

  /// Whether [path] points at a supported video file.
  static bool isVideo(String path) =>
      videoExtensions.contains(extensionOf(path));

  /// Extracts the parent folder name from a path (`/a/b/c.mp4` -> `b`).
  static String folderOf(String path) {
    final String normalised = path.replaceAll('\\', '/');
    final int slash = normalised.lastIndexOf('/');
    if (slash <= 0) return 'Library';
    final String parent = normalised.substring(0, slash);
    final int prev = parent.lastIndexOf('/');
    final String folder = prev == -1 ? parent : parent.substring(prev + 1);
    return folder.isEmpty ? 'Library' : folder;
  }

  /// Builds a [MediaItem] from a raw file path plus optional metadata.
  static MediaItem itemFromPath(
    String path, {
    String? id,
    Duration? duration,
    int? sizeBytes,
    String? thumbnailPath,
  }) {
    final String name = fileNameOf(path);
    return MediaItem(
      id: id ?? path,
      title: _withoutExtension(name),
      path: path,
      folder: folderOf(path),
      duration: duration,
      sizeBytes: sizeBytes,
      thumbnailPath: thumbnailPath,
    );
  }

  /// Filters raw paths down to sorted, de-duplicated video items.
  static List<MediaItem> fromPaths(Iterable<String> paths) {
    final Set<String> seen = <String>{};
    final List<MediaItem> items = <MediaItem>[];
    for (final String path in paths) {
      if (path.isEmpty || !isVideo(path) || !seen.add(path)) continue;
      items.add(itemFromPath(path));
    }
    items.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return items;
  }

  /// Groups items by folder, folders sorted by name and items by title.
  static Map<String, List<MediaItem>> groupByFolder(List<MediaItem> items) {
    final Map<String, List<MediaItem>> groups = <String, List<MediaItem>>{};
    for (final MediaItem item in items) {
      groups.putIfAbsent(item.folder, () => <MediaItem>[]).add(item);
    }
    final List<String> keys = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final Map<String, List<MediaItem>> sorted =
        <String, List<MediaItem>>{};
    for (final String key in keys) {
      final List<MediaItem> list = groups[key]!
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      sorted[key] = list;
    }
    return sorted;
  }

  /// Case-insensitive search over title and folder.
  static List<MediaItem> search(List<MediaItem> items, String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return List<MediaItem>.of(items);
    return items
        .where((MediaItem item) =>
            item.title.toLowerCase().contains(q) ||
            item.folder.toLowerCase().contains(q))
        .toList();
  }

  /// Heuristic: does the file name look like an anime episode? Used only for a
  /// cosmetic badge; it never affects playback.
  static bool looksLikeAnime(String title) {
    final String t = ' ${title.toLowerCase()} ';
    for (final String hint in _animeHints) {
      if (t.contains(hint)) return true;
    }
    // Episode patterns such as " - 12" or "12v2" or "[12]".
    final RegExp patterns = RegExp(
      r'(\b(s\d{1,2}e\d{1,2})\b)|(\bep?\s?\d{1,4}\b)|(\[\d{1,4}\])|(\s-\s\d{1,4}\b)',
      caseSensitive: false,
    );
    return patterns.hasMatch(t);
  }
}
