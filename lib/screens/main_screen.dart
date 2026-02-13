import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:snake_bite_resq/screens/diagnosis_page.dart';
import 'package:snake_bite_resq/screens/education_page.dart';
import 'package:snake_bite_resq/screens/home_page.dart';

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
      // 1. Set the background color of the SCAFFOLD to match your pages.
      // This prevents white flashes during transitions.
      backgroundColor: Colors.grey[50],

      // 2. extendBody: true makes the nav bar float over the content.
      // We will fix the "transparency" issue by setting the nav bar's background color manually below.
      extendBody: true,

      body: _pages[_selectedIndex],

      // --- CURVED NAVIGATION BAR ---
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,

        // --- KEY FIX: MATCHING COLORS ---
        // 'color': The color of the bar itself (White).
        color: Colors.white,

        // 'buttonBackgroundColor': The floating bubble (Teal).
        buttonBackgroundColor: Colors.teal,

        // 'backgroundColor': The color BEHIND the curve.
        // CHANGED from transparent to Colors.grey[50].
        // This hides the scrolling text behind the bar while keeping the curve effect!
        backgroundColor: Colors.grey.shade50,

        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 350),

        items: <Widget>[
          // ICON 1: Dashboard
          Icon(
            Icons.grid_view_rounded,
            size: 28,
            color: _selectedIndex == 0 ? Colors.white : Colors.grey.shade400,
          ),

          // ICON 2: Diagnose (Middle)
          Icon(
            Icons.monitor_heart_outlined,
            size: 28,
            color: _selectedIndex == 1 ? Colors.white : Colors.grey.shade400,
          ),

          // ICON 3: Education
          Icon(
            Icons.menu_book_rounded,
            size: 28,
            color: _selectedIndex == 2 ? Colors.white : Colors.grey.shade400,
          ),
        ],

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
