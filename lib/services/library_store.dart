import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/media_item.dart';
import '../core/resume_entry.dart';

/// Persists the local library and Continue Watching positions using the
/// platform's private preferences store. Nothing is ever uploaded — this is a
/// local-only service and the app requests no INTERNET permission.
class LibraryStore {
  LibraryStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kLibrary = 'aniloom.library.v1';
  static const String _kResume = 'aniloom.resume.v1';
  static const String _kFolders = 'aniloom.folders.v1';

  static Future<LibraryStore> open() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LibraryStore(prefs);
  }

  // ---- Library -----------------------------------------------------------

  List<MediaItem> loadLibrary() {
    final String? raw = _prefs.getString(_kLibrary);
    if (raw == null || raw.isEmpty) return <MediaItem>[];
    try {
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((dynamic e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <MediaItem>[];
    }
  }

  Future<void> saveLibrary(List<MediaItem> items) async {
    final String raw =
        jsonEncode(items.map((MediaItem e) => e.toJson()).toList());
    await _prefs.setString(_kLibrary, raw);
  }

  // ---- Continue Watching ------------------------------------------------

  List<ResumeEntry> loadResume() {
    final String? raw = _prefs.getString(_kResume);
    if (raw == null || raw.isEmpty) return <ResumeEntry>[];
    try {
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((dynamic e) => ResumeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <ResumeEntry>[];
    }
  }

  Future<void> saveResume(List<ResumeEntry> entries) async {
    final String raw =
        jsonEncode(entries.map((ResumeEntry e) => e.toJson()).toList());
    await _prefs.setString(_kResume, raw);
  }

  // ---- Scanned folders (SAF tree URIs) ----------------------------------

  List<String> loadFolders() =>
      _prefs.getStringList(_kFolders) ?? <String>[];

  Future<void> saveFolders(List<String> folderIds) async {
    await _prefs.setStringList(_kFolders, folderIds);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_kLibrary);
    await _prefs.remove(_kResume);
    await _prefs.remove(_kFolders);
  }
}
