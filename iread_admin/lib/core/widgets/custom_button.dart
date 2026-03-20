import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';
import 'responsive_layout.dart';

/// Premium custom button with responsive sizing and elegant feedback
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isDisabled && !isLoading && onPressed != null;
    
    // Responsive sizing - smaller on mobile, standard on desktop
    final double defaultHeight = responsiveValue(
      context,
      mobile: 48,
      desktop: 52,
    );
    
    final currentHeight = height ?? defaultHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: currentHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary 
            ? AppColors.surface 
            : (enabled ? (backgroundColor ?? AppColors.primary) : AppColors.divider),
          foregroundColor: isSecondary 
            ? AppColors.primary 
            : (textColor ?? AppColors.textWhite),
          elevation: isSecondary ? 0 : (enabled ? 4 : 0),
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          side: isSecondary ? const BorderSide(color: AppColors.primary, width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          splashFactory: InkRipple.splashFactory,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? AppColors.primary : AppColors.textWhite,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    AppSpacing.horizontalS,
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button(context).copyWith(
                      color: isSecondary 
                        ? AppColors.primary 
                        : (enabled ? (textColor ?? AppColors.textWhite) : AppColors.textLight),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
