import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF9500);
  static const Color secondaryColor = Color(0xFF4A90E2);
  
  static Color get primaryGold => primaryColor;
  static Color get primaryOrange => primaryColor;
  static Color get secondaryBlue => secondaryColor;
  static Color get textDark => Colors.black87;
  static Color get textGray => Colors.grey;
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );
  }
  
  static ThemeData get darkTheme => ThemeData.dark();
}
