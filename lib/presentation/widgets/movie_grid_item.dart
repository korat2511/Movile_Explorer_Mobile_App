import 'package:flutter/material.dart';
import '../../data/models/movie_details.dart';
import '../../core/utils/responsive_layout.dart';

class MovieGridItem extends StatelessWidget {
  final MovieDetails movie;

  const MovieGridItem({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final posterHeight = constraints.maxWidth * 1.5;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: 'movie_poster_grid_${movie.id}',
                  child: movie.posterPath != null
                      ? Image.network(
                          movie.fullPosterPath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.movie,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: posterHeight * 0.3,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: ResponsiveLayout.isTablet(context) ? 16 : 14,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 