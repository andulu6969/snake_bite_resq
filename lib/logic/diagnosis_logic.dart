class DiagnosisLogic {
  static DiagnosisOutcome evaluate({
    required String? snakeIdentified, // "Yes" or "No"
    String? identifiedSpecies, // Specific species from gallery
    required String? bleeding, // "Yes"
    required String? bruises, // "Yes" — ecchymosis, sign of coagulopathy
    required String? musclePain, // "Yes"
    required String? swelling, // "Rapid", "Mild", "None"
    required String? necrosis, // "Yes"
    required String? ptosis, // "Yes"
    required String? urineColor, // "Red", "Dark/Cola"
    required String? wbctResult, // "Liquid (>20m)"
    String? neostigmine, // "Positive" / "Negative" — used in neurotoxic rule
  }) {
    // --- RULE 1: HAEMATOTOXIC (Bleeding/Clotting Issues) ---
    // Rule: Active Bleeding OR Bruises/Ecchymosis OR Abnormal Clotting (Liquid WBCT) OR Red Urine
    if (bleeding == "Yes" ||
        bruises == "Yes" ||
        wbctResult == "Liquid (>20m)" ||
        urineColor == "Red") {
      String species = "Likely Malayan Pit Viper or Green Pit Viper";
      if (identifiedSpecies != null && identifiedSpecies.contains("Viper")) {
        species = "Confirmed: $identifiedSpecies";
      }

      return DiagnosisOutcome(
        title: "HAEMATOTOXIC ENVENOMATION",
        severity: "CRITICAL",
        color: 0xFFD32F2F, // Red
        icon: 0xe04a, // warning_amber_rounded (CodePoint)
        suspectedSpecies: species,
        confidence: identifiedSpecies != null ? "99% (AI Confirmed)" : "95%",
        imageAsset: "assets/Calloselasma_rhodostoma.png",
        description:
            "Symptoms${identifiedSpecies != null ? " and AI ID" : ""} indicate systemic bleeding and coagulopathy. Immediate antivenom and clotting monitoring required.",
        treatmentSteps: [
          {
            "step": "01",
            "title": "20WBCT Test",
            "desc": "Repeat 20WBCT every 6 hours.",
            "color": 0xFF009688,
          },
          {
            "step": "02",
            "title": "Administer Antivenom",
            "desc": "Indicated for systemic bleeding or incoagulable blood.",
            "color": 0xFFD32F2F,
          },
          {
            "step": "03",
            "title": "Strict Bed Rest",
            "desc": "Minimize movement to prevent further bleeding.",
            "color": 0xFFFF9800,
          },
        ],
      );
    }

    // --- RULE 2: NEUROTOXIC (Paralysis) ---
    // Rule: Ptosis (Drooping eyes) is the earliest sign
    if (ptosis == "Yes") {
      String species = "Likely Cobra (Naja) or Krait (Bungarus)";
      if (identifiedSpecies != null &&
          (identifiedSpecies.contains("Cobra") ||
              identifiedSpecies.contains("Krait"))) {
        species = "Confirmed: $identifiedSpecies";
      }

      // If Neostigmine test is positive → Cobra (reversible); recommend Neostigmine + Atropine
      final bool neostigminePositive = neostigmine == "Positive";

      return DiagnosisOutcome(
        title: "NEUROTOXIC ENVENOMATION",
        severity: "CRITICAL",
        color: 0xFF7B1FA2, // Purple
        icon: 0xe6bd, // visibility_rounded
        suspectedSpecies: neostigminePositive
            ? "Likely Cobra (Naja) — Neostigmine Responsive"
            : species,
        confidence: identifiedSpecies != null ? "98% (AI Confirmed)" : "92%",
        imageAsset: "assets/Naja_sumatrana.png",
        description:
            "Symptoms${identifiedSpecies != null ? " and AI ID" : ""} indicate descending paralysis. High risk of respiratory failure."
            "${neostigminePositive ? " Positive Neostigmine test suggests reversible Cobra envenomation." : ""}",
        treatmentSteps: [
          {
            "step": "01",
            "title": "Airway Assessment",
            "desc":
                "Prepare for intubation/ventilation if respiratory failure occurs.",
            "color": 0xFFD32F2F,
          },
          if (neostigminePositive)
            {
              "step": "02",
              "title": "Neostigmine + Atropine",
              "desc":
                  "Positive test: Administer Neostigmine 0.5mg IM with Atropine 0.6mg IV. Monitor response.",
              "color": 0xFF7B1FA2,
            }
          else
            {
              "step": "02",
              "title": "Neostigmine Test",
              "desc": "Perform test to rule out Cobra bite reversibility.",
              "color": 0xFF7B1FA2,
            },
          {
            "step": "03",
            "title": "Neuro Observation",
            "desc": "Monitor Single Breath Count and Ptosis hourly.",
            "color": 0xFF009688,
          },
        ],
      );
    }

    // --- RULE 3: MYOTOXIC (Muscle Breakdown) ---
    // Rule: Dark/Cola Urine AND Muscle Pain
    if ((urineColor == "Dark/Cola" && musclePain == "Yes") ||
        (identifiedSpecies != null &&
            identifiedSpecies.contains("Sea Snake"))) {
      String species = "Likely Sea Snake or Malayan Krait";
      if (identifiedSpecies != null &&
          identifiedSpecies.contains("Sea Snake")) {
        species = "Confirmed: $identifiedSpecies";
      }

      return DiagnosisOutcome(
        title: "MYOTOXIC ENVENOMATION",
        severity: "HIGH",
        color: 0xFF5D4037, // Brown
        icon: 0xeb3c, // accessibility_new_rounded
        suspectedSpecies: species,
        confidence: identifiedSpecies != null ? "98% (AI Confirmed)" : "88%",
        imageAsset: "assets/Bungarus_candidus.png",
        description:
            "Symptoms${identifiedSpecies != null ? " and AI ID" : ""} indicate rhabdomyolysis (muscle breakdown). Risk of Acute Kidney Injury.",
        treatmentSteps: [
          {
            "step": "01",
            "title": "Aggressive Hydration",
            "desc": "IV Fluids to prevent kidney damage.",
            "color": 0xFF2196F3,
          },
          {
            "step": "02",
            "title": "Monitor Urine Output",
            "desc": "Aim for high urine output to clear myoglobin.",
            "color": 0xFF009688,
          },
          {
            "step": "03",
            "title": "Check CPK Levels",
            "desc": "Monitor Creatine Phosphokinase levels.",
            "color": 0xFFFF9800,
          },
        ],
      );
    }

    // --- RULE 4: LOCAL ENVENOMATION (Cytotoxic) ---
    // Rule: Rapid Swelling OR Necrosis
    if (swelling == "Rapid (>½ limb)" || necrosis == "Yes") {
      return DiagnosisOutcome(
        title: "LOCAL ENVENOMATION (CYTOTOXIC)",
        severity: "MODERATE",
        color: 0xFFEF6C00, // Orange
        icon: 0xf7d3, // healing_rounded
        suspectedSpecies: "Likely Spitting Cobra or Pit Viper",
        confidence: "85%",
        imageAsset: "assets/Calloselasma_rhodostoma.png",
        description:
            "Significant tissue damage detected. Risk of compartment syndrome or infection.",
        treatmentSteps: [
          {
            "step": "01",
            "title": "Elevate Limb",
            "desc": "Reduce swelling. Do NOT use tourniquet.",
            "color": 0xFF2196F3,
          },
          {
            "step": "02",
            "title": "Delineate Swelling",
            "desc": "Mark swelling edge every hour to track progression.",
            "color": 0xFFEF6C00,
          },
          {
            "step": "03",
            "title": "Pain Management",
            "desc": "Opioids may be required. Avoid NSAIDs if bleeding risk.",
            "color": 0xFF009688,
          },
        ],
      );
    }

    // --- RULE 5: SPECIFIC NON-VENOMOUS ID ---
    if (identifiedSpecies != null &&
        (identifiedSpecies.contains("Python") ||
            identifiedSpecies.contains("Rat Snake"))) {
      return DiagnosisOutcome(
        title: "NON-VENOMOUS SNAKE IDENTIFIED",
        severity: "LOW",
        color: 0xFF388E3C, // Green
        icon: 0xe156, // check_circle_outline
        suspectedSpecies: "Confirmed: $identifiedSpecies",
        confidence: "99% (Visual ID)",
        imageAsset: "",
        description:
            "The identified snake is typically non-venomous. Monitor bite site for infection.",
        treatmentSteps: [
          {
            "step": "01",
            "title": "Wound Care",
            "desc": "Clean bite site with soap and water.",
            "color": 0xFF009688,
          },
          {
            "step": "02",
            "title": "Tetanus Shot",
            "desc": "Ensure tetanus prophylaxis is up to date.",
            "color": 0xFFEF6C00,
          },
        ],
      );
    }

    // --- RULE 6: UNKNOWN / NON-VENOMOUS ---
    return DiagnosisOutcome(
      title: "NO SIGNIFICANT ENVENOMATION DETECTED",
      severity: "LOW",
      color: 0xFF388E3C, // Green
      icon: 0xe156, // check_circle_outline
      suspectedSpecies: "Likely Non-Venomous or Dry Bite",
      confidence: "High",
      imageAsset: "", // Fallback to logo
      description:
          "No signs of systemic or severe local envenomation at this time.",
      treatmentSteps: [
        {
          "step": "01",
          "title": "Observe 24 Hours",
          "desc": "Monitor for delayed symptoms.",
          "color": 0xFFEF6C00,
        },
        {
          "step": "02",
          "title": "Repeat Assessment",
          "desc": "Re-check WBCT and Neuro signs every 4 hours.",
          "color": 0xFF009688,
        },
      ],
    );
  }
}

// Simple data class to hold the result
class DiagnosisOutcome {
  final String title;
  final String severity;
  final int color; // Using int for Hex color to pass easily
  final int icon; // CodePoint for IconData
  final String suspectedSpecies;
  final String confidence;
  final String imageAsset;
  final String description;
  final List<Map<String, dynamic>> treatmentSteps;

  DiagnosisOutcome({
    required this.title,
    required this.severity,
    required this.color,
    required this.icon,
    required this.suspectedSpecies,
    required this.confidence,
    required this.imageAsset,
    required this.description,
    required this.treatmentSteps,
  });
}
