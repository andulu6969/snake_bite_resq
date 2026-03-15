import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:snake_bite_resq/screens/diagnosis_page.dart';
import 'package:snake_bite_resq/screens/education_page.dart';
import 'package:snake_bite_resq/screens/home_page.dart';

import 'package:snake_bite_resq/widgets/gradient_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // The pages
  final List<Widget> _pages = const <Widget>[
    HomePage(),
    DiagnosisPage(), // Index 1 (Middle)
    EducationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Transparent Scaffold Background to show Gradient if placed here (or handled by body)
      // Actually, we want the GradientBackground to BE the body.
      backgroundColor: Colors.transparent, // Important!
      // 2. extendBody: true makes the nav bar float over the content.
      extendBody: true,

      body: GradientBackground(child: _pages[_selectedIndex]),

      // --- CURVED NAVIGATION BAR ---
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 65.0,

        color: Colors.white,
        buttonBackgroundColor: Colors.blue.shade700,
        backgroundColor: Colors.transparent,

        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 350),

        items: <Widget>[
          _navItem(Icons.grid_view_rounded, 'Dashboard', _selectedIndex == 0),
          _navItem(
            Icons.monitor_heart_outlined,
            'Diagnose',
            _selectedIndex == 1,
          ),
          _navItem(Icons.menu_book_rounded, 'Resources', _selectedIndex == 2),
        ],

        onTap: (index) => setState(() => _selectedIndex = index),
        letIndexChange: (index) => true,
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? Colors.white : Colors.blueGrey.shade400,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isActive ? Colors.white : Colors.blueGrey.shade400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
