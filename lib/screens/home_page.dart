import 'package:flutter/material.dart';
import 'package:snake_bite_resq/services/api_service.dart'; // Import API Service

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMonthly = true;

  // Real Data Variables
  Map<String, dynamic> stats = {
    "ICU": 0,
    "Ward": 0,
    "Observation": 0,
    "Discharge": 0,
    "total": 0,
  };
  Map<String, dynamic>? recentPatient;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fetch Data from API
  Future<void> _loadDashboardData() async {
    final fetchedStats = await ApiService.getDashboardStats();
    final fetchedRecent = await ApiService.getRecentPatient();

    if (mounted) {
      setState(() {
        stats = fetchedStats;
        recentPatient = fetchedRecent;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.teal[700], size: 24),
            const SizedBox(width: 8),
            Text(
              "GENERAL HOSPITAL",
              style: TextStyle(
                color: Colors.teal[900],
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Station 04",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Text(
                      "SnakeBite Unit",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 1. REAL RECENT PATIENT
                    _buildRecentPatientCard(),

                    const SizedBox(height: 30),

                    // 2. REAL STATISTICS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Patient Outcomes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              _buildToggleButton("Monthly", isMonthly),
                              _buildToggleButton("Yearly", !isMonthly),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildOutcomeStatsCard(),

                    const SizedBox(height: 30),

                    // 3. NEWS SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Clinical Updates",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Archive",
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildNewsCard(
                      title: "New Antivenom Protocol",
                      subtitle:
                          "MOH has updated the dosage guidelines for Malayan Pit Viper bites.",
                      imageUrl:
                          "https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=400",
                      tag: "MOH GUIDELINE",
                      tagColor: Colors.blue,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // --- WIDGETS ---

  Widget _buildToggleButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => isMonthly = (text == "Monthly")),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPatientCard() {
    if (recentPatient == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("No patients recorded yet."),
      );
    }

    String id = recentPatient!['patient_id'] ?? "Unknown";
    String disposition = recentPatient!['final_disposition'] ?? "Pending";
    String time = recentPatient!['diagnosis_time'] ?? "Just now";

    // Dynamic Styling
    Color accentColor = Colors.blue;
    Color lightBg = Colors.blue.shade50;
    if (disposition.contains("Discharge")) {
      accentColor = Colors.green;
      lightBg = Colors.green.shade50;
    } else if (disposition.contains("ICU")) {
      accentColor = Colors.red;
      lightBg = Colors.red.shade50;
    } else if (disposition.contains("Observation")) {
      accentColor = Colors.orange;
      lightBg = Colors.orange.shade50;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border(left: BorderSide(color: accentColor, width: 6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: lightBg, shape: BoxShape.circle),
              child: Icon(
                Icons.assignment_ind_outlined,
                color: accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      disposition.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time.split(' ')[0],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: Increased Height to prevent Overflow
  Widget _buildOutcomeStatsCard() {
    int icu = stats['ICU'] ?? 0;
    int ward = stats['Ward'] ?? 0;
    int observation = stats['Observation'] ?? 0;
    int discharged = stats['Discharge'] ?? 0;
    int total = stats['total'] ?? 0;

    int maxVal = [
      icu,
      ward,
      observation,
      discharged,
    ].reduce((curr, next) => curr > next ? curr : next);

    if (maxVal == 0) maxVal = 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Cases (All Time)",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            "$total",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // CHANGED HEIGHT FROM 180 -> 220 TO FIX OVERFLOW
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildVerticalBar("ICU", icu, maxVal, Colors.red.shade400),
                _buildVerticalBar("Ward", ward, maxVal, Colors.blue.shade400),
                _buildVerticalBar(
                  "Observ.",
                  observation,
                  maxVal,
                  Colors.orange.shade400,
                ),
                _buildVerticalBar(
                  "Disch.",
                  discharged,
                  maxVal,
                  Colors.green.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBar(String label, int value, int maxValue, Color color) {
    double percentage = maxValue > 0 ? (value / maxValue) : 0.0;
    if (percentage < 0.1 && value > 0) percentage = 0.1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min, // Added min size for safety
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          tween: Tween(begin: 0, end: percentage),
          builder: (context, val, child) {
            return Container(
              width: 40,
              height: 120 * val,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[200]),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
