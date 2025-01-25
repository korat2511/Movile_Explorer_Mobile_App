import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _languageKey = 'language_code';

  LanguageService(this._prefs);

  String get languageCode => _prefs.getString(_languageKey) ?? 'en';

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  Locale get locale => Locale(languageCode);
} 