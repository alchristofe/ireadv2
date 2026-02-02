import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/core/widgets/app_rive_animation.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _preloadAssets();
  }

  Future<void> _preloadAssets() async {
    try {
      // Load AssetManifest to get all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final imageAssets = manifestMap.keys
          .where(
            (String key) =>
                key.startsWith('assets/images/') ||
                key.startsWith('assets/data/'),
          )
          .toList();

      for (final asset in imageAssets) {
        if (asset.endsWith('.png') ||
            asset.endsWith('.jpg') ||
            asset.endsWith('.jpeg')) {
          if (!mounted) break;
          await precacheImage(AssetImage(asset), context);
        }
      }

      // Wait for a minimum time to show the animation
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) {
        context.go(RouteNames.splash);
      }
    } catch (e) {
      debugPrint('Error preloading assets: $e');
      // Proceed anyway
      if (mounted) {
        context.go(RouteNames.splash);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEDC), // soft beige
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

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bee Animation
                const SizedBox(
                  width: 130,
                  height: 130,
                  child: AppRiveAnimation.asset(
                    'assets/rive/antfly.riv',
                    animations: [
                      'idle',
                    ], // Assuming 'idle' exists, same as splash
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/iread_text.png',
                  width: 120, // Increased width
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                // Loading Text
                Text(
                  'LOADING...',
                  style: AppTextStyles.heading3.copyWith(
                    color: const Color(0xFFD35400), // Dark orange/brownish
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
