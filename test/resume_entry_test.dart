import 'package:flutter_test/flutter_test.dart';
import 'package:watchanimetv/core/media_item.dart';
import 'package:watchanimetv/core/resume_entry.dart';

void main() {
  final MediaItem item = MediaLibraryItem.sample();

  group('ResumeEntry', () {
    test('progress is clamped and finished detected', () {
      final ResumeEntry e = ResumeEntry(
        mediaId: 'a',
        positionMs: 99000,
        durationMs: 100000,
        updatedAt: DateTime(2026),
        title: 'T',
        path: '/p',
        folder: 'F',
      );
      expect(e.progress, closeTo(0.99, 0.0001));
      expect(e.isFinished, isTrue);
      expect(e.remaining, const Duration(seconds: 1));
    });

    test('zero duration yields zero progress', () {
      final ResumeEntry e = ResumeEntry(
        mediaId: 'a',
        positionMs: 0,
        durationMs: 0,
        updatedAt: DateTime(2026),
        title: 'T',
        path: '/p',
        folder: 'F',
      );
      expect(e.progress, 0);
      expect(e.isFinished, isFalse);
    });

    test('isResumable needs a meaningful position and not finished', () {
      final ResumeEntry early = _entry(positionMs: 5000, durationMs: 100000);
      final ResumeEntry mid = _entry(positionMs: 20000, durationMs: 100000);
      final ResumeEntry done = _entry(positionMs: 99900, durationMs: 100000);
      expect(early.isResumable, isFalse);
      expect(mid.isResumable, isTrue);
      expect(done.isResumable, isFalse);
    });

    test('json round-trip', () {
      final ResumeEntry e = _entry(positionMs: 30000, durationMs: 120000);
      expect(ResumeEntry.fromJson(e.toJson()).positionMs, 30000);
    });

    test('toMediaItem carries identity', () {
      final ResumeEntry e = _entry(positionMs: 30000, durationMs: 120000);
      final MediaItem m = e.toMediaItem();
      expect(m.id, e.mediaId);
      expect(m.path, e.path);
    });
  });

  group('ContinueWatching.upsert', () {
    test('updates existing and orders by recency', () {
      final List<ResumeEntry> list = <ResumeEntry>[
        _entry(id: 'a', updatedAt: DateTime(2026, 1, 1), positionMs: 30000),
      ];
      final List<ResumeEntry> next = ContinueWatching.upsert(
        list,
        _entry(id: 'a', updatedAt: DateTime(2026, 2, 1), positionMs: 50000),
      );
      expect(next.length, 1);
      expect(next.first.positionMs, 50000);
    });

    test('enforces the max bound', () {
      List<ResumeEntry> list = <ResumeEntry>[];
      for (int i = 0; i < 5; i++) {
        list = ContinueWatching.upsert(
          list,
          _entry(id: 'x$i', updatedAt: DateTime(2026, 1, i + 1)),
          max: 3,
        );
      }
      expect(list.length, 3);
      expect(list.first.mediaId, 'x4');
    });
  });

  group('ContinueWatching.dashboard', () {
    test('filters non-resumable and sorts newest first', () {
      final List<ResumeEntry> list = <ResumeEntry>[
        _entry(id: 'early', positionMs: 3000, updatedAt: DateTime(2026, 1, 5)),
        _entry(id: 'recent', positionMs: 30000, updatedAt: DateTime(2026, 1, 9)),
        _entry(id: 'mid', positionMs: 30000, updatedAt: DateTime(2026, 1, 3)),
      ];
      final List<ResumeEntry> dash = ContinueWatching.dashboard(list);
      expect(dash.map((ResumeEntry e) => e.mediaId).toList(),
          <String>['recent', 'mid']);
    });
  });

  group('ContinueWatching.remove/find', () {
    test('remove and find behave', () {
      final List<ResumeEntry> list = <ResumeEntry>[
        _entry(id: 'a'),
        _entry(id: 'b'),
      ];
      expect(ContinueWatching.find(list, 'b')!.mediaId, 'b');
      expect(ContinueWatching.remove(list, 'a').length, 1);
      expect(ContinueWatching.find(list, 'z'), isNull);
    });
  });

  test('build maps player state into an entry', () {
    final ResumeEntry e = ContinueWatching.build(
      item: item,
      position: const Duration(seconds: 42),
      duration: const Duration(minutes: 5),
      now: DateTime(2026, 5, 1),
    );
    expect(e.positionMs, 42000);
    expect(e.durationMs, 300000);
    expect(e.title, item.title);
  });
}

ResumeEntry _entry({
  String id = 'a',
  int positionMs = 30000,
  int durationMs = 100000,
  DateTime? updatedAt,
}) {
  return ResumeEntry(
    mediaId: id,
    positionMs: positionMs,
    durationMs: durationMs,
    updatedAt: updatedAt ?? DateTime(2026, 1, 1),
    title: 'Title $id',
    path: '/v/$id.mp4',
    folder: 'Shows',
  );
}

/// Small helper to avoid importing the scanner in tests.
class MediaLibraryItem {
  static MediaItem sample() => const MediaItem(
        id: 'sample',
        title: 'Sample',
        path: '/v/sample.mp4',
        folder: 'Shows',
      );
}
