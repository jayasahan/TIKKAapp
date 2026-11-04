import 'package:flutter/material.dart';

/// Shared Material theme configuration for the TIKKA application.
abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
  }
}
