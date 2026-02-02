import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:io' as io;

/// A wrapper for RiveAnimation that shows a placeholder during tests.
class AppRiveAnimation extends StatelessWidget {
  final String asset;
  final List<String> animations;
  final BoxFit fit;

  const AppRiveAnimation.asset(
    this.asset, {
    super.key,
    this.animations = const [],
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we are in a test environment
    final bool isTest =
        kDebugMode &&
        (const bool.fromEnvironment('flutter.test') ||
            (!kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST')));

    if (isTest) {
      return Container(
        color: Colors.blueGrey.withOpacity(0.1),
        child: Center(
          child: Text(
            'Rive Mock: $asset',
            style: const TextStyle(fontSize: 8, color: Colors.blueGrey),
          ),
        ),
      );
    }

    return RiveAnimation.asset(asset, animations: animations, fit: fit);
  }
}
