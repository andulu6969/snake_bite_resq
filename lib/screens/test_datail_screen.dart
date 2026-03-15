import 'package:flutter/material.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';

class TestDetailScreen extends StatelessWidget {
  final String testName;

  const TestDetailScreen({super.key, required this.testName});

  /// Returns the matching infographic asset path and metadata for this protocol.
  Map<String, dynamic> _getProtocolInfo() {
    if (testName.contains("20WBCT")) {
      return {
        "tag": "BEDSIDE DIAGNOSTIC",
        "tagColor": Colors.red,
        "imagePath": "assets/infographics/20wbct.png",
        "description":
            "The 20-minute Whole Blood Clotting Test (20WBCT) is the standard bedside test for diagnosing coagulopathy (haematotoxic envenomation) in Viper bites.",
      };
    } else if (testName.contains("Neostigmine")) {
      return {
        "tag": "NEUROLOGICAL TEST",
        "tagColor": Colors.purple,
        "imagePath": "assets/infographics/neostigmine.png",
        "description":
            "The Neostigmine Challenge Test distinguishes postsynaptic (Cobra) from presynaptic (Krait) neurotoxicity.",
      };
    } else if (testName.contains("Single Breath")) {
      return {
        "tag": "RESPIRATORY MONITORING",
        "tagColor": Colors.blue,
        "imagePath": "assets/infographics/single_breath_count.png",
        "description":
            "Single Breath Count (SBC) is a rapid, non-invasive bedside tool to monitor respiratory muscle strength in neurotoxic snakebite.",
      };
    } else if (testName.contains("Antivenom")) {
      return {
        "tag": "TREATMENT PROTOCOL",
        "tagColor": Colors.teal,
        "imagePath": "assets/infographics/antivenom_dosage.png",
        "description":
            "Antivenom is the definitive treatment for systemic snakebite envenomation. Covers Polyvalent ASV dosage, indications, and administration.",
      };
    } else if (testName.contains("Anaphylaxis")) {
      return {
        "tag": "EMERGENCY PROTOCOL",
        "tagColor": Colors.orange,
        "imagePath": "assets/infographics/anaphylaxis.png",
        "description":
            "Emergency response protocol for anaphylaxis following antivenom administration. Prompt recognition and treatment with Adrenaline is life-saving.",
      };
    } else {
      return {
        "tag": "GENERAL PROTOCOL",
        "tagColor": Colors.teal,
        "imagePath": null,
        "description":
            "Standard clinical guideline for managing snakebite patients according to MOH Malaysia protocols.",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getProtocolInfo();
    final String? imagePath = data['imagePath'];
    final Color tagColor = data['tagColor'] as Color;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              data['tag'],
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            testName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey.shade900,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- SCROLLABLE CONTENT ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  children: [
                    // Brief description
                    Text(
                      data['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hint for pinch-to-zoom
                    Row(
                      children: [
                        Icon(
                          Icons.pinch_outlined,
                          size: 14,
                          color: Colors.blueGrey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Pinch to zoom · Double-tap to reset",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Infographic image with pinch-to-zoom
                    if (imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 5.0,
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.fitWidth,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImagePlaceholder(tagColor),
                            ),
                          ),
                        ),
                      )
                    else
                      _buildImagePlaceholder(tagColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color tagColor) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tagColor.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 48, color: tagColor.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              "Infographic coming soon",
              style: TextStyle(
                color: tagColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Place image in assets/infographics/",
              style: TextStyle(
                fontSize: 11,
                color: tagColor.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
