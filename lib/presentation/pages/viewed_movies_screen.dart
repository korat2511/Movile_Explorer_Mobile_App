import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/movie_details.dart';
import '../widgets/movie_grid_item.dart';
import '../../data/services/local_storage_service.dart';

class ViewedMoviesScreen extends StatefulWidget {
  const ViewedMoviesScreen({super.key});

  @override
  _ViewedMoviesScreenState createState() => _ViewedMoviesScreenState();
}

class _ViewedMoviesScreenState extends State<ViewedMoviesScreen> {
  late List<MovieDetails> viewedMovies;

  @override
  void initState() {
    super.initState();
    final storage = context.read<LocalStorageService>();
    viewedMovies = storage.getViewedMovies().map((viewedMovie) {
      return MovieDetails(
        id: viewedMovie.id,
        title: viewedMovie.title,
        posterPath: viewedMovie.posterPath,
        overview: viewedMovie.overview,
        releaseDate: viewedMovie.releaseDate,
        voteAverage: viewedMovie.voteAverage,
        voteCount: 0,
        backdropPath: null,
        adult: true,
        genreIds: [],
        originalLanguage: '',
        originalTitle: '',
        popularity: 0.0,
        video: false,
      );
    }).toList();
  }

  void _clearViewedMovies() {
    final storage = context.read<LocalStorageService>();
    storage.clearViewedMovies();
    setState(() {
      viewedMovies = []; // Clear the list to update the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewed Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                      'Are you sure you want to clear your viewed movies history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearViewedMovies(); // Call the clear method
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: viewedMovies.isEmpty
          ? const Center(
              child: Text('No viewed movies yet'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: viewedMovies.length,
              itemBuilder: (context, index) {
                final movie = viewedMovies[index];
                return MovieGridItem(
                  movie: MovieDetails(
                    id: movie.id,
                    title: movie.title,
                    posterPath: movie.posterPath,
                    overview: movie.overview,
                    releaseDate: movie.releaseDate,
                    voteAverage: movie.voteAverage,
                    voteCount: 0,
                    backdropPath: null,
                    adult: true,
                    genreIds: [],
                    originalLanguage: '',
                    originalTitle: '',
                    popularity: 0.0,
                    video: false,
                  ),
                );
              },
            ),
    );
  }
}
