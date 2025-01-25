import '../../data/models/movie_details.dart';
import '../../data/models/cast.dart';

abstract class MovieRepository {
  Future<List<MovieDetails>> getNowPlayingMovies({int page = 1});
  Future<List<MovieDetails>> getPopularMovies({int page = 1});
  Future<List<MovieDetails>> getTopRatedMovies({int page = 1});
  Future<List<MovieDetails>> getUpcomingMovies({int page = 1});
  Future<List<MovieDetails>> searchMovies(String query, {int page = 1});
  Future<MovieDetails> getMovieDetails(int movieId);
  Future<List<Cast>> getMovieCast(int movieId);
} 