import 'package:flutter/material.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isMonthly = true;
  bool _isLoading = true;

  Map<String, dynamic> _stats = {
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
  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic>? get recentPatient => _recentPatient;

  DashboardProvider() {
    loadDashboardData();
  }

  void toggleTimeFilter(String filter) {
    if (filter == "Monthly" && !_isMonthly) {
      _isMonthly = true;
      loadDashboardData();
    } else if (filter == "Yearly" && _isMonthly) {
      _isMonthly = false;
      loadDashboardData();
    }
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    final String filter = _isMonthly ? "monthly" : "yearly";

    try {
      // #4: read unitId once, then fire both requests in parallel
      final prefs = await SharedPreferences.getInstance();
      final unitId = prefs.getString('unitId') ?? '';

      final results = await Future.wait([
        ApiService.getDashboardStats(filter: filter, unitId: unitId),
        ApiService.getRecentPatient(unitId: unitId),
      ]);

      _stats = Map<String, dynamic>.from(results[0] as Map);
      _recentPatient = results[1] == null
          ? null
          : Map<String, dynamic>.from(results[1] as Map);
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
