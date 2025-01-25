import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/navigation/navigation_service.dart';
import '../../data/services/theme_service.dart';
import '../bloc/movie_bloc.dart';
import '../pages/favorite_movies_screen.dart';
import '../pages/search_screen.dart';
import '../pages/viewed_movies_screen.dart';
import '../widgets/language_selector.dart';
import '../widgets/movie_list_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch movies when the page is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<MovieBloc>();
      bloc.add(FetchNowPlayingMovies());
      bloc.add(FetchPopularMovies());
      bloc.add(FetchTopRatedMovies());
      bloc.add(FetchUpcomingMovies());
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate('app_title')),

        actions: [
          InkWell(
            onTap: () {
              NavigationService.push(
                context,
                const SearchScreen(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                "assets/svg/search.svg",
                width: 25,
                height: 25,
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                AppLocalizations.of(context).translate('app_title'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(AppLocalizations.of(context).translate('search')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                NavigationService.push(
                  context,
                  const SearchScreen(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(AppLocalizations.of(context).translate('favorites')),
              onTap: () {
                Navigator.pop(context);
                NavigationService.push(
                  context,
                  const FavoriteMoviesScreen(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: Text(AppLocalizations.of(context).translate('viewed')),
              onTap: () {
                Navigator.pop(context);
                NavigationService.push(
                  context,
                  const ViewedMoviesScreen(),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: const LanguageSelector(),
              onTap: () {},
            ),
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return ListTile(
                  leading: Icon(
                    themeService.isLightMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: Text(
                    themeService.isLightMode ? 'Dark Mode' : 'Light Mode',
                  ),
                  onTap: () {
                    themeService.toggleTheme();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final bloc = context.read<MovieBloc>();
          bloc.add(FetchNowPlayingMovies());
          bloc.add(FetchPopularMovies());
          bloc.add(FetchTopRatedMovies());
          bloc.add(FetchUpcomingMovies());
        },
        child: ListView(
          children: const [
            MovieListSection(
              title: 'Now Playing',
              category: 'now_playing',
            ),
            MovieListSection(
              title: 'Popular',
              category: 'popular',
            ),
            MovieListSection(
              title: 'Top Rated',
              category: 'top_rated',
            ),
            MovieListSection(
              title: 'Upcoming',
              category: 'upcoming',
            ),
          ],
        ),
      ),
    );
  }
}
