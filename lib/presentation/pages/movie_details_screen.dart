import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movie_details_bloc.dart';
import '../../data/models/movie_details.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../presentation/widgets/error_view.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieDetails movie;
  final bool fromGrid;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    this.fromGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailsBloc(
        repository: MovieRepositoryImpl(),
        storage: context.read<LocalStorageService>(),
        movie: movie,
        movieId: movie.id,
      )..add(LoadMovieDetails()),
      child: MovieDetailsContent(movie: movie, fromGrid: fromGrid),
    );
  }
}

class MovieDetailsContent extends StatelessWidget {
  final MovieDetails movie;
  final bool fromGrid;

  const MovieDetailsContent({
    super.key,
    required this.movie,
    required this.fromGrid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieInfo(context),
                  const SizedBox(height: 16),
                  _buildOverview(),
                  const SizedBox(height: 24),
                  _buildCastSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      actions: [
        BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
          builder: (context, state) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: IconButton(
                icon: Icon(
                  state.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: state.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  context.read<MovieDetailsBloc>().add(ToggleFavorite());
                },
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(movie.title),
        background: movie.backdropPath != null
            ? Image.network(
                movie.fullBackdropPath!,
                fit: BoxFit.cover,
              )
            : Container(color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildMovieInfo(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final posterWidth = isTablet ? 180.0 : 120.0;
    final posterHeight = isTablet ? 270.0 : 180.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Hero(
            tag: fromGrid
                ? 'movie_poster_grid_${movie.id}'
                : 'movie_poster_list_${movie.id}',
            child: SizedBox(
              width: posterWidth,
              height: posterHeight,
              child: movie.posterPath != null
                  ? Image.network(
                      movie.fullPosterPath!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        Icons.movie,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: posterWidth * 0.4,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: isTablet ? 28 : 24,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Release Date: ${movie.releaseDate}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    ' (${movie.voteCount} votes)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(movie.overview),
      ],
    );
  }

  Widget _buildCastSection() {
    return BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
      builder: (context, state) {
        if (state.status == MovieDetailsStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == MovieDetailsStatus.error) {
          return ErrorView(
            message: 'Failed to load cast information\n${state.error}',
            onRetry: () {
              context.read<MovieDetailsBloc>().add(LoadMovieDetails());
            },
          );
        }

        if (state.cast.isEmpty) {
          return const SizedBox.shrink();
        }

        final isTablet = ResponsiveLayout.isTablet(context);
        final itemWidth = isTablet ? 120.0 : 80.0;
        final itemHeight = isTablet ? 180.0 : 120.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cast',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: itemHeight + 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.cast.length,
                itemBuilder: (context, index) {
                  final cast = state.cast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: itemWidth,
                            height: itemHeight,
                            child: cast.profilePath != null
                                ? Image.network(
                                    cast.fullProfilePath!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: itemWidth * 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: itemWidth,
                          child: Text(
                            cast.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: isTablet ? 14 : 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
} 