import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/core/utils/speech_recognition_util.dart';
import 'package:iread/data/local/hive_service.dart';
import 'package:iread/core/widgets/app_rive_animation.dart';

/// Splash screen with app logo and loading
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      await HiveService.init();
      // Pre-initialize speech recognition (especially Vosk models)
      // This ensures models are unpacked and ready for offline use
      await SpeechRecognitionUtil.initialize();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  Future<void> _handleNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding =
        prefs.getBool('has_seen_onboarding') ?? false;

    if (mounted) {
      if (hasSeenOnboarding) {
        context.go(RouteNames.languageSelection);
      } else {
        context.go(RouteNames.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEDC), // soft beige like your design
      body: Stack(
        children: [
          // Background decorative pattern (PNG)
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/upper_pattern.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          ),

          // Background decorative pattern (PNG)
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/bottom_pattern.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          ),

          // Center Rive animation (antfly)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 130,
                  height: 130,
                  child: AppRiveAnimation.asset(
                    'assets/rive/antfly.riv',
                    // your rive animation name
                    animations: ['idle'],
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/iread_text.png',
                  width: 120, // Increased width
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    text: 'TAP TO LEARN',
                    onPressed: _handleNavigation,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push(RouteNames.teacherLogin),
                    child: Text(
                      'Teacher Mode',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
