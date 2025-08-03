// lib/themes/alvorecer_theme.dart
import 'package:flutter/material.dart';

class AlvorecerTheme {
  // Cores Alvorecer
  static const Color primaryGold = Color(0xFFE8B86D);        // Dourado suave
  static const Color primaryBlue = Color(0xFF8DA3A6);        // Azul amanhecer
  static const Color primaryDark = Color(0xFF2C3E50);        // Azul noturno
  static const Color accentGold = Color(0xFFD4A574);         // Dourado suave escuro
  
  static const Color backgroundLight = Color(0xFFFAF9F7);    // Creme suave
  static const Color backgroundDark = Color(0xFF1A1A1A);     // Escuro suave
  static const Color cardLight = Color(0xFFFFFFFF);          // Branco
  static const Color cardDark = Color(0xFF2D2D2D);           // Cinza escuro
  
  static const Color textPrimary = Color(0xFF2C3E50);        // Texto escuro
  static const Color textSecondary = Color(0xFF7F8C8D);      // Texto secundário
  static const Color textLight = Color(0xFFFFFFFF);          // Texto claro

  // Propriedades estáticas para acesso direto (compatibilidade com o código)
  static Color get primaryColor => primaryGold;
  static Color get backgroundColor => backgroundLight;
  static Color get textPrimaryColor => textPrimary;
  static Color get textSecondaryColor => textSecondary;

  // Tema Claro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: _createMaterialColor(primaryGold),
    primaryColor: primaryGold,
    scaffoldBackgroundColor: backgroundLight,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGold,
      foregroundColor: textLight,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
    ),
    
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: cardLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
    ),
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGold,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryGold,
      secondary: primaryBlue,
      surface: cardLight,
      background: backgroundLight,
    ),
  );

  // Tema Escuro  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: _createMaterialColor(accentGold),
    primaryColor: accentGold,
    scaffoldBackgroundColor: backgroundDark,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: textLight,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
    ),
    
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGold,
        foregroundColor: backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentGold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textLight, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textLight, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.grey, fontSize: 14),
    ),
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentGold,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accentGold,
      secondary: primaryBlue,
      surface: cardDark,
      background: backgroundDark,
    ),
  );

  // Função helper para criar MaterialColor
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }

  // Cores adicionais para funcionalidades especiais
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color infoColor = Color(0xFF3498DB);

  // Gradientes
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, accentGold],
  );

  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardLight, cardLight.withOpacity(0.9)],
  );
}