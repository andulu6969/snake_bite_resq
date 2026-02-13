import 'package:flutter/material.dart';

class TestDetailScreen extends StatelessWidget {
  final String testName;

  const TestDetailScreen({super.key, required this.testName});

  // --- MOCK DATA FACTORY ---
  // In a real app, this would come from a database or JSON file.
  Map<String, dynamic> _getTestDetails() {
    if (testName.contains("20WBCT")) {
      return {
        "tag": "BEDSIDE DIAGNOSTIC",
        "tagColor": Colors.red,
        "description":
            "The 20-minute Whole Blood Clotting Test is the standard bedside test for diagnosing coagulopathy (haematotoxic envenomation) in Viper bites.",
        "warning":
            "Do not shake the tube. Even slight agitation can falsely trigger clotting mechanisms.",
        "steps": [
          {
            "title": "Prepare Equipment",
            "desc":
                "Use a clean, dry, new glass test tube. Do not use plastic tubes.",
          },
          {
            "title": "Collect Blood",
            "desc":
                "Draw 2-3ml of venous blood from the patient (preferably from a site away from the bite).",
          },
          {
            "title": "Wait",
            "desc":
                "Leave the tube undisturbed at ambient temperature for exactly 20 minutes.",
          },
          {
            "title": "Observation",
            "desc":
                "Tip the tube once. If the blood remains liquid and runs out, the test is POSITIVE (incoagulable).",
          },
        ],
      };
    } else if (testName.contains("Neostigmine")) {
      return {
        "tag": "NEUROLOGICAL TEST",
        "tagColor": Colors.purple,
        "description":
            "Used to distinguish between postsynaptic (Cobra) and presynaptic (Krait) neurotoxicity. Positive response indicates potential benefit from Neostigmine therapy.",
        "warning":
            "Ensure Atropine is available at bedside to counter muscarinic side effects.",
        "steps": [
          {
            "title": "Baseline Assessment",
            "desc":
                "Measure the distance between upper and lower eyelids (palpebral fissure) or use the single breath count.",
          },
          {
            "title": "Administer Atropine",
            "desc": "Give Atropine (0.6mg IV) first to block side effects.",
          },
          {
            "title": "Administer Neostigmine",
            "desc": "Give Neostigmine (0.5mg - 2.5mg IV) slowly.",
          },
          {
            "title": "Re-evaluate",
            "desc":
                "Observe for improvement in ptosis or respiratory effort after 30-60 minutes.",
          },
        ],
      };
    } else {
      // Default / Generic Fallback
      return {
        "tag": "GENERAL PROTOCOL",
        "tagColor": Colors.teal,
        "description":
            "Standard clinical guideline for managing snakebite patients according to MOH Malaysia protocols.",
        "warning":
            "Always consult a senior specialist if unsure about diagnosis.",
        "steps": [
          {
            "title": "Assessment",
            "desc":
                "Check patient vitals and identifying features of the bite.",
          },
          {
            "title": "Stabilization",
            "desc": "Ensure airway is patent and circulation is stable.",
          },
          {
            "title": "Treatment",
            "desc": "Proceed with specific treatment as indicated by symptoms.",
          },
        ],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getTestDetails();
    final List<Map<String, String>> steps = data['steps'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (CUSTOM APP BAR) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Title Text
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
                            color: (data['tagColor'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            data['tag'],
                            style: TextStyle(
                              color: data['tagColor'],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          testName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
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
                padding: const EdgeInsets.all(20),
                children: [
                  // DESCRIPTION CARD
                  Text(
                    data['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // WARNING CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[800],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CLINICAL NOTE",
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['warning'],
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Procedure Steps",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // DYNAMIC STEPS LIST
                  ...List.generate(steps.length, (index) {
                    return _buildStepItem(
                      index + 1,
                      steps[index]['title']!,
                      steps[index]['desc']!,
                    );
                  }),

                  const SizedBox(height: 30), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Circle
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "$stepNumber",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Optional Placeholder for Image per step
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
