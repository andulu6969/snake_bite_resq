import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_bite_resq/services/api_service.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _unitId;
  String? _hospitalName;
  String _role = 'station'; // 'station' or 'admin'
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get unitId => _unitId;
  String? get hospitalName => _hospitalName;
  String get role => _role;
  bool get isAdmin => _role == 'admin';

  // Hardcoded admin credentials for offline fallback
  static const String _adminUnitId = 'ADMIN';
  static const String _adminPasscode = 'admin1234';

  static String get _baseUrl => ApiService.baseUrl;

  AuthService() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _unitId = prefs.getString('unitId');
    _hospitalName = prefs.getString('hospitalName');
    _role = prefs.getString('role') ?? 'station';
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String unitId, String passcode) async {
    if (unitId.isEmpty || passcode.length < 4) {
      return false;
    }
    _isLoading = true;
    notifyListeners();

    // Check for hardcoded admin credentials
    if (unitId.toUpperCase() == _adminUnitId && passcode == _adminPasscode) {
      _isAuthenticated = true;
      _unitId = unitId.toUpperCase();
      _hospitalName = 'Ministry of Health';
      _role = 'admin';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('unitId', _unitId!);
      await prefs.setString('hospitalName', _hospitalName!);
      await prefs.setString('role', _role);

      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/api/login.php"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"unit_id": unitId, "passcode": passcode}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _isAuthenticated = true;
          _unitId = unitId;
          _hospitalName = data['hospital_name'] ?? "General Hospital";
          _role = data['role'] ?? 'station';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);
          await prefs.setString('unitId', unitId);
          await prefs.setString('hospitalName', _hospitalName!);
          await prefs.setString('role', _role);

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Auth Error: $e — falling back to offline mode.");

      final prefs = await SharedPreferences.getInstance();
      final cachedHospital = prefs.getString('hospitalName');

      _isAuthenticated = true;
      _unitId = unitId;
      _hospitalName = cachedHospital ?? "Offline Mode";
      _role = 'station'; // Default to station for offline

      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('unitId', unitId);
      await prefs.setString('role', _role);
      if (cachedHospital == null) {
        await prefs.setString('hospitalName', _hospitalName!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _unitId = null;
    _hospitalName = null;
    _role = 'station';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('unitId');
    await prefs.remove('hospitalName');
    await prefs.remove('role');

    notifyListeners();
  }
}
