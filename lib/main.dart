import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // #1: Added GoogleFonts
import 'package:snake_bite_resq/screens/splash_screen.dart';

import 'package:provider/provider.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/providers/dashboard_provider.dart';

// --- FILE: lib/main.dart ---
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const SnakeBiteResQApp(),
    ),
  );
}

class SnakeBiteResQApp extends StatelessWidget {
  const SnakeBiteResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Base light theme
    final baseTheme = ThemeData.light();

    return MaterialApp(
      title: 'SnakeBiteResQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, // Switch to Light Mode
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade50, // Soft clinical off-white
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade700,
          brightness: Brightness.light,
          primary: Colors.blue.shade700, // Professional Medical Blue
          secondary: Colors.teal.shade600, // Keep a touch of teal as secondary
          error: const Color(0xFFD32F2F), // Standard error red
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blueGrey.shade900,
          elevation: 0,
          scrolledUnderElevation: 2, // Subtle shadow when scrolling
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            textStyle: TextStyle(
              color: Colors.blueGrey.shade900,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.blueGrey.shade900),
        ),
        // Apply global Google Font "Plus Jakarta Sans"
        textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme)
            .copyWith(
              bodyLarge: GoogleFonts.plusJakartaSans(
                color: Colors.blueGrey.shade900,
              ),
              bodyMedium: GoogleFonts.plusJakartaSans(
                color: Colors.blueGrey.shade700,
              ),
              titleLarge: GoogleFonts.plusJakartaSans(
                color: Colors.blueGrey.shade900,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              labelSmall: GoogleFonts.plusJakartaSans(
                letterSpacing: 1.2, // wide letter spacing for small caps labels
                color: Colors.blueGrey.shade600,
              ),
            ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.blueGrey.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            elevation: 4, // Softer shadow for light theme
            shadowColor: Colors.blue.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
