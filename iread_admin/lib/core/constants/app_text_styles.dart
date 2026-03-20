import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App text styles for consistent typography
class AppTextStyles {
  static double _getResponsiveSize(BuildContext context, double baseSize) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return baseSize * 0.85; // Scale down for mobile
    } else if (width < 1200) {
      return baseSize * 0.95; // Slightly scale down for tablets
    }
    return baseSize;
  }

  // Headings
  static TextStyle heading1(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 32),
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle heading2(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 24),
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle heading3(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 20),    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Body Text
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.nunito(
    fontSize: _getResponsiveSize(context, 18),
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.nunito(
    fontSize: _getResponsiveSize(context, 16),
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.nunito(
    fontSize: _getResponsiveSize(context, 14),
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
  );

  // Button Text
  static TextStyle button(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 18),
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  static TextStyle buttonLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 20),
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
    letterSpacing: 1.0,
  );

  // Special Text
  static TextStyle instruction(BuildContext context) => GoogleFonts.nunito(
    fontSize: _getResponsiveSize(context, 16),
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle wordLabel(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 24),
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle letterDisplay(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 80),
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle congratulations(BuildContext context) => GoogleFonts.poppins(
    fontSize: _getResponsiveSize(context, 28),
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}
