import 'package:flutter/foundation.dart';

import '../core/media_item.dart';
import '../core/resume_entry.dart';
import '../services/library_store.dart';
import '../services/media_scanner.dart';

/// App-wide state: the scanned local library, Continue Watching positions and
/// user preferences. Backed entirely by on-device storage.
class LibraryState extends ChangeNotifier {
  LibraryState(this._store);

  final LibraryStore _store;

  List<MediaItem> _library = <MediaItem>[];
  List<ResumeEntry> _resume = <ResumeEntry>[];
  bool _scanning = false;
  bool _loaded = false;
  String? _lastError;
  bool _gridView = true;
  String _query = '';

  List<MediaItem> get library => _library;
  List<ResumeEntry> get resume => _resume;
  bool get scanning => _scanning;
  bool get loaded => _loaded;
  String? get lastError => _lastError;
  bool get gridView => _gridView;
  String get query => _query;

  /// Items that should appear in the Continue Watching dashboard.
  List<ResumeEntry> get continueWatching =>
      ContinueWatching.dashboard(_resume);

  /// Current library filtered by the search box.
  List<MediaItem> get visibleLibrary =>
      _query.trim().isEmpty ? _library : _visibleSearch(_query);

  List<MediaItem> _visibleSearch(String q) {
    final String needle = q.trim().toLowerCase();
    return _library
        .where((MediaItem item) =>
            item.title.toLowerCase().contains(needle) ||
            item.folder.toLowerCase().contains(needle))
        .toList();
  }

  Map<String, List<MediaItem>> get grouped =>
      _groupByFolder(visibleLibrary);

  static Map<String, List<MediaItem>> _groupByFolder(List<MediaItem> items) {
    final Map<String, List<MediaItem>> groups = <String, List<MediaItem>>{};
    for (final MediaItem item in items) {
      groups.putIfAbsent(item.folder, () => <MediaItem>[]).add(item);
    }
    final List<String> keys = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return <String, List<MediaItem>>{
      for (final String k in keys) k: groups[k]!,
    };
  }

  Future<void> load() async {
    _library = _store.loadLibrary();
    _resume = _store.loadResume();
    _loaded = true;
    notifyListeners();
  }

  Future<void> rescan() async {
    _scanning = true;
    _lastError = null;
    notifyListeners();

    final ScanResult result = await MediaScanner.scan();
    _scanning = false;
    if (result.permissionGranted) {
      _library = result.items;
      await _store.saveLibrary(_library);
    }
    _lastError = result.error;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void toggleView() {
    _gridView = !_gridView;
    notifyListeners();
  }

  ResumeEntry? positionFor(String mediaId) =>
      ContinueWatching.find(_resume, mediaId);

  /// Records the current playback position for an item.
  Future<void> recordProgress({
    required MediaItem item,
    required Duration position,
    required Duration duration,
  }) async {
    final ResumeEntry entry = ContinueWatching.build(
      item: item,
      position: position,
      duration: duration,
      now: DateTime.now(),
    );
    _resume = ContinueWatching.upsert(_resume, entry);
    await _store.saveResume(_resume);
    notifyListeners();
  }

  Future<void> removeResume(String mediaId) async {
    _resume = ContinueWatching.remove(_resume, mediaId);
    await _store.saveResume(_resume);
    notifyListeners();
  }

  int get totalVideos => _library.length;
}
