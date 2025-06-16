import 'package:flutter/material.dart';

// AppTheme class to define custom theme data for the app
class AppTheme {
  // Define primary and secondary colors
  static const Color primaryColor = Color(0xFFD3E0EF);
  static const Color secondaryColor = Color(0xFF1C2A68);
  static const Color navIconLight = Color(0xFF52859E);

  // Define background colors for light and dark themes
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);

  // Define bottom navigation background colors
  static const Color bottomNavLight = primaryColor;
  static const Color bottomNavDark = Color(0xFF1E1E1E);

  // Define text colors for light and dark themes
  static const Color textColorLightGray = Color(0xFF8A8A8A);
  static const Color textColorLightDarkBlue = Color(0xFF244F76);
  static const Color textColorLightWhite = Color(0xFFF3F7F5);
  static const Color textColorDark = Color(0xFFFFFFFF);

  // Define light theme configuration
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,
    textTheme: textTheme,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bottomNavLight,
    ),
  );

  // Define dark theme configuration
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundDark,
    textTheme: textThemeDark,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bottomNavDark,
    ),
  );

  // Define the default font family for the app
  static const String fontFamily = "Raleway";

  // Define custom text theme for light mode
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
        color: textColorLightDarkBlue),
    displayMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
        color: textColorLightDarkBlue),
    bodyLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: textColorLightDarkBlue),
    bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: textColorLightDarkBlue),
  );

  // Define custom text theme for dark mode
  static const TextTheme textThemeDark = TextTheme(
    displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
        color: textColorDark),
    displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
        color: textColorDark),
    bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: textColorDark),
    bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: textColorDark),
  );
}
