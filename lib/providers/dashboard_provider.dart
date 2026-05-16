import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/services/offline_cache_service.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isMonthly = true;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _noCacheStats   = false;   // offline AND no stats cache
  bool _noCacheRecent  = false;   // offline AND no recent patient cache
  DateTime? _cacheTimestamp;

  Map<String, dynamic> _statsMonthly = {
    "ICU": 0, "Ward": 0, "Observation": 0, "Discharge": 0, "total": 0,
  };
  Map<String, dynamic> _statsYearly = {
    "ICU": 0, "Ward": 0, "Observation": 0, "Discharge": 0, "total": 0,
  };
  Map<String, dynamic>? _recentPatient;

  // ── Getters ──────────────────────────────────────────────────────────────────
  bool get isMonthly       => _isMonthly;
  bool get isLoading       => _isLoading;
  bool get isOffline       => _isOffline;
  bool get hasCache        => _cacheTimestamp != null;
  bool get noCacheOffline  => _isOffline && _noCacheStats;   // show "no cache" state for chart
  bool get noCacheRecent   => _isOffline && _noCacheRecent;  // show "no cache" state for recent patient
  DateTime? get cacheTimestamp => _cacheTimestamp;

  String get cacheAgeLabel =>
      _isOffline ? OfflineCacheService.ageLabel(_cacheTimestamp) : '';

  Map<String, dynamic> get stats =>
      _isMonthly ? _statsMonthly : _statsYearly;
  Map<String, dynamic>? get recentPatient => _recentPatient;

  DashboardProvider() {
    loadDashboardData();
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  void toggleTimeFilter(String filter) {
    if (filter == "Monthly" && !_isMonthly) {
      _isMonthly = true;
      notifyListeners();
      _loadBackgroundData();
    } else if (filter == "Yearly" && _isMonthly) {
      _isMonthly = false;
      notifyListeners();
      _loadBackgroundData();
    }
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    final prefs        = await SharedPreferences.getInstance();
    final unitId       = prefs.getString('unitId')       ?? '';
    final hospitalName = prefs.getString('hospitalName') ?? '';

    // Check connectivity first (quick ping)
    _isOffline = !(await _ping());

    try {
      final results = await Future.wait([
        ApiService.getDashboardStats(
          filter:       "monthly",
          unitId:       unitId,
          hospitalName: hospitalName,
        ),
        ApiService.getDashboardStats(
          filter:       "yearly",
          unitId:       unitId,
          hospitalName: hospitalName,
        ),
        ApiService.getRecentPatient(
          hospitalName: hospitalName,
          unitId:       unitId,
        ),
      ]);

      _statsMonthly  = Map<String, dynamic>.from(results[0] as Map);
      _statsYearly   = Map<String, dynamic>.from(results[1] as Map);
      final rawRecent = results[2];

      // Detect no-cache states
      _noCacheStats  = _statsMonthly['_source'] == 'no_cache';
      _noCacheRecent = rawRecent?['_no_cache'] == true;

      _recentPatient = (_noCacheRecent || rawRecent == null)
          ? null
          : Map<String, dynamic>.from(rawRecent);

      // Grab cache timestamp to show "last synced X ago" in offline mode
      _cacheTimestamp = await OfflineCacheService.cacheTimestamp(
        hospitalName: hospitalName,
        filter:       'monthly',
      );
    } catch (e) {
      debugPrint("DashboardProvider error: $e");
      _isOffline = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────────

  Future<void> _loadBackgroundData() async {
    final prefs        = await SharedPreferences.getInstance();
    final unitId       = prefs.getString('unitId')       ?? '';
    final hospitalName = prefs.getString('hospitalName') ?? '';

    _isOffline = !(await _ping());

    try {
      final results = await Future.wait([
        ApiService.getDashboardStats(
          filter:       "monthly",
          unitId:       unitId,
          hospitalName: hospitalName,
        ),
        ApiService.getDashboardStats(
          filter:       "yearly",
          unitId:       unitId,
          hospitalName: hospitalName,
        ),
      ]);
      _statsMonthly = Map<String, dynamic>.from(results[0] as Map);
      _statsYearly  = Map<String, dynamic>.from(results[1] as Map);
    } catch (e) {
      debugPrint("DashboardProvider background refresh error: $e");
    }

    notifyListeners();
  }

  /// Quick connectivity check against our own server.
  Future<bool> _ping() async {
    try {
      final res = await http
          .get(Uri.parse('${ApiService.baseUrl}/api/ping.php'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
