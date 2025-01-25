import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeService(this._prefs);

  ThemeMode get themeMode {
    final isLight = _prefs.getBool(_themeKey) ?? true;
    return isLight ? ThemeMode.light : ThemeMode.dark;
  }

  bool get isLightMode => themeMode == ThemeMode.light;

  Future<void> toggleTheme() async {
    await _prefs.setBool(_themeKey, !isLightMode);
    notifyListeners();
  }
} 