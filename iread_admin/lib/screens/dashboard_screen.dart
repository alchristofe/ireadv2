import 'package:flutter/material.dart';
import 'units_list_screen.dart';
import '../data/models/language.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/responsive_layout.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

enum SidebarView { units, settings }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LanguageType _selectedLanguage = LanguageType.english;
  SidebarView _currentView = SidebarView.units;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isMobileOrTablet = !ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobileOrTablet
          ? Drawer(
              width: AppSpacing.sidebarWidth,
              backgroundColor: AppColors.surface,
              child: _AdminSidebar(
                selectedLanguage: _selectedLanguage,
                currentView: _currentView,
                onLanguageSelected: (type) {
                  setState(() {
                    _selectedLanguage = type;
                    _currentView = SidebarView.units;
                  });
                  _scaffoldKey.currentState?.closeDrawer();
                },
                onViewSelected: (view) {
                  setState(() => _currentView = view);
                  _scaffoldKey.currentState?.closeDrawer();
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for Desktop
          if (!isMobileOrTablet)
            _AdminSidebar(
              selectedLanguage: _selectedLanguage,
              currentView: _currentView,
              onLanguageSelected: (type) {
                setState(() {
                  _selectedLanguage = type;
                  _currentView = SidebarView.units;
                });
              },
              onViewSelected: (view) => setState(() => _currentView = view),
            ),
          
          // Main Content
          Expanded(
            child: _buildMainContent(isMobileOrTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    switch (_currentView) {
      case SidebarView.units:
        return UnitsListScreen(
          language: _selectedLanguage,
          isMobile: isMobile,
          onMenuPressed: isMobile ? () => _scaffoldKey.currentState?.openDrawer() : null,
        );
      case SidebarView.settings:
        return SettingsScreen(
          isMobile: isMobile,
          onMenuPressed: isMobile ? () => _scaffoldKey.currentState?.openDrawer() : null,
        );
    }
  }
}

class _AdminSidebar extends StatelessWidget {
  final LanguageType selectedLanguage;
  final SidebarView currentView;
  final Function(LanguageType) onLanguageSelected;
  final Function(SidebarView) onViewSelected;

  const _AdminSidebar({
    required this.selectedLanguage,
    required this.currentView,
    required this.onLanguageSelected,
    required this.onViewSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
      ),
      child: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l, 
              vertical: AppSpacing.xxl
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const RiveAnimation.asset(
                    'assets/rive/antfly.riv',
                    animations: ['idle'],
                    fit: BoxFit.contain,
                  ),
                ),
                AppSpacing.horizontalM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/iread_text.png',
                        height: 18,
                        fit: BoxFit.contain,
                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                      ),
                      AppSpacing.verticalXS,
                      Text(
                        'ADMIN CONSOLE',
                        style: AppTextStyles.label(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          AppSpacing.verticalL,
          
          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              children: [
                _buildSectionHeader(context, 'CONTENT MANAGEMENT'),
                AppSpacing.verticalS,
                _buildLanguageTile(context, LanguageType.english, 'English Units', Icons.translate_rounded),
                _buildLanguageTile(context, LanguageType.filipino, 'Filipino Units', Icons.language_rounded),
                _buildLanguageTile(context, LanguageType.hiligaynon, 'Hiligaynon Units', Icons.public_rounded),
                
                AppSpacing.verticalXL,
                _buildSectionHeader(context, 'SYSTEM'),
                _buildNavTile(
                  context, 
                  'Settings', 
                  Icons.settings_outlined, 
                  () => onViewSelected(SidebarView.settings),
                  isSelected: currentView == SidebarView.settings,
                ),
                _buildNavTile(
                  context, 
                  'Activity Logs', 
                  Icons.history_rounded, 
                  () {},
                  badgeText: 'COMING SOON',
                ),
              ],
            ),
          ),
          
          // Footer / User Profile
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                ),
                AppSpacing.horizontalM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Super Admin', 
                        style: AppTextStyles.label(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'iRead V2', 
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.textLight, size: 18),
                  tooltip: 'Log out',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.m, bottom: 4),
      child: Text(
        title,
        style: AppTextStyles.label(context).copyWith(
          color: AppColors.textLight,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, LanguageType type, String title, IconData icon) {
    final isSelected = currentView == SidebarView.units && selectedLanguage == type;
    
    return _buildNavTile(
      context, 
      title, 
      icon, 
      () => onLanguageSelected(type),
      isSelected: isSelected,
    );
  }

  Widget _buildNavTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isSelected = false, String? badgeText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.textMedium,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: AppTextStyles.label(context).copyWith(
                    color: AppColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      ),
    );
  }
}
