import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_bite_resq/services/offline_cache_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return "http://localhost/snake_bite";
    if (Platform.isAndroid) return "http://10.0.2.2/snake_bite";
    return "http://localhost/snake_bite";
  }

  // ── Session helpers ──────────────────────────────────────────────────────────

  static Future<Map<String, String?>> _getSessionFields() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'unitId':       prefs.getString('unitId'),
      'hospitalName': prefs.getString('hospitalName'),
      'fullName':     prefs.getString('fullName'),
    };
  }

  // ── 1. Save Patient (offline queue fallback) ─────────────────────────────────

  static Future<bool> savePatientOutcome({
    required String patientId,
    required String species,
    required String severity,
    required String disposition,
    String? icPassport,
    String? diagnosedBy,
    String? hospitalName,
    String? unitId,
  }) async {
    final session  = await _getSessionFields();
    final uid      = unitId      ?? session['unitId']      ?? '';
    final hospital = hospitalName ?? session['hospitalName'] ?? '';
    final doctor   = diagnosedBy ?? session['fullName']    ?? '';

    final data = {
      "patient_id":    patientId,
      "unit_id":       uid,
      "hospital_name": hospital,
      "species":       species,
      "severity":      severity,
      "disposition":   disposition,
      "ic_passport":   icPassport ?? '',
      "diagnosed_by":  doctor,
      "timestamp":     DateTime.now().toIso8601String(),
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
        await OfflineCacheService.refreshPendingCount();
        return true;
      }
    } catch (e) {
      debugPrint("Network error saving patient — queuing offline: $e");
    }

    await _enqueueOffline(data);
    return false;
  }

  // ── 2. Offline sync ─────────────────────────────────────────────────────────

  static Future<int> syncPendingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('offline_queue') ?? [];
      if (queue.isEmpty) return 0;

      debugPrint('[Sync] Syncing ${queue.length} offline records...');
      final remaining  = <String>[];
      int synced = 0;

      for (final jsonStr in queue) {
        try {
          final data     = jsonDecode(jsonStr);
          final response = await http
              .post(
                Uri.parse("$baseUrl/api/save_patient.php"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(data),
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            synced++;
          } else {
            remaining.add(jsonStr);
          }
        } catch (_) {
          remaining.add(jsonStr);
        }
      }

      await prefs.setStringList('offline_queue', remaining);
      await OfflineCacheService.refreshPendingCount();
      debugPrint('[Sync] Synced $synced, ${remaining.length} remaining');
      return synced;
    } catch (e) {
      debugPrint('[Sync] Error: $e');
      return 0;
    }
  }

  // ── 3. Dashboard stats (cache on success, serve cache on failure) ────────────

  static Future<Map<String, dynamic>> getDashboardStats({
    String filter = "monthly",
    String? unitId,
    String? hospitalName,
  }) async {
    final session  = await _getSessionFields();
    final uid      = unitId      ?? session['unitId']      ?? '';
    final hospital = hospitalName ?? session['hospitalName'] ?? '';

    try {
      final queryParams = <String, String>{'filter': filter};
      if (hospital.isNotEmpty) queryParams['hospital_name'] = hospital;
      if (uid.isNotEmpty)      queryParams['unit_id']       = uid;

      final uri      = Uri.parse("$baseUrl/api/get_dashboard_stats.php")
          .replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // ✅ Cache successful response
        await OfflineCacheService.saveStats(
          hospitalName: hospital,
          filter:       filter,
          data:         data,
        );
        return data;
      }
    } catch (e) {
      debugPrint('[Stats] Network error — trying cache: $e');
    }

    // ❌ Network failed → serve cached data
    final cached = await OfflineCacheService.loadStats(
      hospitalName: hospital,
      filter:       filter,
    );
    if (cached != null) return cached;

    // No cache exists — return explicit no-cache marker so UI can show appropriate state
    return {
      "ICU": 0, "Ward": 0, "Observation": 0, "Discharge": 0, "total": 0,
      "_source": "no_cache",
    };
  }

  // ── 4. Recent patient (cache on success, serve cache on failure) ─────────────

  static Future<Map<String, dynamic>?> getRecentPatient({
    String? hospitalName,
    String? unitId,
  }) async {
    final session  = await _getSessionFields();
    final hospital = hospitalName ?? session['hospitalName'] ?? '';
    final uid      = unitId      ?? session['unitId']       ?? '';

    // STRICT: never request without a hospital scope
    if (hospital.isEmpty && uid.isEmpty) return null;

    try {
      final queryParams = <String, String>{};
      if (hospital.isNotEmpty) {
        queryParams['hospital_name'] = hospital;
      } else {
        queryParams['unit_id'] = uid;
      }

      final uri      = Uri.parse("$baseUrl/api/get_recent_patient.php")
          .replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          final data = Map<String, dynamic>.from(body['data'] as Map);
          // ✅ Cache successful response
          await OfflineCacheService.saveRecentPatient(
            hospitalName: hospital.isNotEmpty ? hospital : uid,
            data:         data,
          );
          return data;
        }
      }
    } catch (e) {
      debugPrint('[Recent] Network error — trying cache: $e');
    }

    // ❌ Network failed → serve cached data
    final cached = await OfflineCacheService.loadRecentPatient(
      hospitalName: hospital.isNotEmpty ? hospital : uid,
    );
    if (cached != null) return cached;

    // No cache — return sentinel map so home page can show "no cache" state
    return {"_no_cache": true};
  }

  // ── 5. Next patient ID (shared hospital counter, offline fallback) ───────────

  static Future<String> getNextPatientId({
    String? hospitalName,
    String? unitId,
  }) async {
    final session  = await _getSessionFields();
    final hospital = hospitalName ?? session['hospitalName'] ?? '';
    final uid      = unitId      ?? session['unitId']        ?? '';

    try {
      final queryParams = <String, String>{};
      if (hospital.isNotEmpty) {
        queryParams['hospital_name'] = hospital;
      } else if (uid.isNotEmpty) {
        queryParams['unit_id'] = uid;
      }

      final uri      = Uri.parse("$baseUrl/api/get_next_patient_id.php")
          .replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['next_id'] ?? _offlineFallbackId(hospital);
      }
    } catch (e) {
      debugPrint('[PatientID] Network error — using offline ID: $e');
    }

    return _offlineFallbackId(hospital.isNotEmpty ? hospital : uid);
  }

  static String _offlineFallbackId(String hospitalName) {
    final year     = DateTime.now().year.toString().substring(2);
    final stripped = hospitalName.replaceAll(RegExp(r'^Hospital\s+', caseSensitive: false), '');
    final code     = stripped
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join();
    final ts = DateTime.now().millisecondsSinceEpoch % 10000;
    return "${code.isEmpty ? 'KDH' : code}-$year-${ts.toString().padLeft(4, '0')}";
  }

  // ── 6. Case history (cache on success, serve cache on failure) ───────────────

  static Future<Map<String, dynamic>> getCaseHistory({
    String? hospitalName,
    String? unitId,
    int page       = 1,
    int limit      = 15,
    String search  = '',
    String severity = '',
  }) async {
    final session  = await _getSessionFields();
    final hospital = hospitalName ?? session['hospitalName'] ?? '';
    final uid      = unitId      ?? session['unitId']        ?? '';

    try {
      final queryParams = <String, String>{
        'page':  page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty)   'search':   search,
        if (severity.isNotEmpty) 'severity': severity,
      };

      if (uid == 'ALL') {
        queryParams['unit_id'] = 'ALL';
      } else if (hospital.isNotEmpty) {
        queryParams['hospital_name'] = hospital;
      } else if (uid.isNotEmpty) {
        queryParams['unit_id'] = uid;
      }

      final uri      = Uri.parse("$baseUrl/api/get_case_history.php")
          .replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // ✅ Cache first page with no filters (used for offline display)
        if (page == 1 && search.isEmpty && severity.isEmpty) {
          await OfflineCacheService.saveCaseHistory(
            hospitalName: hospital.isNotEmpty ? hospital : uid,
            data:         data,
          );
        }
        return data;
      }
    } catch (e) {
      debugPrint('[CaseHistory] Network error — trying cache: $e');
    }

    // ❌ Network failed → serve cached history (first page only)
    if (page == 1 && search.isEmpty && severity.isEmpty) {
      final cached = await OfflineCacheService.loadCaseHistory(
        hospitalName: hospital.isNotEmpty ? hospital : uid,
      );
      if (cached != null) return cached;
    }

    return {"status": "offline", "total": 0, "page": 1, "pages": 1, "records": []};
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  static Future<void> _enqueueOffline(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('offline_queue') ?? [];
      queue.add(jsonEncode(data));
      await prefs.setStringList('offline_queue', queue);
      await OfflineCacheService.refreshPendingCount();
      debugPrint('[Queue] Offline queue size: ${queue.length}');
    } catch (e) {
      debugPrint('[Queue] Error enqueueing: $e');
    }
  }

}
