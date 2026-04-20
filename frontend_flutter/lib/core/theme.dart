import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF0F766E);

  final base = ThemeData(
    colorScheme:
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF3F6F8),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
