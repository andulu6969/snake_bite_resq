import 'package:flutter/material.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isMonthly = true;
  bool _isLoading = true;

  Map<String, dynamic> _statsMonthly = {
    "ICU": 0,
    "Ward": 0,
    "Observation": 0,
    "Discharge": 0,
    "total": 0,
  };

  Map<String, dynamic> _statsYearly = {
    "ICU": 0,
    "Ward": 0,
    "Observation": 0,
    "Discharge": 0,
    "total": 0,
  };

  Map<String, dynamic>? _recentPatient;

  // Getters
  bool get isMonthly => _isMonthly;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get stats => _isMonthly ? _statsMonthly : _statsYearly;
  Map<String, dynamic>? get recentPatient => _recentPatient;

  DashboardProvider() {
    loadDashboardData();
  }

  void toggleTimeFilter(String filter) {
    if (filter == "Monthly" && !_isMonthly) {
      _isMonthly = true;
      notifyListeners(); // Instant UI update with cached data
      _loadBackgroundData(); // Load new data in background
    } else if (filter == "Yearly" && _isMonthly) {
      _isMonthly = false;
      notifyListeners(); // Instant UI update with cached data
      _loadBackgroundData(); // Load new data in background
    }
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final unitId = prefs.getString('unitId') ?? '';

      // Load both monthly AND yearly data in parallel
      final results = await Future.wait([
        ApiService.getDashboardStats(filter: "monthly", unitId: unitId),
        ApiService.getDashboardStats(filter: "yearly", unitId: unitId),
        ApiService.getRecentPatient(unitId: unitId),
      ]);

      _statsMonthly = Map<String, dynamic>.from(results[0] as Map);
      _statsYearly = Map<String, dynamic>.from(results[1] as Map);
      _recentPatient = results[2] == null
          ? null
          : Map<String, dynamic>.from(results[2] as Map);
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Background refresh without blocking UI
  Future<void> _loadBackgroundData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unitId = prefs.getString('unitId') ?? '';

      final results = await Future.wait([
        ApiService.getDashboardStats(filter: "monthly", unitId: unitId),
        ApiService.getDashboardStats(filter: "yearly", unitId: unitId),
      ]);

      _statsMonthly = Map<String, dynamic>.from(results[0] as Map);
      _statsYearly = Map<String, dynamic>.from(results[1] as Map);
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing dashboard data: $e");
    }
  }
}
