import 'package:flutter/material.dart';
import 'package:snake_bite_resq/screens/main_screen.dart';

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

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // InkWell captures the tap anywhere on the screen
      body: InkWell(
        onTap: _navigateToHome,
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
              const Text(
                "SnakeBiteResQ", // All caps often looks more modern for headers
                style: TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.w300, // Light font weight is very modern
                  color: Colors.black87,
                  letterSpacing: 3.0, // Wide spacing adds elegance
                ),
              ),

              const SizedBox(height: 10),

              // Optional Tagline
              Text(
                "Ministry of Health Malaysia",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[500],
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
                    color: Colors.teal[300],
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 60), // Space from bottom
            ],
          ),
        ),
      ),
    );
  }
}
