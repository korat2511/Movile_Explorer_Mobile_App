import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static double getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2; // Phone
    if (width < 900) return 3; // Small tablet
    if (width < 1200) return 4; // Large tablet
    return 5; // Extra large screens
  }

  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 115; // Phone
    if (width < 900) return 150; // Small tablet
    return 180; // Large tablet and above
  }

  static double getPosterHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 150; // Phone
    if (width < 900) return 200; // Small tablet
    return 240; // Large tablet and above
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isPhone(context)) {
      return const EdgeInsets.all(8.0);
    }
    return const EdgeInsets.all(16.0);
  }
} 