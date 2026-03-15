import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart'; // #5: Shimmer loading
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/providers/dashboard_provider.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:snake_bite_resq/widgets/glass_card.dart';
import 'package:snake_bite_resq/screens/hospital_locator_screen.dart';
import 'package:snake_bite_resq/screens/profile_screen.dart';
import 'package:snake_bite_resq/screens/case_history_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _triggerOfflineSync();
  }

  Future<void> _triggerOfflineSync() async {
    // Wait a bit for app to settle
    await Future.delayed(const Duration(seconds: 2));
    // Import ApiService inside method or at top (ensure import exists)
    // Assuming ApiService is imported or available via export.
    // If not, we need to add import 'package:snake_bite_resq/services/api_service.dart';

    // Check if mounted before calling sync
    if (!mounted) return;

    // Use a microtask or local logic to not block UI
    ApiService.syncPendingData().then((count) {
      if (count > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Synced $count offline records to server."),
            backgroundColor: Colors.teal,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access Provider
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final stats = dashboardProvider.stats;
    final recentPatient = dashboardProvider.recentPatient;
    final isLoading = dashboardProvider.isLoading;
    final isMonthly = dashboardProvider.isMonthly;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Consumer<AuthService>(
          builder: (context, auth, _) => Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "KIOSK UNIT · ${auth.unitId ?? '—'}",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      auth.hospitalName ?? "SnakeBiteResQ",
                      style: TextStyle(
                        color: Colors.blueGrey.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          GlassCard(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            borderRadius: BorderRadius.circular(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _pulseController,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "ONLINE",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueGrey.shade300),
              ),
              child: Icon(Icons.person, color: Colors.blueGrey.shade700),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Emergency Contact"),
              content: const Text("Call Poison Center Specialist?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    final uri = Uri.parse(
                      "tel:+60320988000",
                    ); // Malaysia Poison Centre
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Unable to launch dialer."),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.call),
                  label: const Text("CALL NOW"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.emergency),
        label: const Text("EMERGENCY"),
      ),
      body: isLoading
          ? _buildShimmerDashboard() // #5: Shimmer loader
          : RefreshIndicator(
              onRefresh: dashboardProvider.loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 1. REAL RECENT PATIENT
                    _buildRecentPatientCard(recentPatient),

                    const SizedBox(height: 24),

                    // 2. PATIENT OUTCOMES (Bar Chart)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Patient Outcomes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900, // White
                          ),
                        ),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            children: [
                              _buildToggleButton(context, "Monthly", isMonthly),
                              _buildToggleButton(context, "Yearly", !isMonthly),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildOutcomeStatsCard(stats, isMonthly),

                    const SizedBox(height: 24),

                    // 3. NEAREST STOCKPILES
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HospitalLocatorScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade500,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.map,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Nearest Antivenom Stockpiles",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Locate generic & specific antivenom nearby",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 4. CASE HISTORY SHORTCUT
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CaseHistoryScreen(),
                        ),
                      ),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_edu_rounded,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "View Case History",
                                style: TextStyle(
                                  color: Colors.blueGrey.shade900,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blueGrey.shade400,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 5. CLINICAL UPDATES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Clinical Updates",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildNewsCarousel(),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
    );
  }

  // #5: Shimmer loader for the dashboard
  Widget _buildShimmerDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Shimmer.fromColors(
        baseColor: Colors.blueGrey.shade100,
        highlightColor: Colors.blueGrey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(width: 100, height: 14, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 250, height: 32, color: Colors.white),
            const SizedBox(height: 24),
            // Recent Patient Card skeleton
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            // Shortcut button skeleton
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 30),
            // Stats skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 150, height: 20, color: Colors.white),
                Container(
                  width: 120,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildToggleButton(BuildContext context, String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Provider.of<DashboardProvider>(
          context,
          listen: false,
        ).toggleTimeFilter(text);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.transparent, // TealAccent Tint
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: Colors.blue.withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Colors.blue.shade700
                : Colors.blueGrey.shade500, // TealAccent / White70
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPatientCard(Map<String, dynamic>? recentPatient) {
    if (recentPatient == null) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueGrey.shade200, width: 1),
                ),
                child: Icon(
                  Icons.monitor_heart_outlined,
                  color: Colors.blue.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "System Ready",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Awaiting first patient diagnosis.\nRecords will stream here securely.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    String id = recentPatient['patient_id'] ?? "Unknown";
    String disposition = recentPatient['disposition'] ?? "Pending";
    String species = recentPatient['species'] ?? "Unknown";
    String time = recentPatient['recorded_at'] ?? "Just now";

    // Dynamic Styling
    Color accentColor = Colors.blue;
    Color lightBg = Colors.blue.withValues(alpha: 0.1); // Glassy bg
    if (disposition.contains("Discharge")) {
      accentColor = Colors.greenAccent;
      lightBg = Colors.green.withValues(alpha: 0.1);
    } else if (disposition.contains("ICU")) {
      accentColor = Colors.redAccent;
      lightBg = Colors.red.withValues(alpha: 0.1);
    } else if (disposition.contains("Observation")) {
      accentColor = Colors.orangeAccent;
      lightBg = Colors.orange.withValues(alpha: 0.1);
    }

    return GlassCard(
      width: double.infinity,
      color: accentColor, // TINT THE WHOLE CARD
      opacity: 0.15, // Visible tint on light background
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accentColor, width: 6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightBg,
                  shape: BoxShape.circle,
                ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      species,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        border: Border.all(
                          color: accentColor.withValues(
                            alpha: 0.5,
                          ), // More visible border
                        ),
                        boxShadow: [
                          // #4: Context-Aware Glowing border
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ],
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
                      color: Colors.blueGrey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.blueGrey.shade300,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeStatsCard(Map<String, dynamic> stats, bool isMonthly) {
    // Process stats into chart data points
    final double icuRaw = double.tryParse(stats["ICU"]?.toString() ?? "0") ?? 0;
    final double wardRaw =
        double.tryParse(stats["Ward"]?.toString() ?? "0") ?? 0;
    final double obsRaw =
        double.tryParse(stats["Observation"]?.toString() ?? "0") ?? 0;
    final double disRaw =
        double.tryParse(stats["Discharge"]?.toString() ?? "0") ?? 0;

    // Check if there's any data
    final bool hasData = (icuRaw + wardRaw + obsRaw + disRaw) > 0;

    // Find maximum count for scaling Y-axis
    final double maxVal = hasData
        ? [icuRaw, wardRaw, obsRaw, disRaw].reduce((a, b) => a > b ? a : b)
        : 10;
    final double maxY = maxVal <= 5 ? 5 : (maxVal * 1.2).ceilToDouble();

    // Helper to build bar groups
    BarChartGroupData makeGroupData(int x, double y, Color barColor) {
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: hasData ? y : 0,
            color: barColor,
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: barColor.withValues(alpha: 0.1),
            ),
          ),
        ],
        showingTooltipIndicators: [0], // Always show the number on top
      );
    }

    final barGroups = [
      makeGroupData(0, icuRaw, Colors.redAccent),
      makeGroupData(1, wardRaw, Colors.orange),
      makeGroupData(2, obsRaw, Colors.amber),
      makeGroupData(3, disRaw, Colors.green),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Patient Dispositions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isMonthly ? "This Month" : "This Year",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40), // More space for tooltips
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        TextStyle(
                          color: rod.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('ICU', style: style);
                            break;
                          case 1:
                            text = const Text('Ward', style: style);
                            break;
                          case 2:
                            text = const Text('Obs.', style: style);
                            break;
                          case 3:
                            text = const Text('Disch.', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 10,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Hide left Y axis
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 10 ? (maxY / 5) : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutBack,
            ),
          ),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  "No patient records found for this period.",
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCarousel() {
    const updates = [
      {
        'tag': 'MOH GUIDELINE',
        'icon': 0xe1b3, // medical_services
        'color': 0xFF0277BD,
        'title': 'Updated Antivenom Protocol 2025',
        'body':
            'MOH Malaysia has revised dosage guidelines for Pit Viper envenomation. First-line dose is now 10 vials IV with repeat 20WBCT assessment at 6 h.',
      },
      {
        'tag': 'CLINICAL ALERT',
        'icon': 0xe000, // warning_amber
        'color': 0xFFB71C1C,
        'title': 'Rising Cobra Bites in North Kedah',
        'body':
            'A 30% increase in Naja sumatrana bites was reported in Kubang Pasu this quarter. Elevated neostigmine readiness recommended at all stations.',
      },
      {
        'tag': 'RESEARCH',
        'icon': 0xe1b4, // science
        'color': 0xFF1B5E20,
        'title': 'WBCT Sensitivity Study — UM 2025',
        'body':
            'A new UM study confirms 20-minute WBCT has 97% sensitivity for systemic coagulopathy. Liquid result at 20 min mandates antivenom irrespective of clinical bleeding.',
      },
      {
        'tag': 'TRAINING',
        'icon': 0xe80c, // school
        'color': 0xFF4A148C,
        'title': 'ToxBase Snakebite Course — June 2025',
        'body':
            'MOH and IMU are co-hosting a snakebite management workshop in Alor Setar on 14–15 June 2025. CPD points available for attendees.',
      },
    ];

    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        padEnds: false,
        itemCount: updates.length,
        itemBuilder: (context, i) {
          final u = updates[i];
          final accent = Color(u['color'] as int);
          return Padding(
            padding: EdgeInsets.only(right: i < updates.length - 1 ? 12 : 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconData(u['icon'] as int, fontFamily: 'MaterialIcons'),
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u['tag'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    u['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      u['body'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
