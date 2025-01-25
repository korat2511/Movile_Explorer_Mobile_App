import 'package:flutter/material.dart';
import 'custom_page_transition.dart';

class NavigationService {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      CustomPageTransition(page: page),
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement(
      context,
      CustomPageTransition(page: page),
    );
  }
} 