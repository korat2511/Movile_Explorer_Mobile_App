import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/presentation/widgets/network_image.dart';
import '../helpers/test_helpers.dart';

void main() {
  testWidgets('NetworkImageWithLoading shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      TestHelpers.wrapWithMaterialApp(
        const NetworkImageWithLoading(
          imageUrl: 'https://example.com/image.jpg',
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('NetworkImageWithLoading shows error icon on failure', (WidgetTester tester) async {
    await tester.pumpWidget(
      TestHelpers.wrapWithMaterialApp(
        const NetworkImageWithLoading(
          imageUrl: 'invalid-url',
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
} 