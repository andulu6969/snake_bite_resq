import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_bite_resq/services/api_service.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;
  String? _hospitalName;
  String? _fullName;
  String? _specialization;
  String _role = 'doctor'; // 'doctor' or 'admin'
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// The logged-in username (used as unit_id in legacy API calls).
  String? get username => _username;

  /// Alias kept for backward compatibility with existing screens.
  String? get unitId => _username;

  String? get hospitalName => _hospitalName;

  /// Doctor's full name (e.g. "Dr. Ahmad bin Razali"). Null for admin.
  String? get fullName => _fullName;

  /// Doctor's specialization (e.g. "Emergency Medicine"). Null for admin.
  String? get specialization => _specialization;

  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isDoctor => _role == 'doctor';

  // ── Hardcoded credentials (work 100% offline, no server needed) ───────────────

  // Admin
  static const String _adminUnitId  = 'ADMIN';
  static const String _adminPasscode = 'admin1234';

  // Demo doctor — for usability testing / device demos
  static const _demoDoctors = [
    {
      'username':       'demo',
      'password':       'demo1234',
      'fullName':       'Dr. Ahmad bin Razali',
      'hospitalName':   'Hospital Sultanah Bahiyah',
      'specialization': 'Emergency Medicine',
      'role':           'doctor',
    },
  ];

  static String get _baseUrl => ApiService.baseUrl;

  AuthService() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _username = prefs.getString('username') ?? prefs.getString('unitId');
    _hospitalName = prefs.getString('hospitalName');
    _fullName = prefs.getString('fullName');
    _specialization = prefs.getString('specialization');
    _role = prefs.getString('role') ?? 'doctor';
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.length < 4) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    // 1. Hardcoded admin (offline)
    if (username.toUpperCase() == _adminUnitId && password == _adminPasscode) {
      await _setSession(
        username: username.toUpperCase(),
        role: 'admin',
        hospitalName: 'Ministry of Health',
        fullName: 'Administrator',
        specialization: null,
      );
      return true;
    }

    // 2. Hardcoded demo doctors (offline — for usability testing)
    final demoMatch = _demoDoctors.where((d) =>
      d['username'] == username.toLowerCase() &&
      d['password'] == password,
    );
    if (demoMatch.isNotEmpty) {
      final d = demoMatch.first;
      await _setSession(
        username: d['username']!,
        role:     d['role']!,
        hospitalName:   d['hospitalName']!,
        fullName:       d['fullName']!,
        specialization: d['specialization'],
      );
      return true;
    }

    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/api/login.php"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await _setSession(
            username: data['username'] ?? username,
            role: data['role'] ?? 'doctor',
            hospitalName: data['hospital_name'] ?? 'General Hospital',
            fullName: data['full_name'],
            specialization: data['specialization'],
          );
          return true;
        }
      }

      // Surface specific error messages (e.g. "pending approval")
      if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        _lastError = data['message'] ?? 'Access denied';
      } else {
        _lastError = null;
      }
    } catch (e) {
      debugPrint("Auth Error: $e — attempting offline mode.");

      // Offline fallback: allow re-login with cached credentials
      final prefs = await SharedPreferences.getInstance();
      final cachedUser = prefs.getString('username') ?? prefs.getString('unitId');
      final cachedHospital = prefs.getString('hospitalName');
      final cachedRole = prefs.getString('role') ?? 'doctor';
      final cachedFullName = prefs.getString('fullName');
      final cachedSpec = prefs.getString('specialization');

      if (cachedUser != null && cachedUser.toLowerCase() == username.toLowerCase()) {
        await _setSession(
          username: cachedUser,
          role: cachedRole,
          hospitalName: cachedHospital ?? 'Offline Mode',
          fullName: cachedFullName,
          specialization: cachedSpec,
        );
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Last server-side error message (e.g., "pending approval")
  String? _lastError;
  String? get lastError => _lastError;

  Future<void> _setSession({
    required String username,
    required String role,
    required String hospitalName,
    String? fullName,
    String? specialization,
  }) async {
    _isAuthenticated  = true;
    _username         = username;
    _role             = role;
    _hospitalName     = hospitalName;
    _fullName         = fullName;
    _specialization   = specialization;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated',  true);
    await prefs.setString('username',       username);
    await prefs.setString('unitId',         username); // legacy compat
    await prefs.setString('hospitalName',   hospitalName);
    await prefs.setString('role',           role);

    // Always overwrite (or clear) nullable fields so stale
    // values from a previous session never leak into this one.
    if (fullName != null) {
      await prefs.setString('fullName', fullName);
    } else {
      await prefs.remove('fullName');
    }
    if (specialization != null) {
      await prefs.setString('specialization', specialization);
    } else {
      await prefs.remove('specialization');  // ← prevents stale specialization
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _username = null;
    _hospitalName = null;
    _fullName = null;
    _specialization = null;
    _role = 'doctor';
    _lastError = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('username');
    await prefs.remove('unitId');
    await prefs.remove('hospitalName');
    await prefs.remove('role');
    await prefs.remove('fullName');
    await prefs.remove('specialization');

    notifyListeners();
  }
}
