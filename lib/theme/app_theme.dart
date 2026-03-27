import 'package:flutter/material.dart';

class AppTheme {
  // ── Child Brand Colors ────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);       // Purple
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color secondary = Color(0xFF00C9A7);     // Teal / Green
  static const Color accent = Color(0xFFFFD166);        // Amber / Yellow
  static const Color danger = Color(0xFFFF6B6B);        // Red
  static const Color pink = Color(0xFFFF85A1);          // Pink
  static const Color skyBlue = Color(0xFF4FC3F7);       // Sky Blue

  static const Color background = Color(0xFFF5F0FF);    // Soft lavender bg
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E1B4B);
  static const Color textMuted = Color(0xFF9E9DB5);

  // ── Parent Brand Colors (Fintech Blue) ────────────────────────
  static const Color parentPrimary   = Color(0xFF1A73E8); // Google Blue
  static const Color parentDark      = Color(0xFF0D47A1); // Deep Navy
  static const Color parentAccent    = Color(0xFF00BCD4); // Cyan accent
  static const Color parentSuccess   = Color(0xFF00C853); // Green confirm
  static const Color parentWarning   = Color(0xFFFFA726); // Amber alert
  static const Color parentDanger    = Color(0xFFEF5350); // Red alert
  static const Color parentSurface   = Color(0xFFF0F4FF); // Light blue-grey bg
  static const Color parentCardBg    = Color(0xFFFFFFFF);
  static const Color parentTextDark  = Color(0xFF0D1B3E); // Deep ink
  static const Color parentTextMuted = Color(0xFF7A8AA0); // Steel grey

  // ── Child Gradients ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF48CFE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF7F78FF), Color(0xFF5A52D5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFF9A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF85A1), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Child Goal Card Gradients ─────────────────────────────────
  static List<LinearGradient> goalGradients = [
    greenGradient,
    amberGradient,
    pinkGradient,
    blueGradient,
    const LinearGradient(
      colors: [Color(0xFFB39DDB), Color(0xFF7C4DFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  // ── Parent Gradients (Fintech Blue) ───────────────────────────

  /// Main header gradient for parent screens
  static const LinearGradient parentGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Alternate card gradient (blue → cyan)
  static const LinearGradient parentCardGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green confirmation gradient (add money / approve)
  static const LinearGradient parentGreenGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Amber/orange gradient (warnings / limits)
  static const LinearGradient parentAmberGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Indigo-violet gradient (secondary stat cards)
  static const LinearGradient parentIndigoGradient = LinearGradient(
    colors: [Color(0xFF5C6BC0), Color(0xFF8E24AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Summary card gradients list (rotate by index)
  static const List<LinearGradient> parentSummaryGradients = [
    parentGradient,
    parentGreenGradient,
    parentCardGradient,
    parentIndigoGradient,
    parentAmberGradient,
  ];

  // ── Border Radius ─────────────────────────────────────────────
  static final BorderRadius radiusSmall = BorderRadius.circular(12);
  static final BorderRadius radiusMedium = BorderRadius.circular(20);
  static final BorderRadius radiusLarge = BorderRadius.circular(28);
  static final BorderRadius radiusXL = BorderRadius.circular(36);

  // ── Shadows ───────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withOpacity(0.18),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> parentCardShadow = [
    BoxShadow(
      color: parentPrimary.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> parentSoftShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  // ── Theme Data ────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          surface: cardWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: cardWhite,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: cardWhite,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: textDark,
            fontFamily: 'Nunito',
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textDark,
            fontFamily: 'Nunito',
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
            fontFamily: 'Nunito',
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textDark,
            fontFamily: 'Nunito',
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textDark,
            fontFamily: 'Nunito',
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textMuted,
            fontFamily: 'Nunito',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: cardWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardWhite,
          selectedItemColor: primary,
          unselectedItemColor: textMuted,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          elevation: 20,
        ),
      );
}
