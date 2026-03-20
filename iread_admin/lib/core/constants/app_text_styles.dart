import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium typography system with fluid scaling
class AppTextStyles {
  // Fluid scaling logic: Min size on mobile, Max size on desktop
  static double _scale(BuildContext context, double min, double max) {
    double width = MediaQuery.of(context).size.width;
    // Breakpoints
    const double minW = 375;
    const double maxW = 1440;
    
    if (width <= minW) return min;
    if (width >= maxW) return max;
    
    // Linear interpolation
    return min + (max - min) * ((width - minW) / (maxW - minW));
  }

  // Headings
  static TextStyle heading1(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 26, 36),
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle heading2(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 20, 28),
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle heading3(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 17, 22),
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  // Body Text
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
    fontSize: _scale(context, 15, 18),
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.5,
  );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
    fontSize: _scale(context, 14, 16),
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.5,
  );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
    fontSize: _scale(context, 12, 13),
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    letterSpacing: 0.1,
  );

  // Button Text
  static TextStyle button(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 13, 15),
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  static TextStyle buttonLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 15, 17),
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 0.8,
  );

  // Form Labels
  static TextStyle label(BuildContext context) => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.2,
  );

  // Special Text
  static TextStyle instruction(BuildContext context) => GoogleFonts.inter(
    fontSize: _scale(context, 15, 17),
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.6,
  );

  static TextStyle wordLabel(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 20, 32),
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );
}
