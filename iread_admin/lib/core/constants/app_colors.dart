import 'package:flutter/material.dart';

/// App color palette based on premium dashboard design standards
class AppColors {
  // Primary Brand Colors (Maintained but refined)
  static const Color primary = Color(0xFFFF8C42); // Vibrant Orange
  static const Color primaryLight = Color(0xFFFFAC6B);
  static const Color primaryDark = Color(0xFFE67A2E);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4A90E2); // Professional Blue
  static const Color secondaryDark = Color(0xFF357ABD);
  
  // Premium Neutral Palette
  static const Color background = Color(0xFFF8F9FA); // Ultra-light gray for modern feel
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  
  // Text Hierarchy
  static const Color textDark = Color(0xFF1A1D23); // Almost black for high readability
  static const Color textMedium = Color(0xFF495057); // Slate gray for body
  static const Color textLight = Color(0xFFADB5BD); // Muted gray for captions
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF00B894); // Mint green
  static const Color error = Color(0xFFFF7675); // Soft red
  static const Color warning = Color(0xFFFAB1A0); // Soft amber
  
  // UI Elements
  static const Color cardBorder = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFDEE2E6);
  static const Color inputFill = Color(0xFFF8F9FA);
  
  // Shadows
  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
