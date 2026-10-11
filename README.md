# AniLoom

**100% offline local anime & video player for Android and Android TV.**

AniLoom scans and plays video files that are already stored on your device and
remembers exactly where you left off with an automated **Continue Watching**
dashboard. It has no backend, requests **no INTERNET permission**, contains no
ads and no analytics, and never connects to the network.

- Package: `com.anivala.watchanimetv`
- Privacy policy: https://codex-zubair.github.io/all_privacy_policy/aniloom/
- Category: Video Players & Editors
- Platform: Android (min SDK 24) + Android TV

## Features

- **Local library scan** using Android's scoped media access
  (`READ_MEDIA_VIDEO` on Android 13+; `READ_EXTERNAL_STORAGE` on older
  versions). No "All files access" permission.
- **Continue Watching** dashboard that resumes each video from the exact
  second you stopped. Positions are stored locally and never uploaded.
- **Folder grouping**, instant search, grid and list layouts.
- **Gesture player** with double-tap seek, 10-second skip, auto-hiding
  controls, landscape/portrait support.
- **Android TV ready** — leanback launcher, 320x180 banner, D-pad friendly,
  touchscreen not required.
- Supports MP4, MKV, WEBM, AVI, MOV, M4V, TS, FLV, WMV, MPEG and more.

## Privacy

AniLoom is offline by design:

- No `INTERNET` permission (it is explicitly removed at build time).
- No ads, no analytics, no third-party tracking SDKs.
- The library index, Continue Watching history and preferences live only in
  the app's private storage on your device, and can be cleared in-app.

## Architecture

```
lib/
  core/       Pure Dart: models, media library logic, resume logic, formatting
  services/   LibraryStore (SharedPreferences), MediaScanner (MediaStore)
  state/      LibraryState (ChangeNotifier + provider)
  screens/    root_shell, continue_watching, library, player, settings, about
  widgets/    brand, media_card
  theme/      app_theme
```

The `lib/core` layer has no Flutter imports where practical so it can be unit
tested without a device.

## Development

```bash
flutter pub get
flutter analyze          # 0 issues
flutter test             # 29 tests
flutter run

# Release
flutter build appbundle --release   # AAB for Play
flutter build apk --release         # APK for sideload / Android TV
```

Generate branding and store graphics:

```bash
python3 tool/gen_icons.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
python3 tool/make_graphics.py        # feature graphic, screenshots, TV banner
```

## Signing

Release builds are signed with `android/aniloom-release.jks` via
`android/key.properties`. Both files are git-ignored. A backup lives in
`/mnt/external_disk/ALL-APP-KEYS/AniLoom/`.

## License

MIT — see [LICENSE](LICENSE).
