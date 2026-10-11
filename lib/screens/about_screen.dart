import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_info.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

/// About / privacy screen. The offline promise is stated plainly here and the
/// hosted privacy policy is one tap away.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              const BrandMark(size: 76),
              const SizedBox(height: 16),
              const Text(
                AppInfo.name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const Text(
                AppInfo.tagline,
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 10),
              Pill(label: 'v${AppInfo.version} · by ${AppInfo.company}'),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppTheme.accent.withValues(alpha: 0.16),
                AppTheme.accent2.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Icon(Icons.shield_outlined, color: AppTheme.accent2, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Private by design',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                AppInfo.privacyPromise,
                style: TextStyle(color: AppTheme.text, height: 1.55),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => _open(AppInfo.privacyPolicyUrl),
                icon: const Icon(Icons.policy_outlined, size: 18),
                label: const Text('Read Privacy Policy'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _Card(
          children: <Widget>[
            _Link(
              icon: Icons.source_outlined,
              title: 'View source on GitHub',
              subtitle: AppInfo.githubUrl,
              onTap: () => _open(AppInfo.githubUrl),
            ),
            _Link(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy policy',
              subtitle: AppInfo.privacyPolicyUrl,
              onTap: () => _open(AppInfo.privacyPolicyUrl),
            ),
            _Link(
              icon: Icons.mail_outline_rounded,
              title: 'Contact',
              subtitle: AppInfo.contactEmail,
              onTap: () => _open('mailto:${AppInfo.contactEmail}'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'AniLoom collects no data, shows no ads and never connects to the '
            'internet. It plays only the media files stored on your device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: AppTheme.accent2),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded,
                size: 16, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}
