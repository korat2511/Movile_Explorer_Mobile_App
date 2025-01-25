import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/navigation_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../data/models/movie_details.dart';
import '../bloc/movie_bloc.dart';
import '../pages/movie_list_screen.dart';
import 'error_view.dart';
import 'movie_card.dart';

class MovieListSection extends StatelessWidget {
  final String title;
  final String category;

  const MovieListSection({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _navigateToMovieList(context),
                    child: const Text('View More'),
                  ),
                  BlocBuilder<MovieBloc, MovieState>(
                    builder: (context, state) {
                      final categoryState = state.categories[category];
                      if (categoryState is CategoryError) {
                        return IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => _refreshSection(context),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: SizedBox(
            height: 200,
            child: BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                final categoryState = state.categories[category];

                if (categoryState is CategoryLoading) {
                  return _buildLoadingIndicator();
                }

                if (categoryState is CategoryLoaded) {
                  if (categoryState.movies.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildMovieList(categoryState.movies);
                }

                if (categoryState is CategoryError) {
                  return _buildErrorState(context, categoryState.message);
                }

                return _buildLoadingIndicator();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ResponsiveLayout.getCardWidth(context);
        final cardHeight = ResponsiveLayout.getPosterHeight(context);

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: cardWidth * 0.8,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No movies available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return SizedBox(
      height: ResponsiveLayout.getPosterHeight(context) + 40,
      child: ErrorView(
        message: message,
        onRetry: () => _refreshSection(context),
        fullScreen: false,
      ),
    );
  }

  Widget _buildMovieList(List<MovieDetails> movies) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ResponsiveLayout.getCardWidth(context);
        final cardHeight = ResponsiveLayout.getPosterHeight(context);

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: MovieCard(movie: movie),
            );
          },
        );
      },
    );
  }

  void _refreshSection(BuildContext context) {
    switch (category) {
      case 'now_playing':
        context.read<MovieBloc>().add(FetchNowPlayingMovies());
        break;
      case 'popular':
        context.read<MovieBloc>().add(FetchPopularMovies());
        break;
      case 'top_rated':
        context.read<MovieBloc>().add(FetchTopRatedMovies());
        break;
      case 'upcoming':
        context.read<MovieBloc>().add(FetchUpcomingMovies());
        break;
    }
  }

  void _navigateToMovieList(BuildContext context) {
    NavigationService.push(
      context,
      MovieListScreen(
        title: title,
        category: category,
      ),
    );
  }
} 