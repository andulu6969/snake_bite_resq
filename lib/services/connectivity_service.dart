import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:snake_bite_resq/services/api_service.dart';

/// Lightweight connectivity detector — no external package needed.
/// Pings the app's own server; falls back to DNS check.
class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline  => _isOnline;
  bool get isOffline => !_isOnline;

  ConnectivityService() {
    _check();
  }

  /// Call this to manually refresh connectivity state.
  Future<bool> check() async {
    await _check();
    return _isOnline;
  }

  Future<void> _check() async {
    bool online = false;
    try {
      // Try pinging our own server first (fastest indicator for the app)
      final res = await http
          .get(Uri.parse('${ApiService.baseUrl}/api/ping.php'))
          .timeout(const Duration(seconds: 3));
      online = res.statusCode < 500;
    } catch (_) {
      // If our server is unreachable, try a public DNS-style ping
      try {
        final res = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 3));
        online = res.statusCode == 200;
      } catch (_) {
        online = false;
      }
    }

    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
      debugPrint('[Connectivity] Status changed → ${_isOnline ? "ONLINE" : "OFFLINE"}');
    }
  }
}
