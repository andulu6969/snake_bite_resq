import 'package:flutter/material.dart';
import 'package:snake_bite_resq/screens/test_datail_screen.dart'; // Keep existing
import 'package:snake_bite_resq/screens/legal_info_screen.dart'; // Import NEW screen

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Resources",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Clinical Protocols",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search guidelines, tests...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST OF PROTOCOLS ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const Text(
                    "Bedside & Lab Tests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  _buildProtocolCard(
                    context,
                    title: "20WBCT",
                    subtitle: "Whole Blood Clotting Test",
                    category: "BEDSIDE",
                    color: Colors.red,
                    icon: Icons.water_drop,
                  ),
                  _buildProtocolCard(
                    context,
                    title: "Neostigmine Test",
                    subtitle: "Neurotoxic reversibility assessment",
                    category: "BEDSIDE",
                    color: Colors.purple,
                    icon: Icons.visibility,
                  ),
                  _buildProtocolCard(
                    context,
                    title: "Single Breath Count",
                    subtitle: "Respiratory failure monitoring",
                    category: "OBSERVATION",
                    color: Colors.blue,
                    icon: Icons.timer,
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Treatment Guidelines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  _buildProtocolCard(
                    context,
                    title: "Antivenom Dosage",
                    subtitle: "Polyvalent vs Monovalent Dosing",
                    category: "MEDICATION",
                    color: Colors.teal,
                    icon: Icons.medication,
                  ),
                  _buildProtocolCard(
                    context,
                    title: "Anaphylaxis Management",
                    subtitle: "Adrenaline & Corticosteroid Protocol",
                    category: "EMERGENCY",
                    color: Colors.orange,
                    icon: Icons.warning_amber,
                  ),

                  // --- NEW SECTION: APP INFO ---
                  const SizedBox(height: 25),
                  const Text(
                    "App Info",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  _buildProtocolCard(
                    context,
                    title: "Terms & Conditions",
                    subtitle: "Disclaimer and Liability",
                    category: "LEGAL",
                    color: Colors.grey,
                    icon: Icons.gavel,
                  ),
                  _buildProtocolCard(
                    context,
                    title: "Privacy Policy",
                    subtitle: "Data protection info",
                    category: "LEGAL",
                    color: Colors.blueGrey,
                    icon: Icons.security,
                  ),
                  _buildProtocolCard(
                    context,
                    title: "About",
                    subtitle: "Version 1.0.0",
                    category: "INFO",
                    color: Colors.teal,
                    icon: Icons.info_outline,
                  ),

                  const SizedBox(height: 100), // Bottom padding for Nav Bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String category,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        // LOGIC: If it is Legal/Info, go to LegalScreen. Else go to TestDetailScreen.
        if (category == "LEGAL" || category == "INFO") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LegalInfoScreen(title: title),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestDetailScreen(testName: title),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Text(
                    category,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}
