import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// Utility class for handling responsive UI scaling.
/// It uses a base design size (375x812 by default, which is common for iPhone X/11/12/13/14).
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double devicePixelRatio;
  static late double statusBarHeight;
  static late double bottomBarHeight;
  static late Orientation orientation;

  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  /// Initialize the responsive utility. This should be called in the top-level build method.
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;
    statusBarHeight = _mediaQueryData.padding.top;
    bottomBarHeight = _mediaQueryData.padding.bottom;
    orientation = _mediaQueryData.orientation;
  }

  /// Get the scaling factor for width.
  static double get widthScale => screenWidth / baseWidth;

  /// Get the scaling factor for height.
  static double get heightScale => screenHeight / baseHeight;

  /// Get the average scaling factor for text or items that need to scale proportionally.
  static double get scale => math.min(widthScale, heightScale);

  /// Get responsive width.
  static double w(double width) => width * widthScale;

  /// Get responsive height.
  static double h(double height) => height * heightScale;

  /// Get responsive font size.
  static double sp(double fontSize) => fontSize * scale;

  /// Determine if the device is a tablet.
  static bool get isTablet => screenWidth >= 600 || screenHeight >= 600;

  /// Determine if the device is in landscape mode.
  static bool get isLandscape => orientation == Orientation.landscape;

  /// Get a value based on device type (mobile or tablet).
  static T select<T>({required T mobile, required T tablet}) {
    return isTablet ? tablet : mobile;
  }
}

/// Extension for easier access to responsive values on num.
extension ResponsiveNum on num {
  double get w => Responsive.w(toDouble());
  double get h => Responsive.h(toDouble());
  double get sp => Responsive.sp(toDouble());
}
