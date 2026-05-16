import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local caching of API responses so the app works fully offline.
///
/// Each cache entry stores:
///   - the JSON payload
///   - a timestamp for cache-age display
///
/// Cache keys (constants at bottom of file) are namespaced so they
/// never clash with other SharedPreferences keys.
class OfflineCacheService {
  // ── Cache Keys ──────────────────────────────────────────────────────────────
  static const String _keyPrefix       = 'cache_';
  static const String _keyStats        = '${_keyPrefix}stats_';       // + hospitalName + filter
  static const String _keyRecent       = '${_keyPrefix}recent_';      // + hospitalName
  static const String _keyHistory      = '${_keyPrefix}history_';     // + hospitalName
  static const String _keyOfflineQueue = 'offline_queue';             // existing

  // ── Default TTL ─────────────────────────────────────────────────────────────
  /// Maximum age before cached data is considered stale (not forced — app still
  /// shows stale data with a warning rather than nothing).
  static const Duration staleTtl = Duration(hours: 24);

  // ── Write ────────────────────────────────────────────────────────────────────

  static Future<void> saveStats({
    required String hospitalName,
    required String filter,
    required Map<String, dynamic> data,
  }) async {
    await _write(_statsKey(hospitalName, filter), data);
  }

  static Future<void> saveRecentPatient({
    required String hospitalName,
    required Map<String, dynamic> data,
  }) async {
    await _write(_recentKey(hospitalName), data);
  }

  static Future<void> saveCaseHistory({
    required String hospitalName,
    required Map<String, dynamic> data,
  }) async {
    await _write(_historyKey(hospitalName), data);
  }

  // ── Read ─────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> loadStats({
    required String hospitalName,
    required String filter,
  }) async {
    return _read(_statsKey(hospitalName, filter));
  }

  static Future<Map<String, dynamic>?> loadRecentPatient({
    required String hospitalName,
  }) async {
    return _read(_recentKey(hospitalName));
  }

  static Future<Map<String, dynamic>?> loadCaseHistory({
    required String hospitalName,
  }) async {
    return _read(_historyKey(hospitalName));
  }

  // ── Cache age ─────────────────────────────────────────────────────────────────

  static Future<DateTime?> cacheTimestamp({
    required String hospitalName,
    required String filter,
  }) async {
    return _timestamp(_statsKey(hospitalName, filter));
  }

  /// Human-readable age string, e.g. "3 min ago", "2 h ago", "Yesterday"
  static String ageLabel(DateTime? ts) {
    if (ts == null) return 'No cache';
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1)  return 'Just cached';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours   < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} day${diff.inDays > 1 ? "s" : ""} ago';
  }

  static bool isStale(DateTime? ts) {
    if (ts == null) return true;
    return DateTime.now().difference(ts) > staleTtl;
  }

  // ── Offline patient queue ─────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> loadOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_keyOfflineQueue) ?? [];
    return raw
        .map((s) {
          try { return Map<String, dynamic>.from(jsonDecode(s) as Map); }
          catch (_) { return null; }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static int get pendingCount => _pendingCount;
  static int _pendingCount = 0;

  static Future<void> refreshPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    _pendingCount = (prefs.getStringList(_keyOfflineQueue) ?? []).length;
  }

  // ── Clear ─────────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys  = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (final k in keys) {
      await prefs.remove(k);
    }
    debugPrint('[Cache] Cleared all cached responses');
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  static String _statsKey(String hospital, String filter) =>
      '$_keyStats${_sanitize(hospital)}_$filter';

  static String _recentKey(String hospital) =>
      '$_keyRecent${_sanitize(hospital)}';

  static String _historyKey(String hospital) =>
      '$_keyHistory${_sanitize(hospital)}';

  static String _sanitize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  static Future<void> _write(String key, Map<String, dynamic> data) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'ts':   DateTime.now().toIso8601String(),
        'data': data,
      });
      await prefs.setString(key, payload);
    } catch (e) {
      debugPrint('[Cache] Write error for $key: $e');
    }
  }

  static Future<Map<String, dynamic>?> _read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(key);
      if (raw == null) return null;
      final wrapper = jsonDecode(raw) as Map;
      return Map<String, dynamic>.from(wrapper['data'] as Map);
    } catch (e) {
      debugPrint('[Cache] Read error for $key: $e');
      return null;
    }
  }

  static Future<DateTime?> _timestamp(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(key);
      if (raw == null) return null;
      final wrapper = jsonDecode(raw) as Map;
      return DateTime.tryParse(wrapper['ts'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }
}
