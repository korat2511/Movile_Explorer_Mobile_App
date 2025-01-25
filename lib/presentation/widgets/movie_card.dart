import 'package:flutter/material.dart';
import '../../data/models/movie_details.dart';
import '../../presentation/pages/movie_details_screen.dart';
import '../../presentation/widgets/like_button.dart';
import '../../core/navigation/navigation_service.dart';
import '../../core/utils/responsive_layout.dart';

class MovieCard extends StatelessWidget {
  final MovieDetails movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveLayout.getCardWidth(context);
    final cardHeight = ResponsiveLayout.getPosterHeight(context);

    return GestureDetector(
      onTap: () {
        NavigationService.push(
          context,
          MovieDetailsScreen(movie: movie),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
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
                                size: cardWidth * 0.3,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: LikeButton(movieId: movie.id, movie: movie,),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: ResponsiveLayout.isTablet(context) ? 16 : 14,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 