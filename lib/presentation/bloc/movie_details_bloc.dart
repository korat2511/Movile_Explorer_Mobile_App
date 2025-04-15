import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cast.dart';
import '../../data/models/movie_details.dart';
import '../../data/models/review.dart';
import '../../data/services/local_storage_service.dart';
import '../../domain/repositories/movie_repository.dart';

enum MovieDetailsStatus { initial, loading, success, error }

// Events
abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadMovieDetails extends MovieDetailsEvent {}

class ToggleFavorite extends MovieDetailsEvent {}

// State
class MovieDetailsState extends Equatable {
  final List<Cast> cast;
  final MovieDetailsStatus status;
  final String? error;
  final bool isViewed;
  final bool isFavorite;
  final List<Review> reviews;

  const MovieDetailsState({
    this.cast = const [],
    this.status = MovieDetailsStatus.initial,
    this.error,
    this.isViewed = false,
    this.isFavorite = false,
    this.reviews = const [],
  });

  MovieDetailsState copyWith({
    List<Cast>? cast,
    MovieDetailsStatus? status,
    String? error,
    bool? isViewed,
    bool? isFavorite,
    List<Review>? reviews,
  }) {
    return MovieDetailsState(
      cast: cast ?? this.cast,
      status: status ?? this.status,
      error: error,
      isViewed: isViewed ?? this.isViewed,
      isFavorite: isFavorite ?? this.isFavorite,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  List<Object?> get props => [cast, status, error, isViewed, isFavorite, reviews];
}

// BLoC
class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final MovieRepository repository;
  final LocalStorageService storage;
  final MovieDetails movie;
  final int movieId;

  MovieDetailsBloc({
    required this.repository,
    required this.storage,
    required this.movie,
    required this.movieId,
  }) : super(MovieDetailsState(
          isViewed: storage.isMovieViewed(movieId),
          isFavorite: storage.isMovieLiked(movieId),
        )) {
    on<LoadMovieDetails>(_onLoadMovieDetails);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetails event,
    Emitter<MovieDetailsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MovieDetailsStatus.loading));
      final cast = await repository.getMovieCast(movieId);
      final reviews = await repository.getMovieReviews(movieId);
      emit(state.copyWith(
        status: MovieDetailsStatus.success,
        cast: cast,
        reviews: reviews,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieDetailsStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<MovieDetailsState> emit,
  ) async {
    await storage.toggleLike(
      movieId,
      movie.title,
      movie.overview,
      movie.releaseDate,
      movie.voteAverage,
      movie.posterPath,
      movie.backdropPath,
    );
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }
}
