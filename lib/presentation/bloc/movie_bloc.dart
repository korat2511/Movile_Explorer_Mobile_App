import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_details.dart';
import '../../domain/repositories/movie_repository.dart';

// Events
abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

class FetchNowPlayingMovies extends MovieEvent {}
class FetchPopularMovies extends MovieEvent {}
class FetchTopRatedMovies extends MovieEvent {}
class FetchUpcomingMovies extends MovieEvent {}

// Update MovieState to handle multiple categories
class MovieState extends Equatable {
  final Map<String, CategoryState> categories;

  const MovieState({
    required this.categories,
  });

  MovieState copyWith({
    Map<String, CategoryState>? categories,
  }) {
    return MovieState(
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object> get props => [categories];
}

// State for each category
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<MovieDetails> movies;

  const CategoryLoaded(this.movies);

  @override
  List<Object> get props => [movies];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository repository;

  MovieBloc({required this.repository}) : super(
    MovieState(categories: {
      'now_playing': CategoryInitial(),
      'popular': CategoryInitial(),
      'top_rated': CategoryInitial(),
      'upcoming': CategoryInitial(),
    }),
  ) {
    on<FetchNowPlayingMovies>(_onFetchNowPlayingMovies);
    on<FetchPopularMovies>(_onFetchPopularMovies);
    on<FetchTopRatedMovies>(_onFetchTopRatedMovies);
    on<FetchUpcomingMovies>(_onFetchUpcomingMovies);
  }

  void _updateCategory(String category, CategoryState newState, Emitter<MovieState> emit) {
    final updatedCategories = Map<String, CategoryState>.from(state.categories);
    updatedCategories[category] = newState;
    emit(state.copyWith(categories: updatedCategories));
  }

  Future<void> _onFetchNowPlayingMovies(
    FetchNowPlayingMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (state.categories['now_playing'] is! CategoryLoading) {
      _updateCategory('now_playing', CategoryLoading(), emit);
      try {
        final movies = await repository.getNowPlayingMovies();
        _updateCategory('now_playing', CategoryLoaded(movies), emit);
      } catch (e) {
        _updateCategory('now_playing', CategoryError(e.toString()), emit);
      }
    }
  }

  Future<void> _onFetchPopularMovies(
    FetchPopularMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (state.categories['popular'] is! CategoryLoading) {
      _updateCategory('popular', CategoryLoading(), emit);
      try {
        final movies = await repository.getPopularMovies();
        _updateCategory('popular', CategoryLoaded(movies), emit);
      } catch (e) {
        _updateCategory('popular', CategoryError(e.toString()), emit);
      }
    }
  }

  Future<void> _onFetchTopRatedMovies(
    FetchTopRatedMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (state.categories['top_rated'] is! CategoryLoading) {
      _updateCategory('top_rated', CategoryLoading(), emit);
      try {
        final movies = await repository.getTopRatedMovies();
        _updateCategory('top_rated', CategoryLoaded(movies), emit);
      } catch (e) {
        _updateCategory('top_rated', CategoryError(e.toString()), emit);
      }
    }
  }

  Future<void> _onFetchUpcomingMovies(
    FetchUpcomingMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (state.categories['upcoming'] is! CategoryLoading) {
      _updateCategory('upcoming', CategoryLoading(), emit);
      try {
        final movies = await repository.getUpcomingMovies();
        _updateCategory('upcoming', CategoryLoaded(movies), emit);
      } catch (e) {
        _updateCategory('upcoming', CategoryError(e.toString()), emit);
      }
    }
  }
} 