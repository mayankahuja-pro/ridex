import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color black = Color(0xFF050505);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surfaceLight = Color(0xFF151515);

  static const Color neonGreen = Color(0xFFB6FF00);
  static const Color neonYellow = Color(0xFFFFE600);

  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: black,

    colorScheme: const ColorScheme.dark(
      primary: neonGreen,
      secondary: neonYellow,
      tertiary: white,

      surface: surface,
      surfaceContainerHighest: surfaceLight,

      onPrimary: Colors.black,
      onSecondary: Colors.black,

      // IMPORTANT:
      // Text/icons on dark surfaces are white.
      onSurface: white,
    ),

    // ============================================================
    // APP BAR
    // ============================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      elevation: 0,
      centerTitle: true,

      titleTextStyle: TextStyle(
        color: white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),

      iconTheme: IconThemeData(
        color: white,
      ),
    ),

    // ============================================================
    // CARD
    // ============================================================

    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFF292929),
          width: 1,
        ),
      ),
    ),

    // ============================================================
    // INPUT
    // ============================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,

      hintStyle: const TextStyle(
        color: white50,
      ),

      labelStyle: const TextStyle(
        color: neonGreen,
        fontWeight: FontWeight.w600,
      ),

      floatingLabelStyle: const TextStyle(
        color: neonGreen,
        fontWeight: FontWeight.w700,
      ),

      prefixIconColor: neonGreen,
      suffixIconColor: white70,

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF303030),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: neonGreen,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: neonYellow,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: neonYellow,
          width: 1.5,
        ),
      ),
    ),

    // ============================================================
    // ELEVATED BUTTON
    // ============================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonGreen,
        foregroundColor: Colors.black,

        disabledBackgroundColor: const Color(0xFF303030),
        disabledForegroundColor: white50,

        elevation: 0,

        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        textStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    ),

    // ============================================================
    // OUTLINED BUTTON
    // ============================================================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: neonGreen,

        side: const BorderSide(
          color: neonGreen,
          width: 1.2,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 13,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        textStyle: const TextStyle(
          color: neonGreen,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    ),

    // ============================================================
    // TEXT BUTTON
    // ============================================================

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: neonYellow,

        textStyle: const TextStyle(
          color: neonYellow,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    ),

    // ============================================================
    // FAB
    // ============================================================

    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(
      backgroundColor: neonGreen,
      foregroundColor: Colors.black,

      iconSize: 24,
      elevation: 6,
    ),

    // ============================================================
    // NAVIGATION BAR
    // ============================================================

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: black,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      indicatorColor: neonGreen,

      labelBehavior:
          NavigationDestinationLabelBehavior.alwaysShow,

      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            );
          }

          return const TextStyle(
            color: white70,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        },
      ),

      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Colors.black,
            );
          }

          return const IconThemeData(
            color: white70,
          );
        },
      ),
    ),

    // ============================================================
    // TEXT THEME
    // ============================================================

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: white,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),

      headlineMedium: TextStyle(
        color: white,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),

      headlineSmall: TextStyle(
        color: neonGreen,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),

      titleLarge: TextStyle(
        color: white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),

      titleMedium: TextStyle(
        color: neonGreen,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),

      titleSmall: TextStyle(
        color: white70,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: white,
      ),

      bodyMedium: TextStyle(
        color: white70,
      ),

      bodySmall: TextStyle(
        color: white50,
      ),

      labelLarge: TextStyle(
        color: white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),

      labelMedium: TextStyle(
        color: white70,
        fontWeight: FontWeight.w600,
      ),

      labelSmall: TextStyle(
        color: white50,
      ),
    ),

    // ============================================================
    // DIVIDER
    // ============================================================

    dividerTheme: const DividerThemeData(
      color: Color(0xFF292929),
      thickness: 1,
      space: 1,
    ),

    // ============================================================
    // SWITCH
    // ============================================================

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return neonGreen;
          }

          return const Color(0xFF777777);
        },
      ),

      trackColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF334700);
          }

          return const Color(0xFF202020);
        },
      ),

      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return neonGreen;
          }

          return const Color(0xFF404040);
        },
      ),
    ),

    // ============================================================
    // CHECKBOX
    // ============================================================

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return neonGreen;
          }

          return Colors.transparent;
        },
      ),

      checkColor: const WidgetStatePropertyAll(
        Colors.black,
      ),

      side: const BorderSide(
        color: neonGreen,
        width: 1.5,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // ============================================================
    // RADIO
    // ============================================================

    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll(
        neonGreen,
      ),
    ),

    // ============================================================
    // PROGRESS
    // ============================================================

    progressIndicatorTheme:
        const ProgressIndicatorThemeData(
      color: neonGreen,
      linearTrackColor: Color(0xFF252525),
      circularTrackColor: Color(0xFF252525),
    ),

    // ============================================================
    // ICONS
    // ============================================================

    iconTheme: const IconThemeData(
      color: white,
      size: 24,
    ),

    // ============================================================
    // DIALOG
    // ============================================================

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,

      titleTextStyle: const TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),

      contentTextStyle: const TextStyle(
        color: white70,
        fontSize: 15,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFF292929),
        ),
      ),
    ),

    // ============================================================
    // BOTTOM SHEET
    // ============================================================

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,

      modalBackgroundColor: surface,
      modalBarrierColor: Color(0x99000000),

      showDragHandle: true,
      dragHandleColor: white50,
    ),

    // ============================================================
    // SNACKBAR
    // ============================================================

    snackBarTheme: SnackBarThemeData(
      backgroundColor: white,
      contentTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),

      actionTextColor: Colors.black,

      behavior: SnackBarBehavior.floating,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    // ============================================================
    // TOOLTIP
    // ============================================================

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(6),
      ),

      textStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
