import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App text styles for consistent typography
class AppTextStyles {
  // Headings
  static TextStyle get heading1 => GoogleFonts.baloo2(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle get heading2 => GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle get heading3 => GoogleFonts.baloo2(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.baloo2(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static TextStyle get bodyMedium => GoogleFonts.baloo2(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static TextStyle get bodySmall => GoogleFonts.baloo2(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
  );

  // Button Text
  static TextStyle get button => GoogleFonts.baloo2(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonLarge => GoogleFonts.baloo2(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
    letterSpacing: 1.0,
  );

  // Special Text
  static TextStyle get instruction => GoogleFonts.baloo2(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle get wordLabel => GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle get letterDisplay => GoogleFonts.baloo2(
    fontSize: 80,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle get congratulations => GoogleFonts.baloo2(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}
