import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_info.dart';
import '../state/library_state.dart';
import '../theme/app_theme.dart';

/// Settings and storage management. Everything is on-device and offline.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryState state = context.watch<LibraryState>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        _SectionTitle('Library'),
        _Card(
          children: <Widget>[
            _Row(
              icon: Icons.video_library_outlined,
              title: 'Videos found',
              value: '${state.totalVideos}',
            ),
            _Row(
              icon: Icons.play_circle_outline_rounded,
              title: 'In progress',
              value: '${state.continueWatching.length}',
            ),
            _Row(
              icon: state.gridView
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
              title: 'Default layout',
              value: state.gridView ? 'Grid' : 'List',
              onTap: state.toggleView,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle('Data'),
        _Card(
          children: <Widget>[
            _Row(
              icon: Icons.refresh_rounded,
              title: 'Rescan device',
              subtitle: 'Look for new local video files',
              onTap: state.scanning ? null : state.rescan,
              trailing: state.scanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            _Row(
              icon: Icons.delete_sweep_outlined,
              title: 'Clear Continue Watching',
              subtitle: 'Removes saved playback positions',
              onTap: () => _confirmClear(context, state),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionTitle('Privacy'),
        const _Card(
          children: <Widget>[
            _InfoRow(
              icon: Icons.wifi_off_rounded,
              text: 'No internet permission. AniLoom cannot access the network.',
            ),
            _InfoRow(
              icon: Icons.block_rounded,
              text: 'No ads, no analytics, no trackers.',
            ),
            _InfoRow(
              icon: Icons.phone_android_rounded,
              text: 'Your library and history never leave this device.',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '${AppInfo.name} v${AppInfo.version}',
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, LibraryState state) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear Continue Watching?'),
        content: const Text(
          'This removes all saved playback positions from this device. '
          'Your video files are not touched.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      final List<String> ids =
          state.resume.map((e) => e.mediaId).toList(growable: false);
      for (final String id in ids) {
        await state.removeResume(id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Continue Watching cleared.')),
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
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

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.value,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!,
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 12)),
                    ),
                ],
              ),
            ),
            if (value != null)
              Text(value!,
                  style: const TextStyle(
                      color: AppTheme.muted, fontWeight: FontWeight.w700)),
            ?trailing,
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.chevron_right_rounded,
                    color: AppTheme.muted, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppTheme.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
