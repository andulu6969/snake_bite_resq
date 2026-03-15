import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/screens/login_screen.dart';
import 'package:snake_bite_resq/screens/admin/admin_overview_page.dart';
import 'package:snake_bite_resq/screens/admin/admin_hospitals_page.dart';
import 'package:snake_bite_resq/screens/admin/admin_analytics_page.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const <Widget>[
    AdminOverviewPage(),
    AdminHospitalsPage(),
    AdminAnalyticsPage(),
  ];

  void _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: GradientBackground(
        child: Stack(
          children: [
            _pages[_selectedIndex],
            // Floating logout button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _handleLogout,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 65.0,
        color: Colors.white,
        buttonBackgroundColor: Colors.indigo.shade600,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 350),
        items: <Widget>[
          _navItem(Icons.dashboard_rounded, 'Overview', _selectedIndex == 0),
          _navItem(
            Icons.local_hospital_rounded,
            'Hospitals',
            _selectedIndex == 1,
          ),
          _navItem(Icons.insights_rounded, 'Analytics', _selectedIndex == 2),
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
