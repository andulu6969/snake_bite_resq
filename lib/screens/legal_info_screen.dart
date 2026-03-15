import 'package:flutter/material.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';
import 'package:snake_bite_resq/widgets/glass_card.dart';

class LegalInfoScreen extends StatelessWidget {
  final String title;

  const LegalInfoScreen({super.key, required this.title});

  // --- MOCK CONTENT FACTORY ---
  String _getContent() {
    if (title == "Terms & Conditions") {
      return """
1. Disclaimer
The SnakeBiteResQ app is a Clinical Decision Support System (CDSS) intended for use by qualified medical professionals only. It does not replace clinical judgment.

2. Liability
The developers and the Ministry of Health are not liable for any adverse outcomes resulting from the use of this app. All treatment decisions remain the responsibility of the treating physician.

3. Accuracy
While every effort has been made to ensure the accuracy of the protocols, guidelines may change. Users should always cross-reference with the latest MOH circulars.
      """;
    } else if (title == "Privacy Policy") {
      return """
1. Data Collection
We collect patient demographics and clinical parameters for the purpose of diagnosis and hospital statistics.

2. Data Storage
All data is stored locally on the secure hospital server (XAMPP). No patient identifiable data is transmitted to external cloud servers.

3. Access
Only authorized personnel within the Emergency Department have access to this system.
      """;
    } else {
      return """
SnakeBiteResQ v1.0.0
Developed for: Ministry of Health Malaysia
Developer: ANDREW LOOI SZU KIT

This application was built to assist in the rapid identification and management of snakebite envenomation cases in the Emergency Department.
      """;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blueGrey.shade900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _getContent(),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (title.contains("About"))
                Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_hospital_rounded,
                          size: 72,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "SnakeBiteResQ",
                          style: TextStyle(
                            color: Colors.blueGrey.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ), // Column
        ), // SingleChildScrollView
      ), // Scaffold
    ); // GradientBackground
  }
}
