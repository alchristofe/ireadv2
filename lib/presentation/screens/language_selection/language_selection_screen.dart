import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/core/utils/audio_player_util.dart';
import 'package:iread/core/utils/background_music_manager.dart';
import 'package:iread/data/models/language.dart';

/// Language selection screen
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  LanguageType? _selectedLanguage;
  bool _isSettingsOpen = false;
  bool _isSfxEnabled = AudioPlayerUtil.isSfxEnabled;
  bool _isMusicEnabled = BackgroundMusicManager.instance.isMusicEnabled;
  Offset _bookPosition = const Offset(20, 20); // Initial position

  void _selectLanguage(LanguageType language) {
    setState(() {
      _selectedLanguage = language;
    });
    if (_isSfxEnabled) AudioPlayerUtil.playTapSound();
  }

  Timer? _teacherModeTimer;

  void _startTeacherModeTimer() {
    _cancelTeacherModeTimer();
    _teacherModeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.push(RouteNames.teacherLogin);
      }
    });
  }

  void _cancelTeacherModeTimer() {
    _teacherModeTimer?.cancel();
    _teacherModeTimer = null;
  }

  void _toggleSfx() {
    setState(() {
      _isSfxEnabled = !_isSfxEnabled;
    });
    AudioPlayerUtil.toggleSfx(_isSfxEnabled);
    if (_isSfxEnabled) AudioPlayerUtil.playTapSound();
  }

  void _toggleMusic() {
    setState(() {
      _isMusicEnabled = !_isMusicEnabled;
    });
    BackgroundMusicManager.instance.toggleMusic(_isMusicEnabled);
    if (_isSfxEnabled) AudioPlayerUtil.playTapSound();
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9F43),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'About',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          '© 2026. iRead. Northern Iloilo State University. All Rights Reserved.\n\n'
                          'This software, including its source code, system design, user interface, and accompanying documentation, is protected by applicable copyright laws.\n\n'
                          'iRead is as an output of the research project entitled “Revolutionizing Reading through iRead: An Interactive, Multilingual, and Culturally Responsive Mobile Application,” funded by Northern Iloilo State University (NISU).\n\n'
                          'Authors:',
                          style: AppTextStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jan Carlo T. Arroyo\n'
                          'Bon Eric A. Besonia\n'
                          'Allemar Jhone P. Delima\n'
                          'Felipe P. Vista Jr.\n'
                          'Mark Ronar G. Galagala\n'
                          'Marieth Flor M. Bernardez\n'
                          'Shiela Mae H. Espora\n'
                          'Rizzamila R. Superio\n'
                          'April Rose A. Zaragosa',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'COOL!',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continue() {
    if (_selectedLanguage != null) {
      context.push(
        RouteNames.categorySelection,
        extra: _selectedLanguage!.name,
      );
    }
  }

  String _getBackgroundPath() {
    switch (_selectedLanguage) {
      case LanguageType.english:
        return 'assets/images/ui/bg_english.png';
      case LanguageType.filipino:
        return 'assets/images/ui/bg_filipino.png';
      case LanguageType.hiligaynon:
        return 'assets/images/ui/bg_hiligaynon.png';
      default:
        return 'assets/images/ui/bg_default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background with smooth transition (Filling the screen)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                _getBackgroundPath(),
                key: ValueKey(_getBackgroundPath()),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (c, e, s) =>
                    Container(color: const Color(0xFFFFF4E6)),
              ),
            ),
          ),

          // Glassy Gradient Overlay for legibility while keeping the center clear
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;

                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isWide)
                                const SizedBox(
                                  height: 60,
                                ), // Space for top button on mobile
                              // Title
                              Text(
                                _selectedLanguage == LanguageType.filipino
                                    ? 'Gusto kong matuto...'
                                    : _selectedLanguage ==
                                          LanguageType.hiligaynon
                                    ? 'Gusto ko magtuon...'
                                    : 'I want to learn...',
                                style: AppTextStyles.heading2.copyWith(
                                  color: const Color(0xFF3D2C29),
                                  fontSize: isWide ? 36 : 28,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // Language Cards - Responsive Layout
                              if (isWide)
                                Wrap(
                                  spacing: 32,
                                  runSpacing: 32,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _LanguageCard(
                                      language: LanguageType.english,
                                      isSelected:
                                          _selectedLanguage ==
                                          LanguageType.english,
                                      onTap: () =>
                                          _selectLanguage(LanguageType.english),
                                      width: 200,
                                    ),
                                    Listener(
                                      onPointerDown: (_) =>
                                          _startTeacherModeTimer(),
                                      onPointerUp: (_) =>
                                          _cancelTeacherModeTimer(),
                                      onPointerCancel: (_) =>
                                          _cancelTeacherModeTimer(),
                                      child: _LanguageCard(
                                        language: LanguageType.filipino,
                                        isSelected:
                                            _selectedLanguage ==
                                            LanguageType.filipino,
                                        onTap: () => _selectLanguage(
                                          LanguageType.filipino,
                                        ),
                                        width: 200,
                                      ),
                                    ),
                                    _LanguageCard(
                                      language: LanguageType.hiligaynon,
                                      isSelected:
                                          _selectedLanguage ==
                                          LanguageType.hiligaynon,
                                      onTap: () => _selectLanguage(
                                        LanguageType.hiligaynon,
                                      ),
                                      width: 200,
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _LanguageCard(
                                      language: LanguageType.english,
                                      isSelected:
                                          _selectedLanguage ==
                                          LanguageType.english,
                                      onTap: () =>
                                          _selectLanguage(LanguageType.english),
                                    ),
                                    const SizedBox(height: 20),
                                    Listener(
                                      onPointerDown: (_) =>
                                          _startTeacherModeTimer(),
                                      onPointerUp: (_) =>
                                          _cancelTeacherModeTimer(),
                                      onPointerCancel: (_) =>
                                          _cancelTeacherModeTimer(),
                                      child: _LanguageCard(
                                        language: LanguageType.filipino,
                                        isSelected:
                                            _selectedLanguage ==
                                            LanguageType.filipino,
                                        onTap: () => _selectLanguage(
                                          LanguageType.filipino,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _LanguageCard(
                                      language: LanguageType.hiligaynon,
                                      isSelected:
                                          _selectedLanguage ==
                                          LanguageType.hiligaynon,
                                      onTap: () => _selectLanguage(
                                        LanguageType.hiligaynon,
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 40),

                              // Continue Button
                              SizedBox(
                                width: isWide ? 300 : double.infinity,
                                child: CustomButton(
                                  text: 'CONTINUE',
                                  onPressed: _selectedLanguage != null
                                      ? _continue
                                      : null,
                                  isDisabled: _selectedLanguage == null,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Story Mode Movable Button
                Positioned(
                  top: _bookPosition.dy,
                  left: _bookPosition.dx,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final newX = _bookPosition.dx + details.delta.dx;
                        final newY = _bookPosition.dy + details.delta.dy;

                        // Simple boundary checks
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;

                        _bookPosition = Offset(
                          newX.clamp(10.0, screenWidth - 70.0),
                          newY.clamp(10.0, screenHeight - 70.0),
                        );
                      });
                    },
                    onTap: () => context.push(RouteNames.storyCategory),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFFFF9F43),
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // Settings Floating Menu
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isSettingsOpen = !_isSettingsOpen),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isSettingsOpen
                                ? const Color(0xFFFF9F43)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isSettingsOpen
                                ? Icons.close
                                : Icons.settings_rounded,
                            color: _isSettingsOpen
                                ? Colors.white
                                : const Color(0xFFFF9F43),
                            size: 32,
                          ),
                        ),
                      ),
                      if (_isSettingsOpen) ...[
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          icon: _isSfxEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: _isSfxEnabled
                              ? const Color(0xFF4CAF50)
                              : AppColors.disabledGray,
                          onTap: _toggleSfx,
                        ),
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          icon: _isMusicEnabled
                              ? Icons.music_note_rounded
                              : Icons.music_off_rounded,
                          color: _isMusicEnabled
                              ? const Color(0xFFFF4081)
                              : AppColors.disabledGray,
                          onTap: _toggleMusic,
                        ),
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          icon: Icons.info_outline_rounded,
                          color: const Color(0xFF2196F3),
                          onTap: _showAboutApp,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(scale: value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final LanguageType language;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? 180,
        height: 180,
        // constraints: const BoxConstraints(maxWidth: 400), // Removed constraint that encouraged stretching
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4C4),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF9F43)
                : const Color(0xFFC4A484),
            width: isSelected ? 6 : 4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9F43).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.cardBorder.withValues(alpha: 0.5),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  language.flagAsset,
                  width: 140,
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (c, o, s) => const Icon(Icons.flag, size: 60),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Language Name
            Text(
              language.displayName,
              style: AppTextStyles.heading3.copyWith(
                color: const Color(0xFF3D2C29),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
