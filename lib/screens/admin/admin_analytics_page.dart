import 'package:flutter/material.dart';
import 'package:snake_bite_resq/services/api_service.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  bool _isMonthly = true;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    "ICU": 0,
    "Ward": 0,
    "Observation": 0,
    "Discharge": 0,
    "total": 0,
  };
  List<Map<String, dynamic>> _allCases = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final filter = _isMonthly ? "monthly" : "yearly";
      final results = await Future.wait([
        ApiService.getDashboardStats(filter: filter, unitId: "ALL"),
        ApiService.getCaseHistory(unitId: "ALL", page: 1, limit: 50),
      ]);
      _stats = Map<String, dynamic>.from(results[0]);
      final caseData = results[1];
      _allCases =
          (caseData['records'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
    } catch (e) {
      debugPrint("Admin analytics load error: $e");
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

    // Count severity distribution from case list
    int critical = 0, high = 0, moderate = 0, low = 0;
    for (final c in _allCases) {
      switch ((c['severity'] ?? '').toString().toUpperCase()) {
        case 'CRITICAL':
          critical++;
          break;
        case 'HIGH':
          high++;
          break;
        case 'MODERATE':
          moderate++;
          break;
        default:
          low++;
      }
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 120),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: Colors.teal.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Analytics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    Text(
                      "System-wide case analytics",
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

          const SizedBox(height: 20),

          // Time filter toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                Expanded(child: _buildToggle("Monthly", _isMonthly)),
                Expanded(child: _buildToggle("Yearly", !_isMonthly)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Disposition Breakdown Bars
            _buildSectionTitle("Disposition Breakdown"),
            const SizedBox(height: 12),
            _buildBarChart([
              _BarData("ICU", icu, Colors.red),
              _BarData("Ward", ward, Colors.blue),
              _BarData("Observation", obs, Colors.orange),
              _BarData("Discharge", discharge, Colors.green),
            ], total),

            const SizedBox(height: 28),

            // Severity Breakdown
            _buildSectionTitle("Severity Distribution"),
            const SizedBox(height: 12),
            _buildBarChart([
              _BarData("Critical", critical, Colors.red),
              _BarData("High", high, Colors.orange),
              _BarData("Moderate", moderate, Colors.amber),
              _BarData("Low", low, Colors.green),
            ], _allCases.length),

            const SizedBox(height: 28),

            // Key metrics cards
            _buildSectionTitle("Key Insights"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.trending_up_rounded,
                    title: "Total Cases",
                    value: total.toString(),
                    color: Colors.indigo,
                    subtitle: _isMonthly ? "this month" : "this year",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.priority_high_rounded,
                    title: "Critical Rate",
                    value: total > 0 ? "${(icu / total * 100).round()}%" : "0%",
                    color: Colors.red,
                    subtitle: "ICU admissions",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: "Discharge Rate",
                    value: total > 0
                        ? "${(discharge / total * 100).round()}%"
                        : "0%",
                    color: Colors.green,
                    subtitle: "sent home safely",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    icon: Icons.bar_chart_rounded,
                    title: "Avg / Hospital",
                    value: total > 0 ? (total / 10).toStringAsFixed(1) : "0",
                    color: Colors.teal,
                    subtitle: "cases per facility",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Species distribution (from case data)
            _buildSectionTitle("Species Identified"),
            const SizedBox(height: 12),
            _buildSpeciesBreakdown(),
          ],
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        final shouldToggle =
            (label == "Monthly" && !_isMonthly) ||
            (label == "Yearly" && _isMonthly);
        if (shouldToggle) {
          setState(() => _isMonthly = label == "Monthly");
          _loadAnalytics();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.indigo.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.blueGrey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.shade900,
      ),
    );
  }

  Widget _buildBarChart(List<_BarData> data, int maxTotal) {
    final maxVal = data.fold<int>(0, (max, d) => d.value > max ? d.value : max);
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
        children: data.map((d) {
          final pct = maxVal > 0 ? d.value / maxVal : 0.0;
          final totalPct = maxTotal > 0
              ? (d.value / maxTotal * 100).round()
              : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      d.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                    Text(
                      "${d.value} ($totalPct%)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 12,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                        ),
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [d.color.shade400, d.color.shade300],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required MaterialColor color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color.shade600, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey.shade900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesBreakdown() {
    // Count species from cases
    final speciesCount = <String, int>{};
    for (final c in _allCases) {
      final species = (c['species'] ?? 'Unknown').toString();
      speciesCount[species] = (speciesCount[species] ?? 0) + 1;
    }

    if (speciesCount.isEmpty) {
      return Container(
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
            "No species data available",
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
          ),
        ),
      );
    }

    // Sort by count descending
    final sorted = speciesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.blue,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
    ];

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
        children: sorted.asMap().entries.map((entry) {
          final color = colors[entry.key % colors.length];
          final species = entry.value.key;
          final count = entry.value.value;
          final pct = _allCases.isNotEmpty
              ? (count / _allCases.length * 100).round()
              : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.shade500,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    species,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ),
                Text(
                  "$count ($pct%)",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BarData {
  final String label;
  final int value;
  final MaterialColor color;

  _BarData(this.label, this.value, this.color);
}
