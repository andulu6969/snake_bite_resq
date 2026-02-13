import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use localhost for Web
  static const String baseUrl = "http://localhost/snake_bite";

  // 1. Save Patient (Existing)
  static Future<bool> savePatientOutcome({
    required String patientId,
    required String species,
    required String severity,
    required String disposition,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/save_patient.php"),
        body: jsonEncode({
          "patient_id": patientId,
          "species": species,
          "severity": severity,
          "disposition": disposition,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 2. Get Dashboard Stats (New)
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/get_dashboard_stats.php"),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetching stats: $e");
    }
    return {"ICU": 0, "Ward": 0, "Discharge": 0, "Dead": 0, "total": 0};
  }

  // 3. Get Recent Patient (New)
  static Future<Map<String, dynamic>?> getRecentPatient() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/get_recent_patient.php"),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'];
        }
      }
    } catch (e) {
      print("Error fetching recent: $e");
    }
    return null;
  }

  // 4. Get Next Incremental ID (New)
  static Future<String> getNextPatientId() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/get_next_patient_id.php"),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['next_id'];
      }
    } catch (e) {
      print("Error fetching next ID: $e");
    }
    return "KDH-ER-26-0000"; // Fallback
  }
}
