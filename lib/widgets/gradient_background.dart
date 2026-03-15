import 'dart:ui'; // #2: Added dart:ui for ImageFilter
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. BACKGROUND GRADIENT (Now a soft clinical white)
        Container(color: Colors.grey.shade50),

        // 2. DECORATIVE CIRCLES (Very soft subtle blue/teal depth)
        Positioned(
          top: -100,
          left: -100,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blue.shade700.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.teal.shade300.withValues(
                  alpha: 0.04,
                ), // Just a hint of teal
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        // 3. CONTENT
        SafeArea(child: child),
      ],
    );
  }
}
