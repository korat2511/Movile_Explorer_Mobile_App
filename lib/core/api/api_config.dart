class ApiConfig {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '2bd69ebec02df630a66161f2c71068c5';
  
  // API Endpoints
  static const String nowPlayingEndpoint = '/movie/now_playing';
  static const String popularEndpoint = '/movie/popular';
  static const String topRatedEndpoint = '/movie/top_rated';
  static const String upcomingEndpoint = '/movie/upcoming';
  static const String searchEndpoint = '/search/movie';
  
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';
  
  static String getImageUrl(String path, {ImageSize size = ImageSize.original}) {
    return '$imageBaseUrl${size.value}$path';
  }

  static String getMovieDetailsEndpoint(int movieId) => '/movie/$movieId';
  static String getMovieCreditsEndpoint(int movieId) => '/movie/$movieId/credits';
  static String getMovieReviewsEndpoint(int movieId) => '/movie/$movieId/reviews';
}

enum ImageSize {
  w200('w200'),
  w500('w500'),
  original('original');

  final String value;
  const ImageSize(this.value);
} 