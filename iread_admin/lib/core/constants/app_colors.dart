import 'package:flutter/material.dart';

/// App color palette based on design mockups
class AppColors {
  // Primary Colors
  static const Color background = Color(0xFFFFF4E6); // Warm beige/cream
  static const Color primary = Color(0xFFFF8C42); // Orange
  static const Color primaryDark = Color(0xFFE67A2E);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4A90E2); // Blue
  static const Color secondaryPink = Color(0xFFE74C8C); // Pink
  
  // Feedback Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFE74C3C); // Red
  static const Color warning = Color(0xFFFFA726); // Amber
  
  // Text Colors
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textMedium = Color(0xFF5A6C7D);
  static const Color textLight = Color(0xFF8E9AAF);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // UI Elements
  static const Color cardBorder = Color(0xFFE0D4C0);
  static const Color cardBackground = Color(0xFFFFFBF5);
  static const Color disabledGray = Color(0xFFBDBDBD);
  static const Color progressBarBackground = Color(0xFFE0D4C0);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
