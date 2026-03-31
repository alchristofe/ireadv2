import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';

class SettingsScreen extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onMenuPressed;

  const SettingsScreen({
    super.key,
    this.isMobile = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSpacing.l : AppSpacing.xl,
                vertical: isMobile ? AppSpacing.xl : AppSpacing.xxl,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (onMenuPressed != null) ...[
                        IconButton(
                          icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
                          onPressed: onMenuPressed,
                        ),
                        AppSpacing.horizontalXS,
                      ],
                      Text('System Settings', style: AppTextStyles.heading1(context)),
                    ],
                  ),
                  AppSpacing.verticalXS,
                  Text(
                    'Configure admin dashboard preferences and platform defaults',
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ],
              ),
            ),
            
            // Settings Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(isMobile ? AppSpacing.m : AppSpacing.xl),
                children: [
                  _buildSection(context, 'General Settings', [
                    _buildSettingTile(
                      context,
                      'Cloudinary Integration',
                      'Manage media storage and delivery settings',
                      Icons.cloud_queue_rounded,
                      trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primary),
                    ),
                    _buildSettingTile(
                      context,
                      'Automatic Backups',
                      'Schedule daily database snapshots',
                      Icons.backup_outlined,
                      trailing: Switch(value: false, onChanged: (_) {}, activeColor: AppColors.primary),
                    ),
                  ]),
                  
                  AppSpacing.verticalL,
                  
                  _buildSection(context, 'Interface Customization', [
                    _buildSettingTile(
                      context,
                      'Dark Mode',
                      'Toggle dashboard appearance',
                      Icons.dark_mode_outlined,
                      trailing: Switch(value: false, onChanged: (_) {}, activeColor: AppColors.primary),
                    ),
                    _buildSettingTile(
                      context,
                      'Compact View',
                      'Show more items in the unit list',
                      Icons.view_compact_outlined,
                      trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primary),
                    ),
                  ]),
                  
                  AppSpacing.verticalL,
                  
                  _buildSection(context, 'Security', [
                    _buildSettingTile(
                      context,
                      'Session Timeout',
                      'Manage administrator login persistence',
                      Icons.timer_outlined,
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      context,
                      'Two-Factor Authentication',
                      'Secure your admin account with 2FA',
                      Icons.security_rounded,
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                      onTap: () {},
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s, bottom: AppSpacing.m),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.label(context).copyWith(
              color: AppColors.textLight,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    {Widget? trailing, VoidCallback? onTap}
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.xs),
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall(context)),
      trailing: trailing,
    );
  }
}
