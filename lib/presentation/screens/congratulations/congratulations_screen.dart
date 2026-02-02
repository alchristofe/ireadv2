import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';

import 'package:iread/core/routes/route_names.dart';
import 'package:iread/core/utils/audio_player_util.dart';

/// Congratulations screen after completing a unit
class CongratulationsScreen extends StatefulWidget {
  final String unitId;
  final String categoryId;
  final String message;
  final String language;

  const CongratulationsScreen({
    super.key,
    required this.unitId,
    required this.categoryId,
    required this.message,
    this.language = 'english',
  });

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _continue() {
    context.pop(true);
  }

  void _goHome() {
    context.go(
      RouteNames.categorySelection,
      extra: widget.language,
    );
  }

  void _changeLanguage() {
    context.go(RouteNames.languageSelection);
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = widget.language.toLowerCase() == 'filipino';
    final avatarPath = widget.language.toLowerCase() == 'hiligaynon'
        ? 'assets/images/characters/hiligaynon.png'
        : widget.language.toLowerCase() == 'filipino'
            ? 'assets/images/characters/filipino_character.png'
            : 'assets/images/characters/english_character.png';
    
    final speechText = isFilipino
        ? 'Binabati kita! Natapos\nmo ang aralin!'
        : 'Congratulations! You\nfinished the lesson!';
        
    final buttonText = isFilipino ? 'MAGPATULOY' : 'CONTINUE';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E6), // Light peach background
      body: Stack(
        children: [
          // Confetti (keeping existing logic)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.success,
                AppColors.secondaryPink,
              ],
              numberOfParticles: 30,
              gravity: 0.3,
            ),
          ),

          // Flaglets Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/flaglets_1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40, // Offset for the second layer of flags
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/flaglets_2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60), // Clear flaglets
                const Spacer(flex: 3),
                
                // Speech Bubble
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0DC), // Light beige
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE0D0C0),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          speechText,
                          style: AppTextStyles.heading3.copyWith(
                            color: const Color(0xFF2D2D2D),
                            height: 1.5,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Speech bubble tail
                      Positioned(
                        bottom: -15,
                        right: 60,
                        child: CustomPaint(
                          size: const Size(30, 20),
                          painter: SpeechBubbleTailPainter(
                            color: const Color(0xFFFFF0DC),
                            borderColor: const Color(0xFFE0D0C0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40), // Increased spacing to push character lower

                // Character Avatar
                SizedBox(
                  height: 250, // Reduced height from 300
                  child: Image.asset(
                    avatarPath,
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(flex: 3),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomButton(
                    text: buttonText,
                    onPressed: _continue,
                    backgroundColor: const Color(0xFFFF9F43), // Orange
                  ),
                ),
                
                const SizedBox(height: 20),

                // Secondary Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Home / Category Selection
                      _buildSecondaryButton(
                        icon: Icons.grid_view_rounded,
                        label: 'Menu',
                        onTap: _goHome,
                      ),
                      const SizedBox(width: 24), // Reduced spacing
                      // Language Selection
                      _buildSecondaryButton(
                        icon: Icons.language,
                        label: 'Language',
                        onTap: _changeLanguage,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AudioPlayerUtil.playButtonSound();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 100, // Fixed width for consistency
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEDDB8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE0D0C0).withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0D0C0).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4E6), // Light peach to match bg
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF9F43), // Orange accent
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF5D4037), // Dark brown
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeechBubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  SpeechBubbleTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    // Draw shadow/fill to cover the border of the main bubble
    canvas.drawPath(path, paint);
    
    // Draw only the bottom two lines for border
    final borderPath = Path();
    borderPath.moveTo(0, 0);
    borderPath.lineTo(size.width / 2, size.height);
    borderPath.lineTo(size.width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
