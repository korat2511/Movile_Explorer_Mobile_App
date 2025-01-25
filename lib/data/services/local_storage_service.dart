import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/viewed_movie.dart';

class LocalStorageService extends ChangeNotifier {
  static const String _viewedMoviesBox = 'viewed_movies';
  static const String _likedMoviesBox = 'liked_movies';
  late Box<ViewedMovie> _viewedBox;
  late Box<ViewedMovie> _likedBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ViewedMovieAdapter());
    _viewedBox = await Hive.openBox<ViewedMovie>(_viewedMoviesBox);
    _likedBox = await Hive.openBox<ViewedMovie>(_likedMoviesBox);
  }

  Future<void> addViewedMovie(ViewedMovie movie) async {
    await _viewedBox.put(movie.id, movie);
  }

  Future<void> removeViewedMovie(int movieId) async {
    await _viewedBox.delete(movieId);
  }

  List<ViewedMovie> getViewedMovies() {
    return _viewedBox.values.toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  List<ViewedMovie> getLikedMovies() {
    return _likedBox.values.where((movie) => movie.isFavorite).toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  bool isMovieViewed(int movieId) {
    return _viewedBox.containsKey(movieId);
  }

  bool isMovieLiked(int movieId) {
    final movie = _likedBox.get(movieId);

    return movie?.isFavorite ?? false;
  }

  Future<void> toggleLike(int movieId, title, overview, releaseDate, voteAverage, posterPath, backdropPath) async {
    log("MID == $movieId");
    final movie = _likedBox.get(movieId);

    if (movie != null) {
      movie.isFavorite = !movie.isFavorite;
      await _likedBox.put(movieId, movie);
    } else {
      final newMovie = ViewedMovie(
        id: movieId,
        isFavorite: true,
        title: title,
        overview: overview,
        releaseDate: releaseDate,
        voteAverage: voteAverage,
        posterPath: posterPath,
        backdropPath: backdropPath,
        viewedAt: DateTime.timestamp(),
      );
      await _likedBox.put(movieId, newMovie);
    }
    notifyListeners();
  }

  Future<void> clearViewedMovies() async {
    await _viewedBox.clear();
  }

  Future<void> clearLikedMovies() async {
    await _likedBox.clear();
  }
}
