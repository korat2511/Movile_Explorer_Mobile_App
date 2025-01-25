import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_explorer/data/models/movie_details.dart';
import 'package:movie_explorer/data/repositories/movie_repository_impl.dart';
import 'package:movie_explorer/data/services/local_storage_service.dart';
import 'package:movie_explorer/data/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHelpers {
  static Widget wrapWithMaterialApp(Widget widget) {
    return MaterialApp(home: widget);
  }

  static Widget wrapWithProviders(Widget widget) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalStorageService>(
          create: (_) => LocalStorageService(),
        ),
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(SharedPreferences.getInstance() as SharedPreferences),
        ),
      ],
      child: MaterialApp(home: widget),
    );
  }

  static MovieDetails createTestMovie() {
    return MovieDetails(
      id: 1,
      title: 'Test Movie',
      overview: 'Test Overview',
      posterPath: '/test.jpg',
      backdropPath: '/backdrop.jpg',
      releaseDate: '2024-01-01',
      voteAverage: 8.5,
      voteCount: 100,
      adult: false,
      genreIds: [1, 2],
      originalLanguage: 'en',
      originalTitle: 'Test Movie',
      popularity: 100.0,
      video: false,
    );
  }
} 