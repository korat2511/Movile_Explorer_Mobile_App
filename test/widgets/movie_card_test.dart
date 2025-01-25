import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/presentation/widgets/movie_card.dart';
import '../helpers/test_helpers.dart';

void main() {
  testWidgets('MovieCard displays movie title and poster', (WidgetTester tester) async {
    final testMovie = TestHelpers.createTestMovie();

    await tester.pumpWidget(
      TestHelpers.wrapWithProviders(
        MovieCard(movie: testMovie),
      ),
    );

    expect(find.text(testMovie.title), findsOneWidget);
    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets('MovieCard shows placeholder when no poster', (WidgetTester tester) async {
    final testMovie = TestHelpers.createTestMovie().copyWith(posterPath: null);

    await tester.pumpWidget(
      TestHelpers.wrapWithProviders(
        MovieCard(movie: testMovie),
      ),
    );

    expect(find.byIcon(Icons.movie), findsOneWidget);
  });

  testWidgets('MovieCard has like button', (WidgetTester tester) async {
    final testMovie = TestHelpers.createTestMovie();

    await tester.pumpWidget(
      TestHelpers.wrapWithProviders(
        MovieCard(movie: testMovie),
      ),
    );

    expect(find.byType(IconButton), findsOneWidget);
  });
} 