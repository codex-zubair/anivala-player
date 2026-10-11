import 'media_item.dart';

/// A saved playback position for one media item — the heart of the
/// "Continue Watching" dashboard. Pure Dart so it is fully unit-testable.
class ResumeEntry {
  const ResumeEntry({
    required this.mediaId,
    required this.positionMs,
    required this.durationMs,
    required this.updatedAt,
    required this.title,
    required this.path,
    required this.folder,
  });

  final String mediaId;
  final int positionMs;
  final int durationMs;
  final DateTime updatedAt;
  final String title;
  final String path;
  final String folder;

  Duration get position => Duration(milliseconds: positionMs);
  Duration get duration => Duration(milliseconds: durationMs);

  /// Fraction watched, clamped to 0..1. Returns 0 when duration is unknown.
  double get progress {
    if (durationMs <= 0) return 0;
    final double p = positionMs / durationMs;
    return p.clamp(0.0, 1.0);
  }

  /// True when the user has essentially finished this item.
  bool get isFinished => durationMs > 0 && progress >= 0.98;

  Duration get remaining {
    final int r = durationMs - positionMs;
    return Duration(milliseconds: r < 0 ? 0 : r);
  }

  /// A resumable entry must have a real, non-trivial position and not be
  /// finished — this is what separates "Continue Watching" from a plain
  /// history list.
  bool get isResumable => positionMs >= 15000 && !isFinished;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mediaId': mediaId,
        'positionMs': positionMs,
        'durationMs': durationMs,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'title': title,
        'path': path,
        'folder': folder,
      };

  static ResumeEntry fromJson(Map<String, dynamic> json) {
    return ResumeEntry(
      mediaId: json['mediaId'] as String,
      positionMs: (json['positionMs'] as num).toInt(),
      durationMs: (json['durationMs'] as num).toInt(),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as num).toInt()),
      title: (json['title'] as String?) ?? '',
      path: (json['path'] as String?) ?? '',
      folder: (json['folder'] as String?) ?? '',
    );
  }

  MediaItem toMediaItem() => MediaItem(
        id: mediaId,
        title: title,
        path: path,
        folder: folder,
        duration: durationMs > 0 ? duration : null,
      );
}

/// Stateless helpers over a collection of [ResumeEntry] values.
class ContinueWatching {
  const ContinueWatching._();

  /// Minimum position (ms) before an item is offered as "continue watching".
  static const int minPositionMs = 15000;

  /// Builds an entry from the current player state.
  static ResumeEntry build({
    required MediaItem item,
    required Duration position,
    required Duration duration,
    required DateTime now,
  }) {
    return ResumeEntry(
      mediaId: item.id,
      positionMs: position.inMilliseconds,
      durationMs: duration.inMilliseconds,
      updatedAt: now,
      title: item.title,
      path: item.path,
      folder: item.folder,
    );
  }

  /// The dashboard list: only resumable entries, most recently watched first.
  static List<ResumeEntry> dashboard(List<ResumeEntry> entries) {
    final List<ResumeEntry> list = entries
        .where((ResumeEntry e) => e.isResumable)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Insert/update [entry] keyed by media id, keeping the list bounded.
  static List<ResumeEntry> upsert(
    List<ResumeEntry> entries,
    ResumeEntry entry, {
    int max = 100,
  }) {
    final List<ResumeEntry> next = entries
        .where((ResumeEntry e) => e.mediaId != entry.mediaId)
        .toList()
      ..add(entry)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (next.length > max) {
      return next.sublist(0, max);
    }
    return next;
  }

  static List<ResumeEntry> remove(List<ResumeEntry> entries, String mediaId) {
    return entries.where((ResumeEntry e) => e.mediaId != mediaId).toList();
  }

  static ResumeEntry? find(List<ResumeEntry> entries, String mediaId) {
    for (final ResumeEntry e in entries) {
      if (e.mediaId == mediaId) return e;
    }
    return null;
  }
}
