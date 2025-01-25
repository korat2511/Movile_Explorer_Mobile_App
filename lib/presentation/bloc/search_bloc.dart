import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_details.dart';
import '../../domain/repositories/movie_repository.dart';

enum SearchStatus { initial, loading, success, error }

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchMovies extends SearchEvent {
  final String query;

  const SearchMovies(this.query);

  @override
  List<Object> get props => [query];
}

class LoadMoreSearchResults extends SearchEvent {
  final String query;

  const LoadMoreSearchResults(this.query);

  @override
  List<Object> get props => [query];
}

// State
class SearchState extends Equatable {
  final List<MovieDetails> movies;
  final SearchStatus status;
  final String? error;
  final bool hasReachedEnd;
  final int currentPage;

  const SearchState({
    this.movies = const [],
    this.status = SearchStatus.initial,
    this.error,
    this.hasReachedEnd = false,
    this.currentPage = 1,
  });

  SearchState copyWith({
    List<MovieDetails>? movies,
    SearchStatus? status,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    return SearchState(
      movies: movies ?? this.movies,
      status: status ?? this.status,
      error: error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [movies, status, error, hasReachedEnd, currentPage];
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MovieRepository repository;

  SearchBloc({required this.repository}) : super(const SearchState()) {
    on<SearchMovies>(_onSearchMovies);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final movies = await repository.searchMovies(event.query);
      emit(state.copyWith(
        status: SearchStatus.success,
        movies: movies,
        currentPage: 1,
        hasReachedEnd: movies.isEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    if (state.hasReachedEnd) return;

    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final nextPage = state.currentPage + 1;
      final moreMovies = await repository.searchMovies(
        event.query,
        page: nextPage,
      );

      if (moreMovies.isEmpty) {
        emit(state.copyWith(hasReachedEnd: true));
      } else {
        emit(state.copyWith(
          status: SearchStatus.success,
          movies: [...state.movies, ...moreMovies],
          currentPage: nextPage,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        error: e.toString(),
      ));
    }
  }
} 