import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData lightTheme([ColorScheme? dynamicColorScheme]) {
    final colorScheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: Color(0xFF6750A4),
          brightness: Brightness.light,
        );

    return _buildThemeData(colorScheme, dynamicColorScheme);
  }

  static ThemeData darkTheme([ColorScheme? dynamicColorScheme]) {
    final colorScheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: Color(0xFF6750A4),
          brightness: Brightness.dark,
        );

    return _buildThemeData(colorScheme, dynamicColorScheme);
  }

  static void _applySystemUiStyle(ColorScheme colorScheme) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: colorScheme.brightness,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness:
            colorScheme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  static ThemeData _buildThemeData(
    ColorScheme appColorScheme,
    ColorScheme? dynamicColorScheme,
  ) {
    final colorScheme = dynamicColorScheme ?? appColorScheme;

    // Apply system UI styling
    _applySystemUiStyle(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: colorScheme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        color: colorScheme.surface,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        elevation: 0,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        elevation: 0,
      ),
    );
  }
}
