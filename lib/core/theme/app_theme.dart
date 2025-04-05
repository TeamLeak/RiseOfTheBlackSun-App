import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF000000); // Pure black
  static const Color accentColor = Color(0xFFEF4444); // Red accent (red-500)
  static const Color accentColorHover = Color(0xFFDC2626); // Darker red (red-600)
  static const Color secondaryColor = Color(0xFF0A0A0A); // Near-black
  
  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF97316)], // red-500 to orange-500
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Status Colors
  static const Color successColor = Color(0xFF22C55E); // green-500
  static const Color errorColor = Color(0xFFEF4444); // red-500
  static const Color warningColor = Color(0xFFF59E0B); // amber-500
  static const Color infoColor = Color(0xFF3B82F6); // blue-500
  
  // Text Colors
  static const Color primaryTextColor = Color(0xFFFFFFFF); // Pure white
  static const Color secondaryTextColor = Color(0xB3FFFFFF); // White with 70% opacity
  static const Color disabledTextColor = Color(0x80FFFFFF); // White with 50% opacity
  
  // Background Colors
  static const Color backgroundColor = Color(0xFF000000); // Pure black
  static const Color surfaceColor = Color(0xFF0D0D0D); // Very dark
  static const Color cardColor = Color(0x0DFFFFFF); // White with 5% opacity
  
  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        onPrimary: Colors.black,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: errorColor,
        surfaceContainerHigh: Colors.grey[100]!,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
  
  // Dark Theme (Primary theme)
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        onPrimary: Colors.white,
        secondary: accentColorHover,
        onSecondary: Colors.white,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
        surfaceTint: Colors.white.withOpacity(0.05),
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          // Epic large text for hero sections
          displayLarge: TextStyle(
            fontSize: 72, 
            fontWeight: FontWeight.w900, 
            color: Colors.white,
            height: 1.1,
            letterSpacing: -1.0,
          ),
          // Large headers with gradient text
          displayMedium: TextStyle(
            fontSize: 48, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            height: 1.2,
          ),
          // Medium headers
          headlineLarge: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          // Section headers
          headlineMedium: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
          ),
          // Subtitle with red accent
          titleLarge: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.w600, 
            color: accentColor,
            letterSpacing: 0.4,
          ),
          // Card titles
          titleMedium: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.w600, 
            color: Colors.white,
          ),
          // Small titles
          titleSmall: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          // Body text
          bodyLarge: TextStyle(
            fontSize: 18, 
            color: secondaryTextColor,
            height: 1.6,
          ),
          // Default body
          bodyMedium: TextStyle(
            fontSize: 16, 
            color: secondaryTextColor,
            height: 1.6,
          ),
          // Small body text
          bodySmall: TextStyle(
            fontSize: 14, 
            color: secondaryTextColor,
            height: 1.5,
          ),
          // Button text
          labelLarge: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          // Small button text
          labelMedium: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600, 
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          // Smallest text
          labelSmall: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w500, 
            color: secondaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      // Updated AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      // Glass-effect cards with subtle border
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.05),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      // Vibrant red buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return accentColorHover;
              if (states.contains(MaterialState.disabled)) return Colors.grey.shade800;
              return accentColor; // Default
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 16, 
              letterSpacing: 0.5,
            ),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          elevation: MaterialStateProperty.all(6),
          shadowColor: MaterialStateProperty.all(accentColor.withOpacity(0.4)),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return Colors.white.withOpacity(0.1);
              return Colors.transparent;
            },
          ),
        ),
      ),
      // Outlined buttons with animated border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return BorderSide(color: Colors.white, width: 1.5);
              return BorderSide(color: Colors.white.withOpacity(0.3), width: 1);
            },
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
        ),
      ),
      // Red accent text buttons
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(accentColor),
          textStyle: MaterialStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          overlayColor: MaterialStateProperty.all(accentColor.withOpacity(0.05)),
        ),
      ),
      // Glass-like input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        floatingLabelStyle: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
        errorStyle: TextStyle(color: errorColor, fontWeight: FontWeight.w500),
        suffixIconColor: Colors.white.withOpacity(0.6),
        prefixIconColor: Colors.white.withOpacity(0.6),
      ),
      // Premium dialog styling with glass effect
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor.withOpacity(0.95),
        elevation: 24,
        shadowColor: accentColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        contentTextStyle: TextStyle(fontSize: 16, color: secondaryTextColor),
        alignment: Alignment.center,
      ),
      // Bottom sheet with premium styling
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.black.withOpacity(0.95),
        modalBackgroundColor: Colors.black.withOpacity(0.95),
        elevation: 12,
        modalElevation: 16,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      // Floating snackbar with red accent
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black.withOpacity(0.9),
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accentColor.withOpacity(0.5), width: 1),
        ),
        elevation: 8,
      ),
      // Modern divider
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
        space: 24,
      ),
      // Enhanced tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        textStyle: TextStyle(color: Colors.white, fontSize: 12),
        height: 32,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        waitDuration: Duration(milliseconds: 500),
      ),
    );
  }
}
