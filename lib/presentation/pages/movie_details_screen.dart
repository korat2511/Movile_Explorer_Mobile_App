import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import '../pages/video_player_screen.dart';
import '../bloc/movie_details_bloc.dart';
import '../../data/models/movie_details.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/api/api_config.dart';
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
                  const SizedBox(height: 24),
                  _buildReviewsSection(),
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
            if (state.status == MovieDetailsStatus.success && state.videos.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () => _launchTrailer(context, state.videos.first.key),
                tooltip: 'Play Trailer',
              );
            }
            return const SizedBox.shrink();
          },
        ),
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
      flexibleSpace: Stack(
        children: [
          FlexibleSpaceBar(
            title: Text(movie.title),
            background: movie.backdropPath != null
                ? Image.network(
                    movie.fullBackdropPath!,
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[800]),
          ),
          BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
            builder: (context, state) {
              if (state.status == MovieDetailsStatus.success && state.videos.isNotEmpty) {
                return Positioned.fill(
                  child: Center(
                    child: IconButton(
                      iconSize: 64,
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                      ),
                      onPressed: () => _launchTrailer(context, state.videos.first.key),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchTrailer(BuildContext context, String videoKey) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoKey: videoKey,
          title: movie.title,
        ),
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
        const Text(
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

  Widget _buildReviewsSection() {
    return BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
      builder: (context, state) {
        if (state.status == MovieDetailsStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == MovieDetailsStatus.error) {
          return ErrorView(
            message: 'Failed to load reviews\n${state.error}',
            onRetry: () {
              context.read<MovieDetailsBloc>().add(LoadMovieDetails());
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: ResponsiveLayout.isTablet(context) ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.reviews.isNotEmpty)
                  Text(
                    '${state.reviews.length} Reviews',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.reviews.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No reviews available yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.reviews.length,
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final review = state.reviews[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: review.fullAvatarPath != null
                                ? Image.network(
                                    review.fullAvatarPath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildAvatarFallback(context, review.author);
                                    },
                                  )
                                : _buildAvatarFallback(context, review.author),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'A review by ${review.author}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (review.rating != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${(review.rating! * 10).toInt()}%',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (review.createdAt != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Written ${review.formattedDate}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ReadMoreText(
                        review.content,
                        trimLines: 5,
                        colorClickableText: Theme.of(context).colorScheme.primary,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Read more',
                        trimExpandedText: 'Show less',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                        ),
                        moreStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        lessStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom,)
          ],
        );
      },
    );
  }

  Widget _buildAvatarFallback(BuildContext context, String author) => Container(
    color: Theme.of(context).colorScheme.primary,
    child: Center(
      child: Text(
        author[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  );
} 