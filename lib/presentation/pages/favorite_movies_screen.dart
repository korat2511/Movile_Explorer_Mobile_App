import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/responsive_layout.dart';
import '../../data/models/movie_details.dart';
import '../../data/services/local_storage_service.dart';
import '../widgets/movie_grid_item.dart';

class FavoriteMoviesScreen extends StatelessWidget {

  const FavoriteMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Movies'),
      ),
      body: Consumer<LocalStorageService>(
        builder: (context, storage, child) {
          final favoriteMovies = storage.getLikedMovies();

          if (favoriteMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite movies yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add movies to your favorites to see them here',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: ResponsiveLayout.getScreenPadding(context),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  ResponsiveLayout.getGridCrossAxisCount(context).toInt(),
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
              return Stack(
                children: [
                  MovieGridItem(
                    movie: MovieDetails(
                      id: movie.id,
                      title: movie.title,
                      posterPath: movie.posterPath,
                      overview: movie.overview,
                      releaseDate: movie.releaseDate,
                      voteAverage: movie.voteAverage,

                      voteCount: 0,
                      backdropPath: movie.backdropPath,
                      adult: false,
                      genreIds: [],
                      originalLanguage: '',
                      originalTitle: '',
                      popularity: 0.0,
                      video: false,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          storage.toggleLike(
                            movie.id,
                            movie.title,
                            movie.overview,
                            movie.releaseDate,
                            movie.voteAverage,
                            movie.posterPath,
                            movie.backdropPath,
                          );
                          // Show a snackbar to confirm removal
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${movie.title} removed from favorites'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => storage.toggleLike(
                                  movie.id,
                                  movie.title,
                                  movie.overview,
                                  movie.releaseDate,
                                  movie.voteAverage,
                                  movie.posterPath,
                                  movie.backdropPath,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
