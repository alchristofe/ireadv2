import 'package:flutter/material.dart';

/// Consistent spacing and layout constants
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double jambo = 64.0;

  // Insets
  static const EdgeInsets edgeInsetsXS = EdgeInsets.all(xs);
  static const EdgeInsets edgeInsetsS = EdgeInsets.all(s);
  static const EdgeInsets edgeInsetsM = EdgeInsets.all(m);
  static const EdgeInsets edgeInsetsL = EdgeInsets.all(l);
  static const EdgeInsets edgeInsetsXL = EdgeInsets.all(xl);

  // Horizontal Spacing
  static const Widget horizontalXS = SizedBox(width: xs);
  static const Widget horizontalS = SizedBox(width: s);
  static const Widget horizontalM = SizedBox(width: m);
  static const Widget horizontalL = SizedBox(width: l);
  static const Widget horizontalXL = SizedBox(width: xl);

  // Vertical Spacing
  static const Widget verticalXS = SizedBox(height: xs);
  static const Widget verticalS = SizedBox(height: s);
  static const Widget verticalM = SizedBox(height: m);
  static const Widget verticalL = SizedBox(height: l);
  static const Widget verticalXL = SizedBox(height: xl);
  static const Widget verticalXXL = SizedBox(height: xxl);

  // Layout Constraints
  static const double maxContentWidth = 1200.0;
  static const double loginCardWidth = 450.0;
  static const double sidebarWidth = 280.0;
}
