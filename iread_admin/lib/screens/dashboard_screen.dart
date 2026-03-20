import 'package:flutter/material.dart';
import 'units_list_screen.dart';
import '../data/models/language.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LanguageType _selectedLanguage = LanguageType.english;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              width: 280,
              child: _AdminSidebar(
                selectedLanguage: _selectedLanguage,
                onLanguageSelected: (type) {
                  setState(() => _selectedLanguage = type);
                  _scaffoldKey.currentState?.closeDrawer();
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for Desktop
          if (!isMobile)
            _AdminSidebar(
              selectedLanguage: _selectedLanguage,
              onLanguageSelected: (type) => setState(() => _selectedLanguage = type),
            ),
          
          // Main Content
          Expanded(
            child: UnitsListScreen(
              language: _selectedLanguage,
              isMobile: isMobile,
              onMenuPressed: isMobile ? () => _scaffoldKey.currentState?.openDrawer() : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final LanguageType selectedLanguage;
  final Function(LanguageType) onLanguageSelected;

  const _AdminSidebar({
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const RiveAnimation.asset(
                    'assets/rive/antfly.riv',
                    animations: ['idle'],
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/iread_text.png',
                        height: 24,
                        fit: BoxFit.contain,
                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Super Admin',
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSectionHeader('MANAGE CONTENT'),
                const SizedBox(height: 8),
                _buildLanguageTile(LanguageType.english, 'English Units', Icons.g_translate),
                _buildLanguageTile(LanguageType.filipino, 'Filipino Units', Icons.language),
                _buildLanguageTile(LanguageType.hiligaynon, 'Hiligaynon Units', Icons.public),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin User', style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text('Super Access', style: AppTextStyles.bodySmall(context).copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.grey, size: 20),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(LanguageType type, String title, IconData icon) {
    final isSelected = selectedLanguage == type;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () => onLanguageSelected(type),
      ),
    );
  }
}
