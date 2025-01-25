import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/presentation/widgets/error_view.dart';
import '../helpers/test_helpers.dart';

void main() {
  testWidgets('ErrorView displays message and retry button', (WidgetTester tester) async {
    const errorMessage = 'Test error message';
    var retryPressed = false;

    await tester.pumpWidget(
      TestHelpers.wrapWithMaterialApp(
        ErrorView(
          message: errorMessage,
          onRetry: () => retryPressed = true,
          fullScreen: false,
        ),
      ),
    );

    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retryPressed, true);
  });

  testWidgets('ErrorView adjusts size based on fullScreen property', (WidgetTester tester) async {
    await tester.pumpWidget(
      TestHelpers.wrapWithMaterialApp(
        ErrorView(
          message: 'Error',
          onRetry: () {},
          fullScreen: true,
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 64.0);
  });
} 