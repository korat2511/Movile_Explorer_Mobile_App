import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'core/localization/app_localizations.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'data/services/language_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/theme_service.dart';
import 'firebase_options.dart';
import 'presentation/bloc/movie_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'core/services/ad_service.dart';
import 'core/services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService();
  await storage.init();

  // Initialize services
  await AdService.initialize();
  await PremiumService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(
          value: prefs,
        ),
        ChangeNotifierProvider<LocalStorageService>(
          create: (_) => storage,
        ),
        ChangeNotifierProvider<ThemeService>(
          create: (context) => ThemeService(prefs),
        ),
        ChangeNotifierProvider<LanguageService>(
          create: (context) => LanguageService(prefs),
        ),
        BlocProvider(
          create: (context) => MovieBloc(
            repository: MovieRepositoryImpl(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LanguageService>(
      builder: (context, themeService, languageService, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: lightTheme(),
          darkTheme: darkTheme(),
          locale: languageService.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomePage(),
        );
      },
    );
  }
}
