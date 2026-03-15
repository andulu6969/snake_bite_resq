import 'package:flutter/material.dart';
import 'package:snake_bite_resq/screens/main_screen.dart';
import 'package:snake_bite_resq/screens/admin/admin_main_screen.dart';
import 'package:snake_bite_resq/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Creates a slow, breathing pulse effect for the bottom text
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation or min splash time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    // If AuthService is still loading (unlikely after 2s, but safe), wait for it?
    // For simplicity, we assume _loadAuthStatus completes fast.

    if (authService.isAuthenticated) {
      final destination = authService.isAdmin
          ? const AdminMainScreen()
          : const MainScreen();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => destination));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // InkWell captures the tap anywhere on the screen
        body: InkWell(
          onTap: _checkAuthAndNavigate,
          splashColor: Colors
              .transparent, // Hides the material splash ripple for a cleaner look
          highlightColor: Colors.transparent,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // --- LOGO SECTION ---
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                ),

                const SizedBox(height: 30),

                // --- APP NAME ---
                Text(
                  "SnakeBiteResQ", // All caps often looks more modern for headers
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold, // Bold for impact
                    color: Colors.blue.shade800, // Medical professional blue
                    letterSpacing: 2.0, // Wide spacing adds elegance
                  ),
                ),

                const SizedBox(height: 10),

                // Optional Tagline
                Text(
                  "Ministry of Health Malaysia",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.blueGrey.shade700,
                    letterSpacing: 1.0,
                  ),
                ),

                const Spacer(),

                // --- SUBTLE PULSING TEXT ---
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    "TAP SCREEN TO BEGIN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 60), // Space from bottom
              ],
            ),
          ), // SizedBox
        ), // InkWell
      ), // Scaffold
    ); // GradientBackground
  }
}
