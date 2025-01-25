import 'package:flutter/material.dart';
import '../../core/utils/responsive_layout.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool fullScreen;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final padding = ResponsiveLayout.getScreenPadding(context);
    final iconSize = fullScreen ? (isTablet ? 96.0 : 64.0) : (isTablet ? 64.0 : 48.0);

    final errorWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: iconSize,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Container(
          constraints: BoxConstraints(maxWidth: isTablet ? 400 : 300),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: isTablet ? 18 : 16,
                ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(
            'Retry',
            style: TextStyle(fontSize: isTablet ? 16 : 14),
          ),
        ),
      ],
    );

    if (fullScreen) {
      return Center(
        child: Padding(
          padding: padding,
          child: errorWidget,
        ),
      );
    }

    return Container(
      padding: padding,
      child: Center(child: errorWidget),
    );
  }
} 