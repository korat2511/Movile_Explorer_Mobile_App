import 'package:hive/hive.dart';

import 'movie_details.dart';

part 'viewed_movie.g.dart';

@HiveType(typeId: 1)
class ViewedMovie extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final String overview;

  @HiveField(4)
  final String releaseDate;

  @HiveField(5)
  final double voteAverage;

  @HiveField(6)
  final DateTime viewedAt;

  @HiveField(7)
  bool isFavorite;

  ViewedMovie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.viewedAt,
    this.isFavorite = false,
  });

  factory ViewedMovie.fromMovieDetails(MovieDetails movie) {
    return ViewedMovie(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      overview: movie.overview,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      viewedAt: DateTime.now(),
    );
  }
} 