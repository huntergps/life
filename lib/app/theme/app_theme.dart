import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Light green border used across multiple light theme components
  static const _lightBorder = Color(0xFFB8D5BA);
  // Subtle green fill for inputs & chips
  static const _lightFill = Color(0xFFE8F0E8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.lavaBlack,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.lavaBlack,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _lightBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.4)),
        labelStyle: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.7)),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.lavaBlack.withValues(alpha: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(color: AppColors.lavaBlack.withValues(alpha: 0.55));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.55), fontSize: 12);
        }),
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.lavaBlack.withValues(alpha: 0.55)),
        selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.55), fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightFill,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        side: const BorderSide(color: _lightBorder, width: 0.5),
        labelStyle: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.8)),
        secondaryLabelStyle: const TextStyle(color: AppColors.primary),
        checkmarkColor: AppColors.primary,
      ),
      dividerTheme: const DividerThemeData(color: _lightBorder, thickness: 0.5),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.lavaBlack.withValues(alpha: 0.6),
        textColor: AppColors.lavaBlack,
      ),
      iconTheme: IconThemeData(color: AppColors.lavaBlack.withValues(alpha: 0.7)),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lavaBlack),
        headlineMedium: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lavaBlack),
        headlineSmall: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lavaBlack),
        titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.lavaBlack),
        titleMedium: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.lavaBlack),
        titleSmall: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.lavaBlack),
        bodyLarge: const TextStyle(color: AppColors.lavaBlack),
        bodyMedium: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.8)),
        bodySmall: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.6)),
        labelLarge: const TextStyle(color: AppColors.lavaBlack),
        labelMedium: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.7)),
        labelSmall: TextStyle(color: AppColors.lavaBlack.withValues(alpha: 0.55)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.accentOrange,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38)),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white38,
        suffixIconColor: Colors.white38,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryLight);
          }
          return const IconThemeData(color: Colors.white54);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: Colors.white54, fontSize: 12);
        }),
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
        selectedIconTheme: const IconThemeData(color: AppColors.primaryLight),
        unselectedIconTheme: const IconThemeData(color: Colors.white54),
        selectedLabelTextStyle: const TextStyle(color: AppColors.primaryLight, fontSize: 12),
        unselectedLabelTextStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        labelStyle: const TextStyle(color: Colors.white70),
        secondaryLabelStyle: const TextStyle(color: AppColors.primaryLight),
        checkmarkColor: AppColors.primaryLight,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 0.5),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white54,
        textColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white54),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white70),
        labelSmall: TextStyle(color: Colors.white54),
      ),
    );
  }
}
