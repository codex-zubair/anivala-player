import 'package:flutter_test/flutter_test.dart';
import 'package:watchanimetv/core/media_item.dart';
import 'package:watchanimetv/core/media_library.dart';

void main() {
  group('extension + detection', () {
    test('recognises video extensions case-insensitively', () {
      expect(MediaLibrary.isVideo('/x/Naruto 1.mp4'), isTrue);
      expect(MediaLibrary.isVideo('/x/show.MKV'), isTrue);
      expect(MediaLibrary.isVideo('/x/clip.webm'), isTrue);
      expect(MediaLibrary.isVideo('/x/notes.txt'), isFalse);
      expect(MediaLibrary.isVideo('/x/noext'), isFalse);
    });

    test('extensionOf and fileNameOf', () {
      expect(MediaLibrary.extensionOf('a/b/c/Dune.Part2.MKV'), 'mkv');
      expect(MediaLibrary.fileNameOf('a/b/c/ep1.mp4'), 'ep1.mp4');
      expect(MediaLibrary.extensionOf('name.'), '');
    });
  });

  group('folderOf', () {
    test('extracts parent folder', () {
      expect(MediaLibrary.folderOf('/storage/Anime/Naruto/ep1.mp4'), 'Naruto');
      expect(MediaLibrary.folderOf('/ep1.mp4'), 'Library');
    });
  });

  group('fromPaths', () {
    test('filters non-videos, de-duplicates and sorts by title', () {
      final List<MediaItem> items = MediaLibrary.fromPaths(<String>[
        '/v/Zebra.mkv',
        '/v/alpha.mp4',
        '/v/readme.txt',
        '/v/alpha.mp4',
        '/v/Middle.avi',
      ]);
      expect(items.map((MediaItem e) => e.title).toList(),
          <String>['alpha', 'Middle', 'Zebra']);
      expect(items.length, 3);
    });

    test('itemFromPath strips extension and sets folder', () {
      final MediaItem item =
          MediaLibrary.itemFromPath('/storage/emulated/0/Anime/Bleach/ep12.mp4');
      expect(item.title, 'ep12');
      expect(item.folder, 'Bleach');
      expect(item.path, endsWith('ep12.mp4'));
    });
  });

  group('groupByFolder', () {
    test('groups and sorts folders and items', () {
      final Map<String, List<MediaItem>> groups = MediaLibrary.groupByFolder(
        <MediaItem>[
          MediaLibrary.itemFromPath('/a/Zeta/b.mp4'),
          MediaLibrary.itemFromPath('/a/Alpha/c.mp4'),
          MediaLibrary.itemFromPath('/a/Zeta/a.mp4'),
        ],
      );
      expect(groups.keys.toList(), <String>['Alpha', 'Zeta']);
      expect(groups['Zeta']!.map((MediaItem e) => e.title),
          <String>['a', 'b']);
    });
  });

  group('search', () {
    final List<MediaItem> lib = <MediaItem>[
      MediaLibrary.itemFromPath('/l/Naruto/ep1.mp4'),
      MediaLibrary.itemFromPath('/l/One Piece/ep2.mp4'),
    ];

    test('matches title and folder case-insensitively', () {
      expect(MediaLibrary.search(lib, 'naruto').length, 1);
      expect(MediaLibrary.search(lib, 'PIECE').length, 1);
      expect(MediaLibrary.search(lib, '  ').length, 2);
      expect(MediaLibrary.search(lib, 'zzz'), isEmpty);
    });
  });

  group('looksLikeAnime', () {
    test('detects episode-style names', () {
      expect(MediaLibrary.looksLikeAnime('Anime - 12'), isTrue);
      expect(MediaLibrary.looksLikeAnime('Show Episode 3'), isTrue);
      expect(MediaLibrary.looksLikeAnime('S02E05'), isTrue);
      expect(MediaLibrary.looksLikeAnime('Random Documentary'), isFalse);
    });
  });

  group('MediaItem json', () {
    test('round-trips', () {
      final MediaItem item = MediaLibrary.itemFromPath(
        '/v/ep1.mp4',
        id: '42',
        duration: const Duration(seconds: 90),
        sizeBytes: 1024,
      );
      final MediaItem back = MediaItem.fromJson(item.toJson());
      expect(back, item);
      expect(back.duration, const Duration(seconds: 90));
      expect(back.sizeBytes, 1024);
    });
  });
}
