import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../theme/app_theme.dart';

/// Rounded gradient app mark with the AniLoom "loom play" glyph.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: CustomPaint(painter: _LoomPainter()),
    );
  }
}

class _LoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()
      ..color = AppTheme.bg
      ..style = PaintingStyle.fill;
    final Paint thread = Paint()
      ..color = AppTheme.bg.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // Three vertical "loom threads".
    for (final double fx in <double>[0.30, 0.5, 0.70]) {
      canvas.drawLine(
        Offset(w * fx, h * 0.24),
        Offset(w * fx, h * 0.76),
        thread,
      );
    }

    // Play triangle, centred.
    final Path play = Path()
      ..moveTo(w * 0.42, h * 0.36)
      ..lineTo(w * 0.42, h * 0.64)
      ..lineTo(w * 0.68, h * 0.5)
      ..close();
    canvas.drawPath(play, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wordmark row used in headers.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.showSubtitle = true});

  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const BrandMark(size: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              AppInfo.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            if (showSubtitle)
              const Text(
                AppInfo.tagline,
                style: TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
          ],
        ),
      ],
    );
  }
}

/// Small pill badge used across the UI.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.color = AppTheme.accent2,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Offline reassurance chip shown in the header.
class OfflineChip extends StatelessWidget {
  const OfflineChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.verified_user_outlined, size: 15, color: AppTheme.accent2),
          SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty-state block.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider),
              ),
              child: Icon(icon, size: 38, color: AppTheme.muted),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, height: 1.5),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 22),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
