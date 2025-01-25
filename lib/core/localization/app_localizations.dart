import 'package:flutter/material.dart';
import 'translations.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late final Map<String, String> _localizedStrings = locale.languageCode == 'hi' 
      ? hindiTranslations 
      : englishTranslations;

  String translate(String key) => _localizedStrings[key] ?? key;

  static final List<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale('hi', ''),
  ];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 