import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_details.dart';
import '../../domain/repositories/movie_repository.dart';

enum MovieListStatus { initial, loading, success, error }

// Events
abstract class MovieListEvent extends Equatable {
  const MovieListEvent();

  @override
  List<Object> get props => [];
}

class LoadMovies extends MovieListEvent {}
class LoadMoreMovies extends MovieListEvent {}
class FilterMovies extends MovieListEvent {
  final String query;

  const FilterMovies(this.query);

  @override
  List<Object> get props => [query];
}
class ClearFilter extends MovieListEvent {}

// State
class MovieListState extends Equatable {
  final List<MovieDetails> movies;
  final List<MovieDetails> filteredMovies;
  final bool isFiltering;
  final MovieListStatus status;
  final String? error;
  final bool hasReachedEnd;
  final int currentPage;

  const MovieListState({
    this.movies = const [],
    this.filteredMovies = const [],
    this.isFiltering = false,
    this.status = MovieListStatus.initial,
    this.error,
    this.hasReachedEnd = false,
    this.currentPage = 1,
  });

  MovieListState copyWith({
    List<MovieDetails>? movies,
    List<MovieDetails>? filteredMovies,
    bool? isFiltering,
    MovieListStatus? status,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      filteredMovies: filteredMovies ?? this.filteredMovies,
      isFiltering: isFiltering ?? this.isFiltering,
      status: status ?? this.status,
      error: error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [movies, filteredMovies, isFiltering, status, error, hasReachedEnd, currentPage];
}

// BLoC
class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final MovieRepository repository;
  final String category;

  MovieListBloc({
    required this.repository,
    required this.category,
  }) : super(const MovieListState()) {
    on<LoadMovies>(_onLoadMovies);
    on<LoadMoreMovies>(_onLoadMoreMovies);
    on<FilterMovies>(_onFilterMovies);
    on<ClearFilter>(_onClearFilter);
  }

  Future<void> _onLoadMovies(
    LoadMovies event,
    Emitter<MovieListState> emit,
  ) async {
    emit(state.copyWith(status: MovieListStatus.loading));
    try {
      final movies = await _fetchMovies(1);
      emit(state.copyWith(
        status: MovieListStatus.success,
        movies: movies,
        currentPage: 1,
        hasReachedEnd: movies.isEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieListStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMovies event,
    Emitter<MovieListState> emit,
  ) async {
    if (state.hasReachedEnd) return;

    emit(state.copyWith(status: MovieListStatus.loading));
    try {
      final nextPage = state.currentPage + 1;
      final moreMovies = await _fetchMovies(nextPage);
      
      if (moreMovies.isEmpty) {
        emit(state.copyWith(hasReachedEnd: true));
      } else {
        emit(state.copyWith(
          status: MovieListStatus.success,
          movies: [...state.movies, ...moreMovies],
          currentPage: nextPage,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: MovieListStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _onFilterMovies(
    FilterMovies event,
    Emitter<MovieListState> emit,
  ) {
    final query = event.query.toLowerCase();
    final filteredMovies = state.movies.where((movie) {
      return movie.title.toLowerCase().contains(query) ||
          movie.overview.toLowerCase().contains(query);
    }).toList();

    emit(state.copyWith(
      filteredMovies: filteredMovies,
      isFiltering: true,
    ));
  }

  void _onClearFilter(
    ClearFilter event,
    Emitter<MovieListState> emit,
  ) {
    emit(state.copyWith(
      filteredMovies: const [],
      isFiltering: false,
    ));
  }

  Future<List<MovieDetails>> _fetchMovies(int page) async {
    switch (category) {
      case 'now_playing':
        return repository.getNowPlayingMovies(page: page);
      case 'popular':
        return repository.getPopularMovies(page: page);
      case 'top_rated':
        return repository.getTopRatedMovies(page: page);
      case 'upcoming':
        return repository.getUpcomingMovies(page: page);
      default:
        throw Exception('Unknown category: $category');
    }
  }
} 