import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_config.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../presentation/bloc/movie_details_bloc.dart';
import '../models/cast.dart';
import '../models/movie_details.dart';
import '../models/review.dart';
import '../models/video.dart';

class MovieRepositoryImpl implements MovieRepository {
  final Dio _dio;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  MovieRepositoryImpl() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      queryParameters: {'api_key': ApiConfig.apiKey},
      connectTimeout: const Duration(seconds: 30), // Increased timeout
      receiveTimeout: const Duration(seconds: 30),
      // Add headers to prevent rate limiting
      headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
      },
    );
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<T> _retryOnError<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == _maxRetries) rethrow;
        
        print('Attempt $attempts failed. Retrying in ${_retryDelay.inSeconds} seconds...');
        await Future.delayed(_retryDelay);
      }
    }
    throw Exception('All retry attempts failed');
  }

  @override
  Future<List<MovieDetails>> getNowPlayingMovies({int page = 1}) async {
    return _retryOnError(() async {
      try {
        print('Fetching Now Playing movies... Page: $page');
        final response = await _dio.get(ApiConfig.nowPlayingEndpoint, queryParameters: {'page': page});
        final movies = _parseMovieResponse(response.data);
        print('Got ${movies.length} Now Playing movies');
        return movies;
      } catch (e) {
        print('Error fetching Now Playing movies: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<List<MovieDetails>> getPopularMovies({int page = 1}) async {
    return _retryOnError(() async {
      try {
        print('Fetching Popular movies... Page: $page');
        final response = await _dio.get(ApiConfig.popularEndpoint, queryParameters: {'page': page});
        final movies = _parseMovieResponse(response.data);
        print('Got ${movies.length} Popular movies');
        return movies;
      } catch (e) {
        print('Error fetching Popular movies: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<List<MovieDetails>> getTopRatedMovies({int page = 1}) async {
    return _retryOnError(() async {
      try {
        print('Fetching Top Rated movies... Page: $page');
        final response = await _dio.get(ApiConfig.topRatedEndpoint, queryParameters: {'page': page});
        final movies = _parseMovieResponse(response.data);
        print('Got ${movies.length} Top Rated movies');
        return movies;
      } catch (e) {
        print('Error fetching Top Rated movies: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<List<MovieDetails>> getUpcomingMovies({int page = 1}) async {
    return _retryOnError(() async {
      try {
        print('Fetching Upcoming movies... Page: $page');
        final response = await _dio.get(ApiConfig.upcomingEndpoint, queryParameters: {'page': page});
        final movies = _parseMovieResponse(response.data);
        print('Got ${movies.length} Upcoming movies');
        return movies;
      } catch (e) {
        print('Error fetching Upcoming movies: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<List<MovieDetails>> searchMovies(String query, {int page = 1}) async {
    return _retryOnError(() async {
      try {
        print('Searching movies... Query: $query, Page: $page');
        final response = await _dio.get(
          ApiConfig.searchEndpoint,
          queryParameters: {
            'query': query,
            'page': page,
          },
        );
        final movies = _parseMovieResponse(response.data);
        print('Got ${movies.length} movies for search query: $query');
        return movies;
      } catch (e) {
        print('Error searching movies: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<MovieDetails> getMovieDetails(int movieId) async {
    return _retryOnError(() async {
      try {
        print('Fetching movie details for ID: $movieId');
        final response = await _dio.get(ApiConfig.getMovieDetailsEndpoint(movieId));
        return MovieDetails.fromJson(response.data);
      } catch (e) {
        print('Error fetching movie details: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<List<Cast>> getMovieCast(int movieId) async {
    return _retryOnError(() async {
      try {
        print('Fetching movie cast for ID: $movieId');
        final response = await _dio.get(ApiConfig.getMovieCreditsEndpoint(movieId));
        final castList = response.data['cast'] as List;
        return castList.map((cast) => Cast.fromJson(cast)).toList();
      } catch (e) {
        print('Error fetching movie cast: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<List<Review>> getMovieReviews(int movieId) async {
    return _retryOnError(() async {
      try {
        print('Fetching movie reviews for ID: $movieId');
        final response = await _dio.get(ApiConfig.getMovieReviewsEndpoint(movieId));
        final reviewsList = response.data['results'] as List;
        return reviewsList.map((review) => Review.fromJson(review)).toList();
      } catch (e) {
        print('Error fetching movie reviews: $e');
        throw _handleError(e);
      }
    });
  }

  @override
  Future<List<Video>> getMovieVideos(int movieId) async {
    return _retryOnError(() async {
      try {
        print('Fetching movie videos for ID: $movieId');
        final response = await _dio.get(ApiConfig.getMovieVideosEndpoint(movieId));
        final videosList = response.data['results'] as List;
        final videos = videosList.map((video) => Video.fromJson(video)).toList();
        
        // Filter for YouTube trailers and sort by official first
        return videos
          .where((video) => video.isYoutubeVideo && video.isTrailer)
          .toList()
          ..sort((a, b) {
            if (a.official != b.official) return a.official ? -1 : 1;
            return DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt));
          });
      } catch (e) {
        print('Error fetching movie videos: $e');
        throw _handleError(e);
      }
    });
  }

  List<MovieDetails> _parseMovieResponse(Map<String, dynamic> data) {
    try {
      final results = data['results'] as List;
      return results.map((movie) => MovieDetails.fromJson(movie)).toList();
    } catch (e) {
      print('Error parsing movie response: $e');
      print('Response data: $data');
      rethrow;
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      print('DioException: ${error.type} - ${error.message}');
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          print('Bad response: ${error.response?.data}');
          return Exception(
            'Server error (${error.response?.statusCode}). Please try again later.',
          );
        default:
          return Exception('Network error occurred. Please check your connection.');
      }
    }
    return Exception('Something went wrong. Please try again.');
  }
} 