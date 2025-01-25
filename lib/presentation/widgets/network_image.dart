import 'package:flutter/material.dart';

class NetworkImageWithLoading extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const NetworkImageWithLoading({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: errorBuilder ??
          (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                width: width,
                height: height,
                color: Theme.of(context).colorScheme.surface,
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).colorScheme.error,
                  size: (width ?? 24) * 0.5,
                ),
              ),
    );
  }
} 