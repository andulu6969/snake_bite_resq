import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return "http://localhost/snake_bite";
    if (Platform.isAndroid) return "http://10.0.2.2/snake_bite";
    // iOS simulator uses localhost; real iPhone on same LAN needs the
    // machine's actual IP, e.g. "http://192.168.x.x/snake_bite".
    return "http://localhost/snake_bite";
  }

  // Helper: read the logged-in unit_id from SharedPreferences
  static Future<String?> _getUnitId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('unitId');
  }

  // 1. Save Patient (with Offline Fallback)
  static Future<bool> savePatientOutcome({
    required String patientId,
    required String species,
    required String severity,
    required String disposition,
  }) async {
    final unitId = await _getUnitId();

    final data = {
      "patient_id": patientId,
      "unit_id": unitId,
      "species": species,
      "severity": severity,
      "disposition": disposition,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/save_patient.php"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else {
        await _saveToOfflineQueue(data);
        return false;
      }
    } catch (e) {
      debugPrint("Network Error: $e. Saving offline.");
      await _saveToOfflineQueue(data);
      return false;
    }
  }

  // --- OFFLINE SYNC LOGIC ---

  static Future<void> _saveToOfflineQueue(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> queue = prefs.getStringList('offline_queue') ?? [];
      queue.add(jsonEncode(data));
      await prefs.setStringList('offline_queue', queue);
      debugPrint("Saved to Offline Queue. Total: ${queue.length}");
    } catch (e) {
      debugPrint("Error saving offline: $e");
    }
  }

  static Future<int> syncPendingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> queue = prefs.getStringList('offline_queue') ?? [];

      if (queue.isEmpty) return 0;

      debugPrint("Syncing ${queue.length} offline records...");
      final List<String> remainingQueue = [];
      int syncedCount = 0;

      for (String jsonStr in queue) {
        try {
          final data = jsonDecode(jsonStr);
          final response = await http
              .post(
                Uri.parse("$baseUrl/api/save_patient.php"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "patient_id": data['patient_id'],
                  "unit_id": data['unit_id'],
                  "species": data['species'],
                  "severity": data['severity'],
                  "disposition": data['disposition'],
                  "timestamp": data['timestamp'],
                }),
              )
              .timeout(const Duration(seconds: 5)); // #3: per-request timeout

          if (response.statusCode == 200) {
            syncedCount++;
          } else {
            remainingQueue.add(jsonStr);
          }
        } catch (e) {
          remainingQueue.add(jsonStr); // keep for next sync attempt
        }
      }

      await prefs.setStringList('offline_queue', remainingQueue);
      return syncedCount;
    } catch (e) {
      debugPrint("Sync Error: $e");
      return 0;
    }
  }

  // 2. Get Dashboard Stats (filtered by unit + time period)
  static Future<Map<String, dynamic>> getDashboardStats({
    String filter = "monthly",
    String? unitId,
  }) async {
    try {
      final uid = unitId ?? await _getUnitId() ?? '';
      final uri = Uri.parse(
        "$baseUrl/api/get_dashboard_stats.php?filter=$filter&unit_id=${Uri.encodeComponent(uid)}",
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 8)); // #2: timeout added
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching stats: $e");
    }
    return {"ICU": 0, "Ward": 0, "Observation": 0, "Discharge": 0, "total": 0};
  }

  // 3. Get Recent Patient (scoped to unit)
  static Future<Map<String, dynamic>?> getRecentPatient({
    String? unitId,
  }) async {
    try {
      final uid = unitId ?? await _getUnitId() ?? '';
      final uri = Uri.parse(
        "$baseUrl/api/get_recent_patient.php?unit_id=${Uri.encodeComponent(uid)}",
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 8)); // #2: timeout added
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'];
        }
      }
    } catch (e) {
      debugPrint("Error fetching recent: $e");
    }
    return null;
  }

  // 4. Get Next Incremental ID (scoped to unit, generates hospital-prefixed IDs)
  static Future<String> getNextPatientId({String? unitId}) async {
    try {
      final uid = unitId ?? await _getUnitId() ?? '';
      final uri = Uri.parse(
        "$baseUrl/api/get_next_patient_id.php?unit_id=${Uri.encodeComponent(uid)}",
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['next_id'];
      }
    } catch (e) {
      debugPrint("Error fetching next ID: $e");
    }
    // Offline fallback — timestamp-based temp ID, replaced on sync
    final ts = DateTime.now().millisecondsSinceEpoch;
    return "OFFLINE-$ts";
  }

  // 5. Get Case History (paginated, searchable, filterable by severity)
  static Future<Map<String, dynamic>> getCaseHistory({
    String? unitId,
    int page = 1,
    int limit = 15,
    String search = '',
    String severity = '',
  }) async {
    try {
      final uid = unitId ?? await _getUnitId() ?? '';
      final queryParams = {
        'unit_id': uid,
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        if (severity.isNotEmpty) 'severity': severity,
      };
      final uri = Uri.parse(
        "$baseUrl/api/get_case_history.php",
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching case history: $e");
    }
    return {
      "status": "error",
      "total": 0,
      "page": 1,
      "pages": 1,
      "records": [],
    };
  }
}
