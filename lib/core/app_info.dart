/// App-wide constants: brand identity, links and legal pointers.
///
/// This is pure Dart (no Flutter imports) so it can be unit tested and reused.
class AppInfo {
  const AppInfo._();

  static const String name = 'AniLoom';
  static const String tagline = 'Offline Anime & Video Player';
  static const String company = 'codex-zubair';
  static const String version = '1.0.0';
  static const String packageName = 'com.codexzubair.aniloom';

  /// Hosted privacy policy (central GitHub Pages site for all factory apps).
  static const String privacyPolicyUrl =
      'https://codex-zubair.github.io/all_privacy_policy/aniloom/';

  /// Public source repository.
  static const String githubUrl =
      'https://github.com/codex-zubair/anivala-player';

  static const String companyUrl = 'https://github.com/codex-zubair';
  static const String contactEmail = 'iam.nmzar@gmail.com';

  /// One-line privacy promise shown in the UI.
  static const String privacyPromise =
      'No internet, no ads, no tracking. Your library and playback history '
      'stay on your device.';
}
