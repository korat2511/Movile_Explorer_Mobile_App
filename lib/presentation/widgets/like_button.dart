import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/movie_details.dart';
import '../../data/services/local_storage_service.dart';

class LikeButton extends StatelessWidget {
  final int movieId;
  final MovieDetails movie;

  const LikeButton({
    super.key,
    required this.movieId, required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalStorageService>(
      builder: (context, storage, _) {
        final isFavorite = storage.isMovieLiked(movieId);
        return IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
              size: 20,
            ),
            onPressed: () async {
              await storage.toggleLike(
                movieId,
                movie.title,
                movie.overview,
                movie.releaseDate,
                movie.voteAverage,
                movie.posterPath,
                movie.backdropPath,
              );
            });
      },
    );
  }
}
