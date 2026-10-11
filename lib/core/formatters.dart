/// Pure-Dart formatting helpers used across the UI and tests.
class Formatters {
  const Formatters._();

  /// `3725s` -> `1:02:05`, `75s` -> `1:15`.
  static String duration(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final int totalSeconds = d.inSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    final String mm = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$mm:$ss';
  }

  /// Human readable byte size: `1536` -> `1.5 KB`.
  static String bytes(int value) {
    if (value < 0) return '0 B';
    const List<String> units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    double size = value.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final String formatted =
        size >= 100 || unit == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
    return '$formatted ${units[unit]}';
  }

  /// `just now`, `5 min ago`, `3 h ago`, `2 d ago`, `on 2026-01-02`.
  static String relativeTime(DateTime time, DateTime now) {
    final Duration diff = now.difference(time);
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 30) return '${diff.inDays} d ago';
    final String y = time.year.toString().padLeft(4, '0');
    final String m = time.month.toString().padLeft(2, '0');
    final String d = time.day.toString().padLeft(2, '0');
    return 'on $y-$m-$d';
  }
}
