import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/data/repositories/movie_repository_impl.dart';
import 'package:movie_explorer/presentation/bloc/movie_bloc.dart';
import 'package:movie_explorer/presentation/widgets/movie_list_section.dart';
import '../helpers/test_helpers.dart';

void main() {
  testWidgets('MovieListSection shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      TestHelpers.wrapWithProviders(
        BlocProvider(
          create: (context) => MovieBloc(repository: MovieRepositoryImpl()),
          child: const MovieListSection(
            title: 'Test Section',
            category: 'popular',
          ),
        ),
      ),
    );

    expect(find.text('Test Section'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('MovieListSection shows view more button', (WidgetTester tester) async {
    await tester.pumpWidget(
      TestHelpers.wrapWithProviders(
        BlocProvider(
          create: (context) => MovieBloc(repository: MovieRepositoryImpl()),
          child: const MovieListSection(
            title: 'Test Section',
            category: 'popular',
          ),
        ),
      ),
    );

    expect(find.text('View More'), findsOneWidget);
  });
} 