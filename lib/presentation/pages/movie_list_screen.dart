import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/movie_repository_impl.dart';
import '../bloc/movie_list_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/movie_grid_item.dart';

class MovieListScreen extends StatelessWidget {
  final String title;
  final String category;

  const MovieListScreen({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieListBloc(
        repository: MovieRepositoryImpl(),
        category: category,
      )..add(LoadMovies()),
      child: MovieListContent(title: title),
    );
  }
}

class MovieListContent extends StatefulWidget {
  final String title;

  const MovieListContent({
    super.key,
    required this.title,
  });

  @override
  State<MovieListContent> createState() => _MovieListContentState();
}

class _MovieListContentState extends State<MovieListContent> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<MovieListBloc>().add(FilterMovies(query));
      } else {
        context.read<MovieListBloc>().add(ClearFilter());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.title}...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<MovieListBloc>().add(ClearFilter());
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  ),
                ),
                onChanged: _onSearchChanged,
              )
            : Text(widget.title),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: BlocBuilder<MovieListBloc, MovieListState>(
        builder: (context, state) {
          if (state.status == MovieListStatus.initial ||
              state.status == MovieListStatus.loading && state.movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MovieListStatus.error && state.movies.isEmpty) {
            return ErrorView(
              message: state.error ?? 'Failed to load movies',
              onRetry: () {
                context.read<MovieListBloc>().add(LoadMovies());
              },
              fullScreen: true,
            );
          }

          final displayMovies = state.isFiltering ? state.filteredMovies : state.movies;

          if (displayMovies.isEmpty && state.isFiltering) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No movies found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<MovieListBloc>().add(ClearFilter());
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Search'),
                  ),
                ],
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (!state.isFiltering &&
                  notification is ScrollEndNotification &&
                  notification.metrics.extentAfter == 0 &&
                  state.status != MovieListStatus.loading &&
                  !state.hasReachedEnd) {
                context.read<MovieListBloc>().add(LoadMoreMovies());
              }
              return true;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<MovieListBloc>().add(LoadMovies());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: displayMovies.length + (state.hasReachedEnd || state.isFiltering ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= displayMovies.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return MovieGridItem(movie: displayMovies[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
} 