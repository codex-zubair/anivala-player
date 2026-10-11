import 'package:flutter_test/flutter_test.dart';
import 'package:watchanimetv/core/formatters.dart';

void main() {
  group('Formatters.duration', () {
    test('formats minutes and seconds', () {
      expect(Formatters.duration(const Duration(seconds: 75)), '1:15');
      expect(Formatters.duration(const Duration(seconds: 5)), '0:05');
    });

    test('formats hours when present', () {
      expect(Formatters.duration(const Duration(seconds: 3725)), '1:02:05');
      expect(Formatters.duration(const Duration(hours: 2)), '2:00:00');
    });

    test('clamps negative durations to zero', () {
      expect(Formatters.duration(const Duration(seconds: -10)), '0:00');
    });
  });

  group('Formatters.bytes', () {
    test('formats sizes', () {
      expect(Formatters.bytes(0), '0 B');
      expect(Formatters.bytes(512), '512 B');
      expect(Formatters.bytes(1024), '1.0 KB');
      expect(Formatters.bytes(1536), '1.5 KB');
      expect(Formatters.bytes(5 * 1024 * 1024), '5.0 MB');
    });

    test('handles negative values', () {
      expect(Formatters.bytes(-1), '0 B');
    });
  });

  group('Formatters.relativeTime', () {
    final DateTime now = DateTime(2026, 1, 10, 12, 0, 0);

    test('recent and older buckets', () {
      expect(Formatters.relativeTime(now, now), 'just now');
      expect(
        Formatters.relativeTime(now.subtract(const Duration(minutes: 5)), now),
        '5 min ago',
      );
      expect(
        Formatters.relativeTime(now.subtract(const Duration(hours: 3)), now),
        '3 h ago',
      );
      expect(
        Formatters.relativeTime(now.subtract(const Duration(days: 2)), now),
        '2 d ago',
      );
      expect(
        Formatters.relativeTime(now.subtract(const Duration(days: 60)), now),
        'on 2025-11-11',
      );
    });
  });
}
