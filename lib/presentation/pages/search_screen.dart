import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../widgets/movie_grid_item.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../widgets/error_view.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(repository: MovieRepositoryImpl()),
      child: const SearchContent(),
    );
  }
}

class SearchContent extends StatefulWidget {
  const SearchContent({super.key});

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final _searchController = TextEditingController();
  Timer? _debounce;

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
        context.read<SearchBloc>().add(SearchMovies(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return _buildSearchResults(context, state);
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchState state) {
    if (state.status == SearchStatus.initial) {
      return const Center(
        child: Text('Search for movies'),
      );
    }

    if (state.status == SearchStatus.loading && state.movies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SearchStatus.error) {
      return ErrorView(
        message: state.error ?? 'Failed to search movies',
        onRetry: () {
          final query = _searchController.text;
          if (query.isNotEmpty) {
            context.read<SearchBloc>().add(SearchMovies(query));
          }
        },
        fullScreen: true,
      );
    }

    if (state.movies.isEmpty) {
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
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter == 0 &&
            state.status != SearchStatus.loading &&
            !state.hasReachedEnd) {
          context.read<SearchBloc>().add(
              LoadMoreSearchResults(_searchController.text));
        }
        return true;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: state.movies.length + (state.hasReachedEnd ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.movies.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return MovieGridItem(movie: state.movies[index]);
        },
      ),
    );
  }
} 