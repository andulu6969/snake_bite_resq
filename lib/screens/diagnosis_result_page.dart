import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/providers/dashboard_provider.dart';
import 'package:snake_bite_resq/screens/main_screen.dart';
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/logic/diagnosis_logic.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';

class DiagnosisResultPage extends StatelessWidget {
  final String patientId;
  final DiagnosisOutcome outcome;
  final String icPassport;
  final String diagnosedBy;
  final String hospitalName;

  const DiagnosisResultPage({
    super.key,
    required this.patientId,
    required this.outcome,
    this.icPassport = '',
    this.diagnosedBy = '',
    this.hospitalName = '',
  });
  @override
  Widget build(BuildContext context) {
    final Color mainColor = Color(outcome.color);
    final IconData mainIcon = IconData(
      outcome.icon,
      fontFamily: 'MaterialIcons',
    );

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Diagnosis Report",
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          centerTitle: true,
          automaticallyImplyLeading: false, // removes default back arrow
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.blueGrey.shade900,
              ),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ],
        ),
        body: Column(
          children: [
            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 1. PATIENT HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Patient ID: $patientId",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. DYNAMIC ALERT BANNER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mainColor.withValues(alpha: 0.2), mainColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(mainIcon, color: Colors.white, size: 40),
                          const SizedBox(height: 10),
                          Text(
                            outcome.title, // DYNAMIC TITLE
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            outcome.description, // DYNAMIC DESCRIPTION
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 3. IDENTIFIED SPECIES CARD (Dynamic)
                    IntrinsicHeight(
                      // <--- 1. Wrap Row in IntrinsicHeight
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, // <--- 2. Stretch children to fill height
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Suspected Species",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    outcome.suspectedSpecies,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  // Removed the SizedBox(height: 68) hack here.
                                  // The container now stretches automatically.
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Snake image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: outcome.imageAsset.isNotEmpty
                                      ? Image.asset(
                                          outcome.imageAsset,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                height: 150,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported_outlined,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                // Source attribution
                                if (outcome.imageAsset.isNotEmpty) ...
                                  [
                                    const SizedBox(height: 6),
                                    Text(
                                      "Source: Guideline: Management of Snakebite (2017), Ministry of Health Malaysia",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.blueGrey.shade400,
                                        fontStyle: FontStyle.italic,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 4. DYNAMIC TREATMENT TIMELINE
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Recommended Treatment Protocol",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Generate Steps dynamically
                    ...outcome.treatmentSteps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return _buildTreatmentStep(
                        step['step'],
                        step['title'],
                        step['desc'],
                        index ==
                            outcome.treatmentSteps.length -
                                1, // #12: index-based
                        Color(step['color']),
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- 5. BOTTOM ACTION BAR (DISPOSITION) ---
            Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => _showDispositionPopup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_outlined),
                      SizedBox(width: 10),
                      Text(
                        "DECIDE NEXT STEP / DISPOSITION",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW: SCROLLABLE POPUP DIALOG ---
  void _showDispositionPopup(BuildContext context) {
    // --- 1. DETERMINE RECOMMENDATION BASED ON DIAGNOSIS LOGIC ---
    // This implements your 4 specific rules:
    String recommendedOption = "Observation"; // Default to Observation (Rule 1)

    if (outcome.severity == "CRITICAL") {
      // Rule 4: Severe envenoming (Neurotoxic/Haematotoxic) -> ICU
      recommendedOption = "Admit ICU";
    } else if (outcome.severity == "HIGH" || outcome.severity == "MODERATE") {
      // Rule 3: Features of Envenomation -> General Ward
      recommendedOption = "Admit Ward";
    } else if (outcome.title.contains("NON-VENOMOUS")) {
      // Rule 2: Identified Non-venomous -> Discharge
      // (Note: You might need to refine Logic to separate 'Unknown' vs 'Non-venomous' strictly)
      recommendedOption = "Discharge";
    } else {
      // Rule 1: Unidentified / No signs -> Observation
      recommendedOption = "Observation";
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent, // Transparent for GlassCard
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Disposition",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900, // Dark
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.blueGrey.shade500,
                          ), // Dark
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap an option to finalize and save.",
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 13,
                      ), // Dark
                    ),
                    const SizedBox(height: 20),

                    // GRID LAYOUT
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: [
                        // OPTION 1: DISCHARGE
                        _buildGridOption(
                          context,
                          title: "Discharge",
                          subtitle: "Stable",
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                          isRecommended:
                              recommendedOption == "Discharge", // DYNAMIC
                        ),

                        // OPTION 2: OBSERVATION
                        _buildGridOption(
                          context,
                          title: "Observation",
                          subtitle: "24h Monitor",
                          color: Colors.orange,
                          icon: Icons.visibility_outlined,
                          isRecommended:
                              recommendedOption == "Observation", // DYNAMIC
                        ),

                        // OPTION 3: GENERAL WARD
                        _buildGridOption(
                          context,
                          title: "Admit Ward",
                          subtitle: "Envenomated",
                          color: Colors.blue,
                          icon: Icons.bedroom_parent_outlined,
                          isRecommended:
                              recommendedOption == "Admit Ward", // DYNAMIC
                        ),

                        // OPTION 4: ICU
                        _buildGridOption(
                          context,
                          title: "Admit ICU",
                          subtitle: "Critical",
                          color: Colors.red,
                          icon: Icons.local_hospital_outlined,
                          isRecommended:
                              recommendedOption == "Admit ICU", // DYNAMIC
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // GRID CARD WIDGET
  Widget _buildGridOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()),
        );

        bool success = await ApiService.savePatientOutcome(
          patientId:    patientId,
          species:      outcome.suspectedSpecies,
          severity:     outcome.severity,
          disposition:  title,
          icPassport:   icPassport.isNotEmpty ? icPassport : null,
          diagnosedBy:  diagnosedBy.isNotEmpty ? diagnosedBy : null,
          hospitalName: hospitalName.isNotEmpty ? hospitalName : null,
        );

        if (!context.mounted) return;

        Navigator.pop(context); // Pop Loader
        Navigator.pop(context); // Pop Dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Success: Patient $patientId Saved!"),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the dashboard so the chart & recent patient update immediately
          if (context.mounted) {
            Provider.of<DashboardProvider>(
              context,
              listen: false,
            ).loadDashboardData();
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const MainScreen()),
            (r) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to save. Check connection."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRecommended
              ? color.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? color : Colors.grey.shade300,
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isRecommended
                  ? color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "RECOMMENDED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blueGrey.shade900, // Dark
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontSize: 11,
              ), // Dark
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentStep(
    String step,
    String title,
    String desc,
    bool isLast,
    Color color,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.blueGrey.shade200),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey.shade900, // Dark
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      height: 1.4,
                    ), // Dark
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
