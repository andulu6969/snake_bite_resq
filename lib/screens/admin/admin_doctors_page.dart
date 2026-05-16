import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/widgets/glass_card.dart';

class AdminDoctorsPage extends StatefulWidget {
  const AdminDoctorsPage({super.key});

  @override
  State<AdminDoctorsPage> createState() => _AdminDoctorsPageState();
}

class _AdminDoctorsPageState extends State<AdminDoctorsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pendingDoctors = [];
  List<Map<String, dynamic>> _activeDoctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDoctors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final adminUsername = auth.username ?? 'ADMIN';
      // For the admin passcode we use the hardcoded fallback for the API call
      // In production this should be token-based. For now use stored session.
      const adminPasscode = 'admin1234';

      // Fetch pending
      final pendingUri = Uri.parse(
        "${ApiService.baseUrl}/api/get_pending_doctors.php"
        "?admin_username=${Uri.encodeComponent(adminUsername)}"
        "&admin_passcode=${Uri.encodeComponent(adminPasscode)}"
        "&filter=pending",
      );
      final activeUri = Uri.parse(
        "${ApiService.baseUrl}/api/get_pending_doctors.php"
        "?admin_username=${Uri.encodeComponent(adminUsername)}"
        "&admin_passcode=${Uri.encodeComponent(adminPasscode)}"
        "&filter=active",
      );

      final results = await Future.wait([
        http.get(pendingUri).timeout(const Duration(seconds: 8)),
        http.get(activeUri).timeout(const Duration(seconds: 8)),
      ]);

      if (!mounted) return;

      final pendingData = jsonDecode(results[0].body);
      final activeData = jsonDecode(results[1].body);

      setState(() {
        _pendingDoctors = List<Map<String, dynamic>>.from(pendingData['doctors'] ?? []);
        _activeDoctors = List<Map<String, dynamic>>.from(activeData['doctors'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load doctor records. Check server connection.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _manageDoctor(int doctorId, String action, String doctorName) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          action == 'approve'
              ? 'Approve Doctor?'
              : action == 'suspend'
                  ? 'Suspend Doctor?'
                  : 'Delete Account?',
          style: TextStyle(
            color: action == 'delete' ? Colors.red : Colors.blueGrey.shade900,
          ),
        ),
        content: Text(
          action == 'approve'
              ? 'Approve $doctorName\'s account? They will be able to log in immediately.'
              : action == 'suspend'
                  ? 'Suspend $doctorName\'s account? They will no longer be able to log in.'
                  : 'Permanently delete $doctorName\'s account? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approve'
                  ? Colors.green
                  : action == 'suspend'
                      ? Colors.orange
                      : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http
          .post(
            Uri.parse("${ApiService.baseUrl}/api/manage_doctor.php"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "admin_username": auth.username ?? 'ADMIN',
              "admin_passcode": 'admin1234',
              "doctor_id": doctorId,
              "action": action,
            }),
          )
          .timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Done'),
          backgroundColor: data['status'] == 'success' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );

      if (data['status'] == 'success') {
        _loadDoctors(); // Refresh
      }
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Network error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.blueGrey.shade600,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pending_actions, size: 16),
                    const SizedBox(width: 6),
                    Text('Pending (${_pendingDoctors.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 6),
                    Text('Active (${_activeDoctors.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Doctor Accounts',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey.shade500,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _loadDoctors,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDoctorList(_pendingDoctors, isPending: true),
                        _buildDoctorList(_activeDoctors, isPending: false),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDoctors,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(List<Map<String, dynamic>> doctors, {required bool isPending}) {
    if (doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.inbox_outlined : Icons.people_outline,
              color: Colors.blueGrey.shade300,
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? 'No pending registrations'
                  : 'No active doctor accounts',
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doc = doctors[index];
        return _buildDoctorCard(doc, isPending: isPending);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doc, {required bool isPending}) {
    final int docId = int.tryParse(doc['id'].toString()) ?? 0;
    final String name = doc['full_name'] ?? '—';
    final String username = doc['username'] ?? '—';
    final String spec = doc['specialization'] ?? '—';
    final String hospital = doc['hospital_name'] ?? '—';
    final String status = doc['status'] ?? '—';
    final String createdAt = doc['created_at'] ?? '—';

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isPending ? Colors.orange.shade100 : Colors.blue.shade100,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPending ? Colors.orange.shade700 : Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    Text(
                      '@$username',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPending
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPending ? Colors.orange.shade700 : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 10),
          _infoRow(Icons.medical_services_outlined, 'Specialization', spec),
          const SizedBox(height: 6),
          _infoRow(Icons.local_hospital_outlined, 'Hospital', hospital),
          const SizedBox(height: 6),
          _infoRow(Icons.schedule_outlined, 'Registered', createdAt.split(' ')[0]),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              if (isPending) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _manageDoctor(docId, 'approve', name),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _manageDoctor(docId, 'delete', name),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _manageDoctor(docId, 'suspend', name),
                    icon: const Icon(Icons.pause_circle_outline, size: 16),
                    label: const Text('Suspend'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _manageDoctor(docId, 'delete', name),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blueGrey.shade400),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
