# Movie Explorer

## Overview
Movie Explorer is a Flutter application that fetches data from The Movie Database (TMDB) API, allowing users to discover, search, and manage their favorite movies. The app supports multiple languages and features a responsive design for both mobile and tablet devices.

## Setup Instructions

### Prerequisites
- Flutter SDK (version 3.5.4 or higher)
- Dart SDK
- An IDE (e.g., Android Studio, Visual Studio Code)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/movie_explorer.git
   cd movie_explorer
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Add your TMDB API key:**
    - Create a file named `constants.dart` in `lib/config/` and add your API key:
   ```dart
   const String apiKey = 'YOUR_TMDB_API_KEY';
   ```

## Architecture Overview
The application follows a clean architecture pattern, separating concerns into different layers:

- **Presentation Layer**: Contains UI components and screens, utilizing Flutter's widget system.
- **Domain Layer**: Contains business logic and use cases, ensuring that the app's core functionality is independent of the UI.
- **Data Layer**: Manages data sources, including local storage (using Hive) and remote API calls (using Dio).

## List of Implemented Features
- Browse popular, top-rated, and upcoming movies.
- Search for movies.
- View movie details, including cast and overview.
- Save favorite movies and manage viewed history.
- Multi-language support (English and Hindi).
- Responsive layout for phones and tablets.
- Dark and light theme support.

## Assumptions and Trade-offs
- The app assumes a stable internet connection for fetching movie data.
- Local storage is used for caching viewed movies, which may lead to data persistence issues if not managed properly.
- The choice of Hive for local storage is based on its performance and ease of use, but it may not be suitable for very large datasets.

## Future Improvements
- Implement user authentication to allow users to save their preferences and favorites across devices.
- Add more languages for broader accessibility.
- Enhance error handling and user feedback for network requests.
- Implement unit and widget tests for better code coverage and reliability.
- Optimize performance for larger datasets and improve loading times.


## Acknowledgments
- [The Movie Database (TMDB)](https://www.themoviedb.org/) for providing the movie data API.
- Flutter community for their extensive documentation and support.