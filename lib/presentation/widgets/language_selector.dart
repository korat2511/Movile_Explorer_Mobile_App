import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String languageCode) {
        context.read<LanguageService>().setLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        const PopupMenuItem(
          value: 'hi',
          child: Text('हिंदी'),
        ),
      ],
    );
  }
} 