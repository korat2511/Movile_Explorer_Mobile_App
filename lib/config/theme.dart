import 'package:flutter/material.dart';

ThemeData appThemeData() {
  Color primaryColor = const Color(0xff27a48b);
  Color contrastColor = const Color(0xffd6ac3c);

  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "Poppins",
    primarySwatch: createMaterialColor(primaryColor),
    focusColor: createMaterialColor(primaryColor)[900],
    dividerColor: getTextColor(primaryColor),
    highlightColor: contrastColor,

    indicatorColor: createMaterialColor(primaryColor)[200],
    primaryColor: primaryColor,
    hintColor: createMaterialColor(primaryColor)[50],
    textTheme: TextTheme(
      labelLarge: TextStyle(
          color: getTextColor(primaryColor), fontWeight: FontWeight.bold),
      displayLarge: TextStyle(color: getTextColor(primaryColor)),
      displayMedium: TextStyle(color: getTextColor(primaryColor)),
      displaySmall: TextStyle(
        color: primaryColor,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

MaterialColor getTextColor(Color color) {
  int d = 0;
  double luminance = color.computeLuminance();
  if (luminance > 0.5) {
    d = 0;
  } else {
    d = 255;
  }
  return createMaterialColor(
    Color.fromARGB(color.alpha, d, d, d),
  );
}

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
