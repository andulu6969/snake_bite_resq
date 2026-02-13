import 'package:flutter/material.dart';
import 'package:snake_bite_resq/screens/splash_screen.dart';

// --- FILE: lib/main.dart ---
void main() {
  runApp(const SnakeBiteResQApp());
}

class SnakeBiteResQApp extends StatelessWidget {
  const SnakeBiteResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeBiteResQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
