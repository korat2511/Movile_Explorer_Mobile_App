import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/local_storage_service.dart';

class LikeButton extends StatelessWidget {
  final int movieId;

  const LikeButton({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalStorageService>(
      builder: (context, storage, _) {
        final isFavorite = storage.isMovieFavorite(movieId);
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
            size: 20,
          ),
          onPressed: () => storage.toggleFavorite(movieId),
        );
      },
    );
  }
} 