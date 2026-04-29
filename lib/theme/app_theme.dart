import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF6D5EF7);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF8F7FF),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: base.colorScheme.onSurface,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: base.colorScheme.surfaceContainerHigh,
        contentTextStyle: TextStyle(color: base.colorScheme.onSurface),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1016),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: base.colorScheme.onSurface,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: base.colorScheme.surfaceContainerHigh,
        contentTextStyle: TextStyle(color: base.colorScheme.onSurface),
      ),
    );
  }
}
