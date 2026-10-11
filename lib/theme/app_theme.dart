import 'package:flutter/material.dart';

/// AniLoom's dark "screening room" theme.
class AppTheme {
  const AppTheme._();

  static const Color bg = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141A2B);
  static const Color surfaceAlt = Color(0xFF1B2338);
  static const Color divider = Color(0xFF243048);
  static const Color text = Color(0xFFEAF0FB);
  static const Color muted = Color(0xFF93A1BD);
  static const Color accent = Color(0xFF7C5CFF); // violet
  static const Color accent2 = Color(0xFF22D3EE); // cyan
  static const Color warm = Color(0xFFFFB454);

  static ThemeData dark() {
    final ColorScheme scheme = const ColorScheme.dark(
      primary: accent,
      secondary: accent2,
      surface: surface,
      onSurface: text,
    );

    final TextTheme textTheme = Typography.whiteMountainView.apply(
      bodyColor: text,
      displayColor: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: divider,
      iconTheme: const IconThemeData(color: text),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0C1120),
        indicatorColor: accent.withValues(alpha: 0.22),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? text : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? accent2 : muted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent2),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[accent, accent2],
  );
}
