import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/viewed_movie.dart';

class LocalStorageService extends ChangeNotifier {
  static const String _viewedMoviesBox = 'viewed_movies';
  late Box<ViewedMovie> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ViewedMovieAdapter());
    _box = await Hive.openBox<ViewedMovie>(_viewedMoviesBox);
  }

  Future<void> addViewedMovie(ViewedMovie movie) async {
    await _box.put(movie.id, movie);
  }

  Future<void> removeViewedMovie(int movieId) async {
    await _box.delete(movieId);
  }

  List<ViewedMovie> getViewedMovies() {
    return _box.values.toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  List<ViewedMovie> getFavoriteMovies() {
    return _box.values.where((movie) => movie.isFavorite).toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  bool isMovieViewed(int movieId) {
    return _box.containsKey(movieId);
  }

  bool isMovieFavorite(int movieId) {
    final movie = _box.get(movieId);
    return movie?.isFavorite ?? false;
  }

  Future<void> toggleFavorite(int movieId) async {
    final movie = _box.get(movieId);
    if (movie != null) {
      movie.isFavorite = !movie.isFavorite;
      await _box.put(movieId, movie);
      notifyListeners();
    }
  }

  Future<void> clearViewedMovies() async {
    await _box.clear();
  }
} 