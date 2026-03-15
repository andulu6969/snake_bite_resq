import 'package:flutter/material.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/models/hospital_model.dart';

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    "ICU": 0,
    "Ward": 0,
    "Observation": 0,
    "Discharge": 0,
    "total": 0,
  };
  List<Map<String, dynamic>> _recentCases = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getDashboardStats(filter: "monthly", unitId: "ALL"),
        ApiService.getCaseHistory(unitId: "ALL", page: 1, limit: 5),
      ]);
      _stats = Map<String, dynamic>.from(results[0]);
      final caseData = results[1];
      _recentCases =
          (caseData['records'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
    } catch (e) {
      debugPrint("Admin overview load error: $e");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final total = (_stats['total'] ?? 0) as int;
    final icu = (_stats['ICU'] ?? 0) as int;
    final ward = (_stats['Ward'] ?? 0) as int;
    final obs = (_stats['Observation'] ?? 0) as int;
    final discharge = (_stats['Discharge'] ?? 0) as int;
    final hospitalCount = Hospital.mockHospitals.length;
    final antivenomCount = Hospital.mockHospitals
        .where((h) => h.hasAntivenom)
        .length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 120),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.indigo.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ministry Dashboard",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    Text(
                      "System-wide overview",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Hero Stats Row
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Total Cases Hero Card
            _buildHeroCard(
              icon: Icons.assignment_rounded,
              label: "Total Cases",
              value: total.toString(),
              color: Colors.indigo,
              subtitle: "across all hospitals this month",
            ),

            const SizedBox(height: 16),

            // Disposition grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "ICU",
                    icu,
                    Colors.red,
                    Icons.emergency_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Ward",
                    ward,
                    Colors.blue,
                    Icons.bedroom_parent_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Observation",
                    obs,
                    Colors.orange,
                    Icons.visibility_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Discharge",
                    discharge,
                    Colors.green,
                    Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hospital network summary
            _buildNetworkSummaryCard(hospitalCount, antivenomCount),

            const SizedBox(height: 24),

            // Severity Distribution Chart
            _buildSeverityChart(icu, ward, obs, discharge, total),

            const SizedBox(height: 24),

            // Recent Activity Feed
            Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            if (_recentCases.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "No recent activity",
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...(_recentCases.map(_buildActivityItem)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade600, color.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    int value,
    MaterialColor color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color.shade600, size: 20),
              ),
              const Spacer(),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSummaryCard(int hospitalCount, int antivenomCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.blue.shade600,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  hospitalCount.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                Text(
                  "Hospitals",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: Colors.blueGrey.shade100),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.vaccines_rounded,
                  color: Colors.green.shade600,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  "$antivenomCount / $hospitalCount",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                Text(
                  "Antivenom Stock",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: Colors.blueGrey.shade100),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade600,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  (hospitalCount - antivenomCount).toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                Text(
                  "No Stock",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChart(
    int icu,
    int ward,
    int obs,
    int discharge,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Disposition Distribution",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
          const SizedBox(height: 16),
          // Proportional bar
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    if (icu > 0)
                      Expanded(
                        flex: icu,
                        child: Container(color: Colors.red.shade400),
                      ),
                    if (ward > 0)
                      Expanded(
                        flex: ward,
                        child: Container(color: Colors.blue.shade400),
                      ),
                    if (obs > 0)
                      Expanded(
                        flex: obs,
                        child: Container(color: Colors.orange.shade400),
                      ),
                    if (discharge > 0)
                      Expanded(
                        flex: discharge,
                        child: Container(color: Colors.green.shade400),
                      ),
                  ],
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(height: 24, color: Colors.grey.shade200),
            ),
          const SizedBox(height: 14),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legendItem("ICU", Colors.red.shade400, icu, total),
              _legendItem("Ward", Colors.blue.shade400, ward, total),
              _legendItem("Observation", Colors.orange.shade400, obs, total),
              _legendItem("Discharge", Colors.green.shade400, discharge, total),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, int value, int total) {
    final pct = total > 0 ? (value / total * 100).round() : 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "$label $pct%",
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> caseData) {
    final severity = caseData['severity'] ?? 'LOW';
    final Color severityColor;
    final Color severityTextColor;
    switch (severity.toString().toUpperCase()) {
      case 'CRITICAL':
        severityColor = Colors.red;
        severityTextColor = Colors.red.shade700;
        break;
      case 'HIGH':
        severityColor = Colors.orange;
        severityTextColor = Colors.orange.shade700;
        break;
      case 'MODERATE':
        severityColor = Colors.amber;
        severityTextColor = Colors.amber.shade700;
        break;
      default:
        severityColor = Colors.green;
        severityTextColor = Colors.green.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseData['patient_id'] ?? '—',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${caseData['species'] ?? 'Unknown'} • ${caseData['disposition'] ?? '—'}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              severity,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: severityTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
