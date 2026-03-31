import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced Color Palette - 60-30-10 Rule
  // 60% - Background (Grey)
  static const Color backgroundDark = Color(0xFF18181B); // Zinc 900
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50

  // 30% - Cards/Surface (White/Dark)
  static const Color surfaceDark = Color(0xFF27272A); // Zinc 800
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  
  // 10% - Primary/Accent (Indigo)
  static const Color primaryBlue = Colors.indigo; // Changed to indigo
  static const Color primaryBlueDark = Color(0xFF3F51B5); // Indigo 700
  static const Color primaryBlueLight = Color(0xFF7986CB); // Indigo 300
  
  // Semantic Colors (Indigo variants instead of green)
  static const Color successBlue = Colors.indigo; // Changed to indigo
  static const Color errorRed = Color(0xFFEF4444); // Red 500
  static const Color warningOrange = Color(0xFFF97316); // Orange 500

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Pure white instead of zinc 50
  static const Color textSecondaryDark = Color(0xFFFFFFFF); // Pure white instead of zinc 400
  static const Color textMutedDark = Color(0xFFFFFFFF); // Pure white instead of zinc 500

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF000000); // Pure black instead of slate 900
  static const Color textSecondaryLight = Color(0xFF000000); // Pure black instead of slate 600
  static const Color textMutedLight = Color(0xFF000000); // Pure black instead of slate 400

  // Dynamic colors based on theme
  static Color getTextPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color getTextSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color getTextMuted(bool isDark) => isDark ? textMutedDark : textMutedLight;
  static Color getBackground(bool isDark) => isDark ? backgroundDark : backgroundLight;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : surfaceLight;

  // Compatibility Aliases (all blue now)
  static const Color gradientStart = backgroundDark;
  static const Color gradientMiddle = backgroundDark;
  static const Color gradientEnd = backgroundDark;
  
  static const Color primaryStart = primaryBlue;
  static const Color primaryEnd = primaryBlueDark;
  
  static const Color secondaryStart = primaryBlueLight;
  static const Color secondaryEnd = primaryBlue;
  
  // All accent colors are now indigo variants
  static const Color accentGreen = primaryBlue; // Changed from green to indigo
  static const Color accentOrange = warningOrange;
  static const Color accentRed = errorRed;
  static const Color accentPurple = primaryBlue;
  static const Color accentPink = primaryBlue;
  static const Color accentTeal = primaryBlue;

  // Legacy compatibility - static colors for backward compatibility
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white for dark theme
  static const Color textSecondary = Color(0xFFFFFFFF); // Pure white for dark theme
  static const Color textMuted = Color(0xFFFFFFFF); // Pure white for dark theme
  static const Color textHint = Color(0xFFFFFFFF); // Pure white for dark theme
  static const Color profitGreen = successBlue; // Changed to indigo

  // Card Colors
  static const Color cardBackground = surfaceDark;
  static const Color cardBackgroundStrong = Color(0xFF3F3F46); // Zinc 700
  static const Color cardBorder = Color(0x1FFFFFFF);
  static const Color cardBorderStrong = Color(0x33FFFFFF);

  // Light theme card colors
  static const Color cardBackgroundLight = surfaceLight;
  static const Color cardBorderLight = Color(0x1F000000);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundDark], // Solid grey background
  );

  // Primary Button Gradient (Indigo)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );

  // Success Gradient (Indigo instead of green)
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successBlue, primaryBlueDark],
  );

  // Warning Gradient
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningOrange, Color(0xFFEA580C)],
  );

  // Error Gradient
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorRed, Color(0xFFDC2626)],
  );

  // Text Styles - Legacy getters for backward compatibility
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textPrimaryDark,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryDark,
        height: 1.2,
      );

  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        height: 1.3,
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryDark,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMutedDark,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondaryDark,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMutedDark,
      );

  static TextStyle get resultLabel => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondaryDark,
      );

  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get resultValue => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryDark,
        letterSpacing: -0.5,
      );

  // Dynamic Text Styles - Functions that accept theme parameter
  static TextStyle getDisplayLarge({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: getTextPrimary(isDark),
        height: 1.2,
      );

  static TextStyle getDisplayMedium({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: getTextPrimary(isDark),
        height: 1.2,
      );

  static TextStyle getHeadingLarge({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: getTextPrimary(isDark),
        height: 1.3,
      );

  static TextStyle getHeadingMedium({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: getTextPrimary(isDark),
        height: 1.3,
      );

  static TextStyle getHeadingSmall({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: getTextPrimary(isDark),
        height: 1.4,
      );

  static TextStyle getBodyLarge({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: getTextPrimary(isDark),
        height: 1.5,
      );

  static TextStyle getBodyMedium({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: getTextSecondary(isDark),
        height: 1.5,
      );

  static TextStyle getBodySmall({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: getTextMuted(isDark),
        height: 1.5,
      );

  static TextStyle getLabelLarge({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: getTextPrimary(isDark),
      );

  static TextStyle getLabelMedium({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: getTextSecondary(isDark),
      );

  static TextStyle getLabelSmall({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: getTextMuted(isDark),
      );

  static TextStyle getResultLabel({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: getTextSecondary(isDark),
      );

  static TextStyle getResultValue({bool isDark = true}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: getTextPrimary(isDark),
        letterSpacing: -0.5,
      );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    String? suffix,
    bool isError = false,
    bool isDark = true,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        color: isError ? errorRed : (isDark ? Colors.white : Colors.black),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.poppins(
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: isError ? errorRed : (isDark ? Colors.white : Colors.black),
              size: 20,
            )
          : null,
      suffixText: suffix,
      suffixStyle: GoogleFonts.poppins(
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: isError 
          ? errorRed.withValues(alpha: 0.1) 
          : (isDark ? surfaceDark : surfaceLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isError 
              ? errorRed 
              : (isDark ? cardBorder : cardBorderLight),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isError 
              ? errorRed 
              : (isDark ? cardBorder : cardBorderLight),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isError ? errorRed : Colors.indigo,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: textPrimaryDark,
        side: BorderSide(color: cardBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
      );

  static ButtonStyle getSecondaryButtonStyle({bool isDark = true}) => OutlinedButton.styleFrom(
        foregroundColor: getTextPrimary(isDark),
        side: BorderSide(
          color: isDark ? cardBorder : cardBorderLight, 
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: getLabelLarge(isDark: isDark).copyWith(fontWeight: FontWeight.w600),
      );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration getCardDecoration({bool isDark = true}) => BoxDecoration(
        color: isDark ? cardBackground : cardBackgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? cardBorder : cardBorderLight, 
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Theme Data
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.dark(
          primary: Colors.indigo,
          secondary: primaryBlueDark,
          surface: surfaceDark,
          error: errorRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimaryDark,
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: textPrimaryDark,
          displayColor: textPrimaryDark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: secondaryButtonStyle,
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: cardBorder),
          ),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundLight,
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.light(
          primary: Colors.indigo,
          secondary: primaryBlueDark,
          surface: surfaceLight,
          error: errorRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimaryLight,
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor: textPrimaryLight,
          displayColor: textPrimaryLight,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cardBorderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cardBorderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: getSecondaryButtonStyle(isDark: false),
        ),
        cardTheme: CardThemeData(
          color: surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: cardBorderLight),
          ),
        ),
      );

  // Legacy theme data getter
  static ThemeData get themeData => darkTheme;

  // Animation Curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;

  // Durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
}
