import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'data/services/theme_service.dart';
import 'presentation/bloc/movie_bloc.dart';
import 'config/globals.dart';
import 'config/theme.dart';
import 'presentation/pages/home_page.dart';
import 'data/services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'data/services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService();
  await storage.init();

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
          navigatorKey: Globals.navigatorKey,
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
