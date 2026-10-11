import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/media_item.dart';
import '../core/media_library.dart';

/// Result of a scan attempt, so the UI can explain exactly what happened.
class ScanResult {
  const ScanResult({
    required this.items,
    required this.permissionGranted,
    this.error,
  });

  final List<MediaItem> items;
  final bool permissionGranted;
  final String? error;
}

/// Reads the device's local video files from Android's MediaStore.
///
/// AniLoom never touches the network. On Android 13+ it asks only for the
/// scoped `READ_MEDIA_VIDEO` permission; on older versions it asks for
/// `READ_EXTERNAL_STORAGE`. The app does not request `MANAGE_EXTERNAL_STORAGE`.
class MediaScanner {
  const MediaScanner._();

  static const MethodChannel _channel =
      MethodChannel('com.anivala.watchanimetv/scanner');

  /// Ensures the appropriate media permission is granted (or granted via the
  /// system dialog). Returns true when scanning is allowed.
  static Future<bool> ensurePermission() async {
    if (!Platform.isAndroid) return false;

    // Android 13+ scoped media permission.
    PermissionStatus status = await Permission.videos.status;
    if (status.isGranted) return true;
    status = await Permission.videos.request();
    if (status.isGranted) return true;

    // Older Android falls back to storage.
    if (status.isDenied || status.isRestricted) {
      final PermissionStatus legacy = await Permission.storage.request();
      if (legacy.isGranted) return true;
    }
    return false;
  }

  static Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    final PermissionStatus videos = await Permission.videos.status;
    if (videos.isGranted) return true;
    final PermissionStatus storage = await Permission.storage.status;
    return storage.isGranted;
  }

  /// Scans MediaStore for video files and returns them as [MediaItem]s.
  static Future<ScanResult> scan() async {
    if (!Platform.isAndroid) {
      return const ScanResult(
        items: <MediaItem>[],
        permissionGranted: false,
        error: 'Scanning local media is only supported on Android.',
      );
    }

    final bool granted = await ensurePermission();
    if (!granted) {
      return const ScanResult(
        items: <MediaItem>[],
        permissionGranted: false,
        error: 'Permission to read videos was not granted.',
      );
    }

    try {
      final dynamic raw = await _channel.invokeMethod<dynamic>('queryVideos');
      final List<MediaItem> items = <MediaItem>[];
      if (raw is List) {
        for (final dynamic entry in raw) {
          if (entry is! Map) continue;
          final String path = (entry['path'] ?? '') as String;
          if (path.isEmpty || !MediaLibrary.isVideo(path)) continue;
          final int? durationMs = entry['duration'] as int?;
          items.add(
            MediaLibrary.itemFromPath(
              path,
              id: (entry['id'] ?? path).toString(),
              duration: (durationMs == null || durationMs <= 0)
                  ? null
                  : Duration(milliseconds: durationMs),
              sizeBytes: entry['size'] as int?,
            ),
          );
        }
      }
      items.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      return ScanResult(items: items, permissionGranted: true);
    } on PlatformException catch (e) {
      return ScanResult(
        items: const <MediaItem>[],
        permissionGranted: true,
        error: e.message ?? 'Scan failed.',
      );
    }
  }
}
