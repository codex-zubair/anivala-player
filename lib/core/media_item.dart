import 'package:flutter/material.dart';

/// A local video file discovered on the device.
///
/// Pure Dart model (only uses [Duration] and a Flutter-independent API) so the
/// scanning, filtering and resume logic can be unit tested without a device.
@immutable
class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.path,
    required this.folder,
    this.duration,
    this.sizeBytes,
    this.thumbnailPath,
  });

  /// Stable identity for persisted state. On Android this is the MediaStore id
  /// (as a string); for other sources it is derived from the file path.
  final String id;

  /// Display title, usually the file name without extension.
  final String title;

  /// Absolute file path (or content URI string) used by the player.
  final String path;

  /// Parent folder name, used to group the library.
  final String folder;

  final Duration? duration;
  final int? sizeBytes;
  final String? thumbnailPath;

  MediaItem copyWith({
    String? id,
    String? title,
    String? path,
    String? folder,
    Duration? duration,
    int? sizeBytes,
    String? thumbnailPath,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      folder: folder ?? this.folder,
      duration: duration ?? this.duration,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'path': path,
        'folder': folder,
        'durationMs': duration?.inMilliseconds,
        'sizeBytes': sizeBytes,
        'thumbnailPath': thumbnailPath,
      };

  static MediaItem fromJson(Map<String, dynamic> json) {
    final int? ms = json['durationMs'] as int?;
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      folder: (json['folder'] as String?) ?? '',
      duration: ms == null ? null : Duration(milliseconds: ms),
      sizeBytes: json['sizeBytes'] as int?,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MediaItem && other.id == id && other.path == path;

  @override
  int get hashCode => Object.hash(id, path);
}
