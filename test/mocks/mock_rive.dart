import 'package:flutter/material.dart';

/// A mock for RiveAnimation that displays a simple placeholder.
/// This avoids the "Failed to load dynamic library 'rive_common_plugin.dll'" error during tests.
class MockRiveAnimation extends StatelessWidget {
  final String name;

  const MockRiveAnimation.asset(
    String asset, {
    super.key,
    List<String>? animations,
    BoxFit? fit,
  }) : name = asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.withOpacity(0.1),
      child: Center(
        child: Text(
          'Mock Rive: $name',
          style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
