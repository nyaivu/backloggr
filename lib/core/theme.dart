import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.uiBlack,
        surface: AppColors.scaffoldBackground,
      ),

      // --- TYPOGRAPHY ---
      textTheme: const TextTheme(
        // For large titles like "My trips" and "Short trip to Paris"
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        // For card titles like "Old friends in Paris"
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        // For standard body text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        // For subtitles like "May 2024 • 14 photos"
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),

      // --- BUTTON STYLES ---
      // Styles the "Add new" pill button and floating action buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.uiBlack,
          foregroundColor: AppColors.uiWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.paddingMedium,
            vertical: AppLayout.paddingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppLayout.pillBorderRadius,
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Styles the circular icon buttons (back, edit, share)
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.uiWhite.withAlpha(
            1,
          ), // For the frosted look
          foregroundColor: AppColors.uiBlack,
          padding: const EdgeInsets.all(12),
          shape: const CircleBorder(),
        ),
      ),

      // --- CARD STYLES ---
      // Standardizes the large pastel containers
      cardTheme: const CardThemeData(
        // <--- Change CardTheme to CardThemeData here
        elevation: 0,
        shape: RoundedRectangleBorder(
          // Note: You will need to remove 'const' from CardThemeData if
          // AppLayout.cardBorderRadius is not a const variable.
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
