import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TMDBAttribution extends StatelessWidget {
  const TMDBAttribution({super.key});

  Future<void> _launchTMDBWebsite() async {
    final Uri url = Uri.parse('https://www.themoviedb.org/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchTMDBWebsite,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Powered by',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Image.network(
              'https://www.themoviedb.org/assets/2/v4/logos/v2/blue_short-8e7b30f73a4020692ccca9c88bafe5dcb6f8a62a4c6bc55cd9ba82bb2cd95f6c.svg',
              height: 16,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'TMDB',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF01B4E4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 