import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/cast.dart';
import '../../data/models/movie_details.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../data/models/viewed_movie.dart';
import '../../data/services/local_storage_service.dart';

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

  const MovieDetailsState({
    this.cast = const [],
    this.status = MovieDetailsStatus.initial,
    this.error,
    this.isViewed = false,
    this.isFavorite = false,
  });

  MovieDetailsState copyWith({
    List<Cast>? cast,
    MovieDetailsStatus? status,
    String? error,
    bool? isViewed,
    bool? isFavorite,
  }) {
    return MovieDetailsState(
      cast: cast ?? this.cast,
      status: status ?? this.status,
      error: error,
      isViewed: isViewed ?? this.isViewed,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [cast, status, error, isViewed, isFavorite];
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
    emit(state.copyWith(status: MovieDetailsStatus.loading));
    try {
      // Add movie to viewed list automatically
      if (!state.isViewed) {
        await storage.addViewedMovie(ViewedMovie.fromMovieDetails(movie));
        emit(state.copyWith(isViewed: true));
      }

      final cast = await repository.getMovieCast(movieId);
      emit(state.copyWith(
        status: MovieDetailsStatus.success,
        cast: cast,
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
