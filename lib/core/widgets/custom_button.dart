import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/audio_player_util.dart';
import '../utils/responsive_utils.dart';

/// Custom button widget matching design mockups
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56, // Default will be scaled in build
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isDisabled && !isLoading && onPressed != null;
    final double buttonHeight = height.h;
    final double buttonWidth = width != null ? width!.w : double.infinity;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                AudioPlayerUtil.playButtonSound();
                onPressed!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? (backgroundColor ?? AppColors.primary)
              : AppColors.disabledGray,
          foregroundColor: textColor ?? AppColors.textWhite,
          elevation: enabled ? 4 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 12.0.h),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textWhite,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 24.0.sp),
                    SizedBox(width: 8.0.w),
                  ],
                  Text(text.toUpperCase(), style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }
}
